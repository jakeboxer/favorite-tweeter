class CalculateStatsJob
  @queue = :stats

  def self.perform(tweeter_id, requester_id)
    tweeters  = Tweeter.find(tweeter_id, requester_id)
    tweeter   = tweeters.find { |t| t.id == tweeter_id }
    requester = tweeters.find { |t| t.id == requester_id }

    tweeter.calculate_stats!(requester)
  end
end
