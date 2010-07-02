class SearchView < Report
  attr_reader :from_day, :to_day, :tag_type, :customer, :parameters, :group_by, :time_entries, :project, :status, :user, :tag

  def from_day_month
    @from_day.month
  end

  def from_day_year
    @from_day.year
  end

  def to_day_month
    @to_day.month
  end

  def to_day_year
    @to_day.year
  end

  def show
    setup_calendar
    parse_search_params
    create_search_report
  end

  def prepare_update
    setup_calendar
    parse_search_params
  end

  def create_search_report
    if @params[:customer] && @params[:customer] != ""
      @time_entries = TimeEntry.search(@from_day,@to_day,@customer,@project,@tag,@tag_type,@user,@status).sort
    end
    @group_by = @params[:group_by].to_sym if @params[:group_by] && @params[:group_by] != ""
    @group_by ||= :user
  end

  def mark_time_entries
    setup_calendar
    parse_search_params
    create_search_report

    value = (@params[:value] && @params[:value] == "true")

    if @params[:mark_as] == 'billed'
      TimeEntry.mark_as_billed(@time_entries, value)
    elsif @params[:mark_as] == 'locked'
      TimeEntry.mark_as_locked(@time_entries, value)
    end
  end
end