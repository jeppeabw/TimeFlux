require 'test_helper'

class ReportsControllerTest < ActionController::TestCase

  context "Logged in as user Bob" do
    
    setup do
      login_as(:bob)
      @date = Date.new(2009, 6, 22) # monday in week 26, 2009
      Date.stubs(:today).returns(@date)
    end

    context "on GET report index" do
      setup { get :index }
      should_respond_with :success
    end

    context "on GET to :user" do
      setup { get :user }
      should_respond_with :success
    end

    context "on GET to :customer" do
      setup { get :customer }
      should_respond_with :success
    end

    context "on GET to :project" do
      setup { get :project, :project => projects(:community).id }
      should_respond_with :success
    end

    ## SEARCH RELATED ##
    context "GET to :search with search criteria" do

      should "find all time_entries in current month if all search criteria are empty" do
        get :search, :project_id => "", :user_id => "", :billed => "", :customer => "*"
        search_view = assigns(:search_view)
        time_entries = search_view.time_entries
        assert_equal(TimeEntry.between(@date.at_beginning_of_month, @date.at_end_of_month).count, time_entries.size )
      end

      context "render the result in pdf" do
        setup do 
          get :search, :project_id => "", :user_id => "", :billed => "", :customer => "*", :format => 'pdf'
        end
        should_respond_with :success
        should_assign_to :parameters
      end
    end

    context "GET to :update_search_advanced_form" do
      setup do
        xhr :get, :update_search_advanced_form, :from_month=>"6", :tag_type=>"", :to_year=>"2010", :group_by=>"activity",
          :commit=>"Apply Filter", :to_day=>"30", :type=>"advanced", :controller=>"reports", :to_month=>"6", :customer=>"*",
          :from_year=>"2010", :from_day=>"1", :status=>"", :user=>"", "_"=>""
      end
      should_respond_with :success
    end

    context "marking hours as billed from search page" do
      setup do
        post :mark_time_entries, :mark_as => 'billed', :value => 'true',:month=>7, :year=>2009, :customer => '*',:method => 'post'
      end
      should_change("the number of billed time entries") { TimeEntry.billed(true).count }
    end

    ## END SEARCH RELATED ##

    context "render billing" do
      setup { post :billing }
      should_assign_to  :billing_report
      should_respond_with :success
    end

    context "rendering details" do
      setup { get :details, :project => projects(:community).id, :user => users(:bob).id, :day => Date.today.to_s}
      should_assign_to  :time_entries
      should "show 9 entries" do
        assert_equal 9, assigns(:time_entries).size
      end
    end

    context "POST to :billing_action" do

      context "render report in PDF" do
        setup { post :billing_action, :format=>"pdf", :project =>{ projects(:community).id =>"1"}, :report=>"Report (PDF)" }
        should_assign_to  :projects
        should_respond_with :success
      end

     context "mark time entries as billed" do
        setup { post :billing_action, :format=>"pdf", :project =>{ projects(:community).id =>"1"}, :bill =>"Mark as billed" }
        should_change("the number of billed time entries", :by => 23) { TimeEntry.billed(true).count }
      end
      
    end

  end

  context 'Logged in as bill' do
    setup do
      login_as(:bill)
    end

    reports = [:user, :activity, :hours]
    reports.each do |report|
      context "on GET to :#{report}" do
        setup { get report }
        should_redirect_to("Time Entries for Bill") { user_time_entries_url(:user_id => users(:bill).id) }
      end
    end
  end

  context "Not logged in" do
    reports = [:user, :activity, :hours]
    reports.each do |report|
      context "on GET to :#{report}" do
        setup { get report }
        should_redirect_to("Login page") { new_user_session_url }
      end
    end    
  end

end