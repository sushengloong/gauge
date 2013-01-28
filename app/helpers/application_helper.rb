module ApplicationHelper
  def days_left date=Date.today
    diff = (date - Date.today).to_i
    diff <= 0 ? 'Due' : "#{pluralize(diff, 'day')} left"
  end

  def top_gauge_img_link i
    placeholder = 'http://placehold.it/160x100'
    if current_user
      top_goals = current_user.top_goals
      if top_goals.present? && top_goals[i].present?
        top_goals[i].image_url(:thumb)
      else
        placeholder
      end
    else
      placeholder
    end
  end
end
