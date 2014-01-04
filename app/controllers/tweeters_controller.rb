class TweetersController < ApplicationController
  def create
    @tweeter = Tweeter.find_or_create_by(:screen_name => params[:tweeter][:screen_name])

    redirect_to @tweeter
  end

  def index
    @tweeter = Tweeter.new
  end

  def show
    cutoff_date = 3.months.ago
    @tweeter    = Tweeter.find_by!(:screen_name => params[:screen_name].strip)

    @most_favorited_tweeters = @tweeter.most_favorited_tweeters(cutoff_date)
    @most_retweeted_tweeters = @tweeter.most_retweeted_tweeters(cutoff_date)
    @favorite_tweeter        = Tweeter.favorite_tweeter(@most_favorited_tweeters, @most_retweeted_tweeters)
  end
end
