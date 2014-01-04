class TweetersController < ApplicationController
  def create
    @tweeter = Tweeter.find_or_create_by(:screen_name => params[:tweeter][:screen_name])

    redirect_to @tweeter
  end

  def index
    @tweeter = Tweeter.new
  end

  def show
    @tweeter = Tweeter.find_by!(:screen_name => params[:screen_name])
    @tweets = TWITTER.user_timeline(@tweeter.screen_name)
  end
end
