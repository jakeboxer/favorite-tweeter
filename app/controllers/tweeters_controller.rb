class TweetersController < ApplicationController
  def create
    redirect_to "/@#{params[:tweeter][:screen_name].strip}"
  end

  def index
    @tweeter = Tweeter.new
  end

  def show
    cutoff_date = 2.months.ago

    if user_signed_in?
      @tweeter = Tweeter.new(:screen_name => params[:screen_name].strip)

      twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
        config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
        config.access_token        = current_user.access_token
        config.access_token_secret = current_user.access_token_secret
      end

      @most_favorited_tweeters = @tweeter.most_favorited_tweeters(cutoff_date, twitter_client)
      @most_retweeted_tweeters = @tweeter.most_retweeted_tweeters(cutoff_date, twitter_client)
      @favorite_tweeter        = Tweeter.favorite_tweeter(@most_favorited_tweeters, @most_retweeted_tweeters)
    else
      redirect_to "/auth/twitter"
    end
  end
end
