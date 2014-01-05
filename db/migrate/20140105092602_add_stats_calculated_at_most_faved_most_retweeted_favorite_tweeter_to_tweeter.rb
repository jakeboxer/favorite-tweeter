class AddStatsCalculatedAtMostFavedMostRetweetedFavoriteTweeterToTweeter < ActiveRecord::Migration
  def change
    add_column :tweeters, :stats_calculated_at, :datetime
    add_column :tweeters, :most_faved, :text
    add_column :tweeters, :most_retweeted, :text
    add_column :tweeters, :favorite_tweeter, :text
  end
end
