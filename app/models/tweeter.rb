class Tweeter < ActiveRecord::Base
  attr_accessor :favs_count, :retweets_count, :score

  # Public: Get the favorite tweeter based on the specified count hashes of
  # favorites and retweets.
  #
  # favorite_counts - A hash of the format { screen_name => favorite_count }
  # retweet_counts  - A hash of the format { screen_name => retweet_count }
  #
  # Returns a Tweeter.
  def self.favorite_tweeter(favorite_counts, retweet_counts)
    # Count each fav as 1 point
    scores = Hash[favorite_counts]
    scores.default = 0

    # Count each RT as 1.5 points
    retweet_counts.each { |screen_name, rts| scores[screen_name] += (rts * 1.5) }

    winning_screen_name, winning_score = scores.max_by { |_, score| score }

    Tweeter.new(
      :screen_name    => winning_screen_name,
      :favs_count     => Hash[favorite_counts][winning_screen_name],
      :retweets_count => Hash[retweet_counts][winning_screen_name],
      :score          => winning_score
    )
  end

  # Public: Get an array of [username, fav_count] tuples in descending order by
  # favorite count.
  #
  # cutoff_date - (Time) Oldest allowed tweet date. Tweets that came before this
  #               won't be counted.
  #
  # Returns an Array.
  def most_favorited_tweeters(cutoff_date)
    faved_tweets = TWITTER.favorites(screen_name, :count => 200)
    self.class.screen_name_count(faved_tweets, cutoff_date)
  end

  # Public: Get an array of [username, rt_count] tuples in descending order by
  # retweet count.
  #
  # cutoff_date - (Time) Oldest allowed tweet date. Tweets that came before this
  #               won't be counted.
  #
  # Returns an Array.
  def most_retweeted_tweeters(cutoff_date)
    retweets = TWITTER.retweeted_by_user(screen_name, :count => 200)
    self.class.screen_name_count(retweets, cutoff_date)
  end

  def to_param
    screen_name
  end

  private

  # Internal: Convert a list of Twitter::Tweets into a list counting the number
  # of times each user appears in the list.
  #
  # The list is in descending order by count.
  #
  # Examples
  #
  #   tweets = TWITTER.retweeted_by_user("jakeboxer")
  #   Tweeter.screen_name_count(tweets)
  #   # => [["justinbieber", 18], ["jessicard", 15], ["scottjg", 2]]
  #
  # tweets      - List of tweets to count.
  # cutoff_date - (Time) Oldest allowed tweet date. Tweets that came before this
  #               won't be counted.
  #
  # Returns an Array of [screen_name, count] tuples.
  def self.screen_name_count(tweets, cutoff_date)
    counts = Hash.new(0)

    tweets.each do |tweet|
      # Don't count this tweet if it happened before the cutoff date.
      next if tweet.created_at < cutoff_date

      # We only care about the authors of original tweets.
      original_tweet = tweet.retweet? ? tweet.retweeted_status : tweet

      counts[original_tweet.user.screen_name] += 1
    end

    counts.sort_by { |_, count| -count }
  end
end
