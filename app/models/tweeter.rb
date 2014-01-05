class Tweeter < ActiveRecord::Base
  serialize :favorite_tweeter, Hash
  serialize :most_faved, Array
  serialize :most_retweeted, Array

  def calculate_stats(requester)
    if !stats_job_queued? && !stats_calculated_recently?
      Resque.enqueue(CalculateStatsJob, id, requester.id)
      touch(:stats_job_queued_at)
    end
  end

  def calculate_stats!(requester)
    self.stats_job_queued_at = nil
    self.stats_calculated_at = Time.zone.now
    cutoff_date              = stats_calculated_at - 2.months
    twitter_client           = requester.twitter_rest_client

    self.most_faved       = calculate_most_faved(cutoff_date, twitter_client)
    self.most_retweeted   = calculate_most_retweeted(cutoff_date, twitter_client)
    self.favorite_tweeter = calculate_favorite_tweeter

    save!
  end

  def stats_job_queued?
    stats_job_queued_at.present? && stats_job_queued_at > 1.hour.ago
  end

  def stats_calculated_recently?
    stats_calculated_at.present? && stats_calculated_at > 1.day.ago
  end

  def to_param
    screen_name
  end

  # Public: Get a Twitter REST client authenticated with this tweeter.
  #
  # Returns a Twitter::REST::Client.
  def twitter_rest_client
    @twitter_rest_client ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = access_token
      config.access_token_secret = access_token_secret
    end
  end

  private

  # Public: Calculate the favorite tweeter based on favs and retweets.
  #
  # Returns a Hash with the following keys:
  #   :screen_name    => Screen name of the favorite tweeter
  #   :favs_count     => Number of tweets he/she had favorited by the user
  #   :retweets_count => Number of tweets he/she had retweeted by the user
  #   :score          => Number of points he/she got for all favs/RTs
  def calculate_favorite_tweeter
    # Count each fav as 1 point
    scores = Hash[most_faved]
    scores.default = 0

    # Count each RT as 1.5 points
    most_retweeted.each { |screen_name, rts| scores[screen_name] += (rts * 1.5) }

    winning_screen_name, winning_score = scores.max_by { |_, score| score }

    {
      :screen_name    => winning_screen_name,
      :favs_count     => Hash[most_faved][winning_screen_name],
      :retweets_count => Hash[most_retweeted][winning_screen_name],
      :score          => winning_score
    }
  end

  # Public: Calculate an array of [username, fav_count] tuples in descending
  # order by favorite count.
  #
  # cutoff_date    - (Time) Oldest allowed tweet date. Tweets that came before
  #                  this won't be counted.
  # twitter_client - Twitter::REST::Client to use to make API calls.
  #
  # Returns an Array.
  def calculate_most_faved(cutoff_date, twitter_client)
    faved_tweets = load_tweets_up_to(cutoff_date) do |options|
      logger.debug "loading more favs with options = #{options.inspect}"
      twitter_client.favorites(screen_name, options)
    end

    self.class.screen_name_count(faved_tweets)
  end

  # Public: Calculate an array of [username, rt_count] tuples in descending
  # order by retweet count.
  #
  # cutoff_date    - (Time) Oldest allowed tweet date. Tweets that came before
  #                  this won't be counted.
  # twitter_client - Twitter::REST::Client to use to make API calls.
  #
  # Returns an Array.
  def calculate_most_retweeted(cutoff_date, twitter_client)
    retweets = load_tweets_up_to(cutoff_date) do |options|
      logger.debug "loading more retweets with options = #{options.inspect}"
      twitter_client.user_timeline(screen_name, options)
    end.select(&:retweet?)

    self.class.screen_name_count(retweets)
  end

  def load_tweets_up_to(cutoff_date)
    tweets = []

    while tweets.empty? || tweets.last.created_at >= cutoff_date
      options          = { :count => 200 }
      options[:max_id] = tweets.last.id if tweets.present?
      older_tweets     = yield(options)

      logger.debug "loaded #{older_tweets.size} more tweets (last was #{older_tweets.last.created_at})"

      tweets += older_tweets
    end

    tweets.select { |tweet| tweet.created_at >= cutoff_date }.tap do |x|
      logger.debug "done loading. final count is #{x.size}. oldest tweet was #{x.last.created_at}"
    end
  end

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
  #
  # Returns an Array of [screen_name, count] tuples.
  def self.screen_name_count(tweets)
    counts = Hash.new(0)

    tweets.each do |tweet|
      # We only care about the authors of original tweets.
      original_tweet = tweet.retweet? ? tweet.retweeted_status : tweet

      counts[original_tweet.user.screen_name] += 1
    end

    counts.sort_by { |_, count| -count }
  end
end
