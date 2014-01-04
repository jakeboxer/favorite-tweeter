FavoriteTweeter::Application.routes.draw do
  resources :tweeters, :only => [:create, :index]

  get "@:screen_name", :to => "tweeters#show", :as => :tweeter
  root :to => "tweeters#index"
end
