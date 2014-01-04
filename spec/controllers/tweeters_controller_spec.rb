require 'spec_helper'

describe TweetersController do
  describe "GET 'index'" do
    it "returns http success" do
      get "index"
      expect(response).to be_success
    end
  end

  describe "GET 'show'" do
    let(:tweeter) { create(:tweeter) }

    it "returns http success if the user exists" do
      get "show", :screen_name => tweeter.screen_name
      expect(response).to be_success
    end

    it "returns http not found if the user doesn't exist" do
      get "show", :screen_name => tweeter.screen_name + "nonexist"
      expect(response).to be_not_found
    end
  end

  describe "POST 'create'" do
    let(:screen_name) { "jakeboxer" }

    it "redirects to tweeters#show" do
      post "create", :tweeter => { :screen_name => screen_name }
      expect(response).to redirect_to(tweeter_url(assigns(:tweeter)))
    end

    it "creates a new tweeter if none exists" do
      expect do
        post "create", :tweeter => { :screen_name => screen_name }
      end.to change(Tweeter, :count).by(1)
    end

    it "doesn't a new tweeter if one exists with the same screen name" do
      create(:tweeter, :screen_name => screen_name)

      expect do
        post "create", :tweeter => { :screen_name => screen_name }
      end.not_to change(Tweeter, :count)
    end
  end
end
