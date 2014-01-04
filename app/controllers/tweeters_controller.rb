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

    faved_tweets      = TWITTER.favorites(@tweeter.screen_name, :count => 100)
    retweets          = TWITTER.retweeted_by_user(@tweeter.screen_name, :count => 200)
    oldest_tweet_time = 3.months.ago

    faved_users     = Hash.new(0)
    retweeted_users = Hash.new(0)

    faved_tweets.each do |tweet|
      break unless tweet.created_at >= oldest_tweet_time

      faved_users[tweet.user.screen_name] += 1

      if tweet.retweet?
        faved_users[tweet.retweeted_status.user.screen_name] += 1
      end
    end

    retweets.each do |tweet|
      break unless tweet.created_at >= oldest_tweet_time

      retweeted_users[tweet.retweeted_status.user.screen_name] += 1
    end

    @tweeters_by_favs = faved_users.sort_by { |_, favs| -favs }
    @tweeters_by_rts  = retweeted_users.sort_by { |_, rts| -rts }
  end
end
