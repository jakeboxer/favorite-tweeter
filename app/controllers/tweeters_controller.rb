class TweetersController < ApplicationController
  def index
    @tweeter = Tweeter.new
  end
end
