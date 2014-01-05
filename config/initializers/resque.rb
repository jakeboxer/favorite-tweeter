Resque.redis = ENV["FAVORITE_TWEETER_REDIS"] if ENV["FAVORITE_TWEETER_REDIS"]
Resque.redis.namespace = "resque:FavoriteTweeter"
