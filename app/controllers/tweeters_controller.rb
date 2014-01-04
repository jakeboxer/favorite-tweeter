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

    # Hash of username => count, where count is the number of tweets by username
    # that were faved by the specified user.
    fav_counts       = Hash.new(0)

    # Hash of username => count, where count is the number of tweets by username
    # that were RTed by the specified user.
    rt_counts        = Hash.new(0)

    faved_tweets.each do |tweet|
      break unless tweet.created_at >= oldest_tweet_time

      fav_counts[tweet.user.screen_name] += 1
    end

    retweets.each do |tweet|
      break unless tweet.created_at >= oldest_tweet_time

      rt_counts[tweet.retweeted_status.user.screen_name] += 1
    end

    @tweeters_by_favs        = fav_counts.sort_by { |_, count| -count }
    @tweeters_by_rts         = rt_counts.sort_by { |_, count| -count }
  end
end
