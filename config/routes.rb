FavoriteTweeter::Application.routes.draw do
  resources :tweeters, :only => :index

  root :to => "tweeters#index"
end
