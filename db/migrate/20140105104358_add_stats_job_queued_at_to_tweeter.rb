class AddStatsJobQueuedAtToTweeter < ActiveRecord::Migration
  def change
    add_column :tweeters, :stats_job_queued_at, :datetime
  end
end
