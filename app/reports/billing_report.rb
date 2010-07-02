class BillingReport < Report
  attr_reader :letters, :customers

  def show
    setup_calendar
    @params[:letter] ||= "A"

    billable_customers = Customer.billable(true).to_a
    @letters, @other = extract_customers_by_letter( billable_customers, @day )

    @customers = case @params[:letter]
    when '*' then
      Customer.billable(true).paginate :page => @params[:page] || 1, :per_page => 100, :order => 'name'
    when '#' then
      @other.paginate :page => @params[:page] || 1, :per_page => 25, :order => 'name'
    else
      Customer.billable(true).on_letter(@params[:letter]).paginate :page => @params[:page] || 1, :per_page => 25, :order => 'name'
    end
  end

  def setup_calendar_for_billing
    setup_calendar
  end


end
