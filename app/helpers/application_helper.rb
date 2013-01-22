module ApplicationHelper
  def loginout_text
    current_user.present? ? 'Logout' : 'Login'
  end

  def loginout_path
    current_user.present? ? logout_path : login_path
  end
end
