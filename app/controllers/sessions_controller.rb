class SessionsController < ApplicationController
  def new
  end

  def create
    if params[:provider].present? && omniauth = request.env["omniauth.auth"]
      logger.debug "Omniauth Paypal: #{omniauth.inspect}"
      user = User.find_or_create_from_omniauth(omniauth)
    else
      user = User.find_by_email(params[:email])
      user = nil unless user && user.authenticate(params[:password])
    end
    if user
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
      redirect_to root_url
    else
      flash.now.alert = "Email or password is invalid."
      render :new
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to root_url, notice: "You have logged out."
  end
end
