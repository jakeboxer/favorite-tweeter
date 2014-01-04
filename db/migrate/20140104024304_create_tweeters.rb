class CreateTweeters < ActiveRecord::Migration
  def change
    create_table :tweeters do |t|
      t.string :screen_name

      t.timestamps
    end
  end
end
