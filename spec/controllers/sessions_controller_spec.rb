require 'spec_helper'

describe SessionsController do

  describe "GET 'create'" do
    it "returns http success" do
      get 'create'
      expect(response).to be_success
    end
  end

end
