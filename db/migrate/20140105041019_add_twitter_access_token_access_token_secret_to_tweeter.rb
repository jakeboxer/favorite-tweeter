class AddTwitterAccessTokenAccessTokenSecretToTweeter < ActiveRecord::Migration
  def change
    add_column :tweeters, :access_token, :string
    add_column :tweeters, :access_token_secret, :string
  end
end
