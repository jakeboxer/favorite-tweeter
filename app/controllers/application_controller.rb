class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = Tweeter.find_by(:screen_name => session[:screen_name])
  end
  helper_method :current_user

  def user_signed_in?
    current_user.present?
  end
  helper_method :logged_in?

  private

  def record_not_found
    render :text => "404 Not Found", :status => 404
  end
end
