class UserReport < Report
  attr_reader :day, :months, :years, :expected, :users, :totals

  def at_end_of_month
    @day.at_end_of_month
  end

  def month
    @day.month
  end

  def show
    setup_calendar

    @users = User.active.paginate :page => @params[:page] || 1, :per_page => 30, :order => 'lastname'

    first_day = @day.at_beginning_of_month
    last_day = @day.at_end_of_month
    first_week = [first_day,first_day.end_of_week]
    last_week = [last_day.beginning_of_week,last_day]

    date_iterator = first_day.end_of_week + 1 #monday in the second week of the month
    middle_weeks = []
    until date_iterator == last_day.beginning_of_week
      middle_weeks << [date_iterator, date_iterator + 6]
      date_iterator += 7
    end

    @weeks = [first_week] + middle_weeks + [last_week]

    @expected = @weeks.collect do |from, to|
      Holiday.expected_hours_between( from,to )
    end

    @totals = @weeks.collect do |day, to|
      TimeEntry.between(day, to).sum(:hours)
    end
  end
  
end
