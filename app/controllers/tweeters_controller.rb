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
      @tweeter = Tweeter.find_by(:screen_name => params[:screen_name].strip)

      twitter_client = TWITTER

      @most_favorited_tweeters = @tweeter.most_favorited_tweeters(cutoff_date, twitter_client)
      @most_retweeted_tweeters = @tweeter.most_retweeted_tweeters(cutoff_date, twitter_client)
      @favorite_tweeter        = Tweeter.favorite_tweeter(@most_favorited_tweeters, @most_retweeted_tweeters)
    else
      redirect_to "/auth/twitter"
    end
  end
end
