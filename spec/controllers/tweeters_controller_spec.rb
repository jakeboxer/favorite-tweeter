require 'spec_helper'

describe TweetersController do
  describe "GET 'index'" do
    it "returns http success" do
      get "index"
      expect(response).to be_success
    end
  end

  describe "GET 'show'" do
  end

  describe "POST 'create'" do
  end
end
