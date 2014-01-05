class TweetersController < ApplicationController
  def create
    redirect_to "/@#{params[:tweeter][:screen_name].strip}"
  end

  def index
    @tweeter = Tweeter.new
  end

  def show
    screen_name = params[:screen_name].strip
    @tweeter    = Tweeter.find_by(:screen_name => screen_name)

    if @tweeter.nil? || @tweeter.calculation_required?
      if user_signed_in?
        @tweeter ||= Tweeter.create(:screen_name => screen_name)
        @tweeter.calculate_stats(current_user)
      else
        session[:return_to] = request.fullpath
        redirect_to "/auth/twitter"
      end
    end
  end
end
