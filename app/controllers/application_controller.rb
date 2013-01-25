class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :layout

  private
  def current_user
    @current_user ||= User.find_by_auth_token(cookies[:auth_token]) if cookies[:auth_token]
  end

  def authorize
    redirect_to login_url, alert: "Not authorized" if current_user.nil?
  end

  def layout
    if params[:layout].blank?
      'application'
    else
      layout_name = params[:layout].chomp.strip.downcase
      layout_name == 'false' ? false : layout_name
    end
  end

  helper_method :current_user

end
