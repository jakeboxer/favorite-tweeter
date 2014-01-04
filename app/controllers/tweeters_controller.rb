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

    oldest_tweet_time = 3.months.ago
    faved_tweets      = TWITTER.favorites(screen_name, :count => 100)
    retweets          = TWITTER.retweeted_by_user(screen_name, :count => 200)

    # Cut favs and RTs down to the last 3 months
    [faved_tweets, retweets].each do |tweets|
      tweets.select! { |t| t.created_at >= oldest_tweet_time }
    end

    # Hash of username => count, where count is the number of tweets by username
    # that were faved by the specified user.
    fav_counts = Hash.new(0)

    # Hash of username => count, where count is the number of tweets by username
    # that were RTed by the specified user.
    rt_counts  = Hash.new(0)

    # Record the user counts for favs and RTs
    faved_tweets.each { |t| fav_counts[t.user.screen_name] += 1 }
    retweets.each     { |t| rt_counts[t.retweeted_status.user.screen_name] += 1 }

    # Sort tweeters by most -> least favs and RTs
    @tweeters_by_favs = sort_count_hash(fav_counts)
    @tweeters_by_rts  = sort_count_hash(rt_counts)
  end

  private

  # Private: Convert a count hash into an array of tuples sorted by value in
  # descending order.
  #
  # Ex:
  #
  #   fav_counts = {
  #     "user1" => 26,
  #     "user2" => 29,
  #     "user3" => 25
  #   }
  #   sort_hash_count(fav_counts)
  #   # => [["user2", 29], ["user1", 26], ["user3", 25]]
  #
  # count_hash - A hash of format { key1 => count1, key2 => count2 }.
  #
  # Returns an array of format [[key1, count1], [key2, count2]].
  def sort_count_hash(count_hash)
    count_hash.sort_by { |_, count| -count }
  end
end
