class TweetersController < ApplicationController
  def create
    @tweeter = Tweeter.find_or_create_by(:screen_name => params[:tweeter][:screen_name])

    redirect_to @tweeter
  end

  def index
    @tweeter = Tweeter.new
  end

  def show
    screen_name = params[:screen_name].strip
    @tweeter    = Tweeter.find_by!(:screen_name => screen_name)

    cutoff_date              = 3.months.ago
    @most_favorited_tweeters = @tweeter.most_favorited_tweeters(cutoff_date)
    @most_retweeted_tweeters = @tweeter.most_retweeted_tweeters(cutoff_date)
  end
end
