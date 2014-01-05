class SessionsController < ApplicationController
  def create
    Tweeter.find_or_create_by!(:screen_name => auth_hash[:info][:nickname])
    redirect_to "/"
  end
end
