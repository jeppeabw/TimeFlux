# To change this template, choose Tools | Templates
# and open the template in the editor.

module ReportingTmp


  private

  def setup_calender
    if params[:calender]
      year = params[:calender]["date(1i)"].to_i
      month = params[:calender]["date(2i)"].to_i
    else
      year = params[:year].to_i if params[:year] && params[:year] != ""
      month = params[:month].to_i if params[:month] && params[:month] != ""
    end
    relevant_date = Date.today - 7
    @day = Date.new(year ? year : relevant_date.year, month ? month : relevant_date.month, 1)

    @years = (2007..Date.today.year).to_a.reverse
    @months = []
    @month_names = %w{ January Febrary March April May June July August September October November December}
    @month_names.each_with_index { |name, i| @months << [ i+1, name ] }
  end

  # Sets the date to the last in month if the supplied date is higher.
  # Example 2009,2,31 returns Date.civil(2009,2,28)
  #
  def set_date(year, month, day)
    puts "Setting date: #{year}-#{month}-#{day}"
    max_day = Date.civil(year,month,1).at_end_of_month.mday
    Date.civil(year,month, day > max_day ? max_day : day)
  end

  # Finds the instance of class <tt>symbol<tt>, with the id of params[symbol]
  # Example for symbol :user -> returns User.find(params[:user]) or nil if param or user does not exsist
  #
  def param_instance(symbol)
    Kernel.const_get(symbol.to_s.camelcase).find(params[symbol])  if params[symbol] && params[symbol] != ""
  end

  # Sets prawn arguments, and disables cache for explorer (prior to v. 6.0)
  # so that it too can download pdf documents
  def initialize_pdf_download(filename)
    prawnto :prawn => prawn_params, :filename=> filename
    #if request.env["HTTP_USER_AGENT"] =~ /MSIE/
    #  response.headers['Cache-Control'] = ""
    #end
  end

  def project_hours_for_customers(customers)
    project_hours = []
    customers.each do |customer|
      customer.projects.each do |project|
        project_hours << [customer,project, TimeEntry.between(@from_day, @to_day).for_project(project).sum(:hours), customer.billable]
      end
    end
    project_hours
  end

  # Takes a list of customers, and a date representing a month
  # Returns 1. a list in the format ["what to display", "what to select", empty?, has_hours?]
  #         2. a list of customers that doesnt start on any of the letters between A and Z.
  def extract_customers_by_letter( customers, day )
    letters = []
    ('A'..'Z').each do |letter|
      customers_on_letter = customers.select { |customer| customer.name.index(letter) == 0  }
      customers -= customers_on_letter
      if customers_on_letter
        unbilled_hours = customers_on_letter.any? {|customer| customer.has_unbilled_hours_between(day,day.at_end_of_month) }
      end
      letters << [letter, letter, customers_on_letter.empty?, unbilled_hours ]
    end

    other_hours = customers.any? {|customer| customer.has_unbilled_hours_between(day,day.at_end_of_month) }
    other = ['Other', '#', customers.empty?, other_hours ]
    all = ['All', '*', false, letters.any?{|letter| letter[3] == true} || other[3] == true ]

    return [all] + letters + [other], customers
  end

  # Prawnto arguments for creating a plain A4 page with sensible margins
  #
  def prawn_params
    {
      :page_size => 'A4',
      :left_margin => 50,
      :right_margin => 50,
      :top_margin => 24,
      :bottom_margin => 24 }
  end

    
end
