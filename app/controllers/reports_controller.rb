
class ReportsController < ApplicationController
  
  include Reporting

  before_filter :check_authentication, :check_admin

  def index
  end

  
  def user
    @user_report = UserReport.new(params)
    @user_report.show
  end

  def billing
    @billing_report = BillingReport.new(params)
    @billing_report.show
  end

  # With the selected project this method will either mark entries as billed,
  # or display a pdf invoice depending on submit name.
  #
  def billing_action
    @billing_report = BillingReport.new(params)
    @billing_report.setup_calendar_for_billing

    if params[:project]
      project_keys = params[:project].keys
      @projects = project_keys.map{|key| Project.find(key.to_i)}

      if params[:report]
        @from_day = @billing_report.day
        @to_day = @billing_report.day.at_end_of_month
        initialize_pdf_download("#{t'invoice.filename'}.pdf")
        render :billing_report, :layout=>false
      else
        @projects.each do |p|
          TimeEntry.mark_as_billed( TimeEntry.for_project(p).between(@billing_report.day, @billing_report.day.at_end_of_month) , true)
        end
        redirect_to params.merge( :action => 'billing', :format => 'html' )
      end

    else
      flash[:error] = "No projects selected"
      redirect_to :action => 'billing', :month => @billing_report.day.month, :year => @billing_report.day.year
    end
  end

  def details
    @user = User.find(params[:user])
    @project = Project.find(params[:project])
    @day = Date.parse(params[:day])
    @time_entries = TimeEntry.for_user(@user).for_project(@project).between(@day, @day.at_end_of_month).sort
  end

  def customer
    @customer_report = CustomerReport.new(params)
    @customer_report.show
  end

  def update_project_content
    if request.xhr?
      project()
      render :partial => 'project_content', :locals => { :user_activity_hours => @user_activity_hours}
    end
  end

  def project
    @customer_report = CustomerReport.new(params)
    @customer_report.show_projects
  end

  def search
    @search_view = SearchView.new(params)
    @search_view.show
    
    @user_id = params[:user].to_i
    @tag_type_id = params[:tag_type].to_i
    @tag_id = params[:tag].to_i
    @group_by = params[:group_by]

    respond_to do |format|
      format.html { }
      format.pdf  do
      @parameters = []
      @parameters << [t('common.period'),"#{@search_view.from_day} to #{@search_view.to_day}"]
      @parameters << [t('common.person'),@search_view.user.fullname] if @search_view.user
      @parameters << [t('common.billable'),@billed ? "Ja" : "Nei"] if @billed
      @parameters << [t('common.customer'),@search_view.customer.name] if @search_view.customer
      @parameters << [t('common.project'),@search_view.project.name]  if @search_view.project
      @parameters << [t('common.category'),@search_view.tag_type.name] if @search_view.tag_type
      @parameters << [t('common.tag'),@search_view.tag.name] if @search_view.tag

      initialize_pdf_download("search_report.pdf")

      render :search, :layout=>false
      end
    end
  end

  def update_search_advanced_form
    if request.xhr?
      @search_view = SearchView.new(params)
      @search_view.prepare_update

      @user_id = params[:user].to_i
      @customer_id = params[:customer].to_i
      @tag_type_id = params[:tag_type].to_i
      @tag_id = params[:tag].to_i
      @group_by = params[:group_by]
            
      render :partial => 'search_advanced_form', :locals => 
        { :user_id => @user_id, :customer_id => @customer_id, :search_view => @search_view, :years => @search_view.years,
        :months => @search_view.months, :customer => @search_view.customer, :tag_type_id => @tag_type_id, :tag_id => @tag_id, :group_by => @group_by }
    end
  end

  def update_search_content
    if request.xhr?
      search()
      render :partial => 'search_content', :locals => { :table => @billing_report}
    end
  end

  def mark_time_entries
    if params[:method] == 'post'
      @search_view = SearchView.new(params)
      @search_view.mark_time_entries
    end
    redirect_to( {:action => 'search'}.merge(params) )
  end
  
end