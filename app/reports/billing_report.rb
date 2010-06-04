# To change this template, choose Tools | Templates
# and open the template in the editor.

class BillingReport

  include Reporting
  
  def month
    @day.month
  end

  def show(params)
    setup_calender(params)
    params[:letter] ||= "A"

    billable_customers = Customer.billable(true).to_a
    @letters, @other = extract_customers_by_letter( billable_customers, @day )

    @customers = case params[:letter]
    when '*' then
      Customer.billable(true).paginate :page => params[:page] || 1, :per_page => 100, :order => 'name'
    when '#' then
      @other.paginate :page => params[:page] || 1, :per_page => 25, :order => 'name'
    else
      Customer.billable(true).on_letter(params[:letter]).paginate :page => params[:page] || 1, :per_page => 25, :order => 'name'
    end
  end
end
