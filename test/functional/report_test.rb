require 'test_helper'

class ReportTest < Test::Unit::TestCase #ActiveSupport::TestCase
  include Reporting

  def setup
    params = {:year => "2011", :month => "4"}
    @report = Report.new(params)
  end

  context "setup calendar" do
    should "return months" do
      month_names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
      month = @report.setup_calendar
      assert_equal month_names, month
    end

    should "return years" do
      years_list = [2010, 2009, 2008, 2007]
      @report.setup_calendar
      assert_equal years_list, @report.years
    end

    should "return day" do
      @report.setup_calendar
      first_of_april_2011 = Date.new(2011, 4, 1)
      assert_equal first_of_april_2011, @report.day
    end

  end

  context "set project hours for customers" do
    should "return project hours" do
      cust1 = Customer.new

      cust2 = Customer.new
      customer_array = [cust1, cust2]
      params = {}
      @report = CustomerReport.new(params)
      @report.project_hours_for_customers(customer_array)
      asserted_billable_project_hours = []
      assert_equal asserted_project_hours, @report.billable_project_hours
    end
  end

end
