FavoriteTweeter::Application.routes.draw do
  resources :tweeters, :only => [:create, :index, :show]

  root :to => "tweeters#index"
end
