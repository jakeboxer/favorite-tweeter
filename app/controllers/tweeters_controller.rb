class TweetersController < ApplicationController
  def create
    redirect_to "/@#{params[:tweeter][:screen_name].strip}"
  end

  def index
    @tweeter = Tweeter.new
  end

  def show
    if user_signed_in?
      @tweeter       = Tweeter.new(:screen_name => params[:screen_name].strip)
      twitter_client = current_user.twitter_rest_client
      cutoff_date    = 2.months.ago

      @most_favorited_tweeters = @tweeter.most_favorited_tweeters(cutoff_date, twitter_client)
      @most_retweeted_tweeters = @tweeter.most_retweeted_tweeters(cutoff_date, twitter_client)
      @favorite_tweeter        = Tweeter.favorite_tweeter(@most_favorited_tweeters, @most_retweeted_tweeters)
    else
      session[:return_to] = request.fullpath
      redirect_to "/auth/twitter"
    end
  end
end
