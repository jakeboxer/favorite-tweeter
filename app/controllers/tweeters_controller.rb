class TweetersController < ApplicationController
  def create
    redirect_to "/@#{params[:tweeter][:screen_name].strip}"
  end

  def index
    @tweeter = Tweeter.new
  end

  def show
    if user_signed_in?
      @tweeter = Tweeter.new(:screen_name => params[:screen_name].strip)
      @tweeter.calculate_stats!
    else
      session[:return_to] = request.fullpath
      redirect_to "/auth/twitter"
    end
  end
end
