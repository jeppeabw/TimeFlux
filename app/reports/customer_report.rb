class CustomerReport < Report

  def billable_project_hours
    @billable_project_hours
  end

  def internal_project_hours
    @internal_project_hours
  end

  def project
    @project
  end

  def user_activity_hours
    @user_activity_hours
  end

  def show 
    setup_calendar
    parse_search_params
    @billable_project_hours = project_hours_for_customers(Customer.billable(true))
    @internal_project_hours = project_hours_for_customers(Customer.billable(false))
  end
  
  def show_projects
    setup_calendar
    parse_search_params
    @user_activity_hours = []
    @project.activities.each do |activity|
      User.all.each do |user|
        hours = TimeEntry.between(@from_day, @to_day).for_user(user).for_activity(activity).sum(:hours)
        @user_activity_hours << [user,activity, hours] if hours > 0
      end
    end
  end

end
