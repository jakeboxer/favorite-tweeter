class SessionsController < ApplicationController
  def create
    auth_hash = request.env["omniauth.auth"]
    tweeter   = Tweeter.find_or_create_by!(:screen_name => auth_hash[:info][:nickname])

    # Update auth credentials
    tweeter.access_token        = auth_hash[:credentials][:token]
    tweeter.access_token_secret = auth_hash[:credentials][:secret]
    tweeter.save

    session[:screen_name] = tweeter.screen_name

    redirect_to(session.delete(:return_to) || "/")
  end
end
