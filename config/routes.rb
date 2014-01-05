FavoriteTweeter::Application.routes.draw do
  resources :tweeters, :only => [:create, :index] do
    member do
      get "stats"
    end
  end

  get "/auth/:provider/callback", to: "sessions#create"
  get "@:screen_name", :to => "tweeters#show", :as => :tweeter
  root :to => "tweeters#index"
end
