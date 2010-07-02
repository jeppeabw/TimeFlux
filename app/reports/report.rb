# To change this template, choose Tools | Templates
# and open the template in the editor.

class Report
  include Reporting

  attr_reader :day, :weeks, :months, :years

  def initialize(params)
    @params = params
  end

  def month
    @day.month
  end

  def year
    @day.year
  end
end
