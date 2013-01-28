module ApplicationHelper
  def days_left date=Date.today
    diff = (date - Date.today).to_i
    diff <= 0 ? 'Due' : "#{pluralize(diff, 'day')} left"
  end
end
