Rails.application.config.middleware.use OmniAuth::Builder do
  provider(:twitter, ENV["TWITTER_CONSUMER_KEY"], ENV["TWITTER_CONSUMER_SECRET"],
    :authorize_params => {
      :oauth_callback => "http://localhost:3000/auth/twitter/callback"
    }
  )
end
