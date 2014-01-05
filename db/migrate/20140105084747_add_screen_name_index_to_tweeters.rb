class AddScreenNameIndexToTweeters < ActiveRecord::Migration
  def change
    add_index :tweeters, :screen_name, unique: true
  end
end
