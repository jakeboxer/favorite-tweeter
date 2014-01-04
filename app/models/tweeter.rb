class Tweeter < ActiveRecord::Base
  # Public: Get an array of [username, fav_count] tuples in descending order by
  # favorite count.
  #
  # cutoff_date - (Time) Oldest allowed tweet date. Tweets that came before this
  #               won't be counted.
  #
  # Returns an Array.
  def most_favorited_tweeters(cutoff_date)
    faved_tweets = TWITTER.favorites(screen_name, :count => 100).select do |tweet|
      tweet.created_at >= cutoff_date
    end

    counts = Hash.new(0)
    faved_tweets.each { |t| counts[t.user.screen_name] += 1 }

    sort_count_hash(counts)
  end

  # Public: Get an array of [username, rt_count] tuples in descending order by
  # retweet count.
  #
  # cutoff_date - (Time) Oldest allowed tweet date. Tweets that came before this
  #               won't be counted.
  #
  # Returns an Array.
  def most_retweeted_tweeters(cutoff_date)
    retweets = TWITTER.retweeted_by_user(screen_name, :count => 200).select do |tweet|
      tweet.created_at >= cutoff_date
    end

    counts = Hash.new(0)
    retweets.each { |t| counts[t.retweeted_status.user.screen_name] += 1 }

    sort_count_hash(counts)
  end

  def to_param
    screen_name
  end

  private

  # Internal: Convert a count hash into an array of tuples sorted by value in
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
