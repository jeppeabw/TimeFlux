require 'test_helper'

class MonthListingsControllerTest < ActionController::TestCase

  setup do
    @date = Date.new(2009, 6, 22) # monday in week 26, 2009
    Date.stubs(:today).returns(@date)
  end

  context "Logged in as user Bob" do
    setup do
      login_as(:bob)
    end
      
    context "on GET to :show for listing report" do
      setup { get :show, :user_id => users(:bob).id }
      
      should_render_template :show
      should_respond_with :success
      should_assign_to :user, :beginning_of_month, :end_of_month, :time_entries
    end
    
    context "on GET to :show for listing report in pdf format" do
      setup { get :show, :user_id => users(:bob).id, :format => "pdf" }
      
      should_render_template "month_listings/show.pdf.prawn"
      should_respond_with :success
      should_assign_to :user, :beginning_of_month, :end_of_month, :time_entries
    end
  end

  context "Not logged in" do
    setup { get :show, :user_id => users(:bob).id }
    should_redirect_to("Login page") { new_user_session_url }
  end
  
  context "When logged in as Bill" do 
    
    setup { login_as :bill }
    
    context "a GET request to :show with a different user id" do
      
      setup { get :show, :id => users(:bob).id.to_s }
      
      should_redirect_to("Login page") { new_user_session_url }
      should_set_the_flash_to "You do not have access to this page"
      
    end
    
  end

end