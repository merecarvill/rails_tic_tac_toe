require "rails_helper"

RSpec.describe TicTacToeController, :type => :controller do
  describe "play" do
    it "works" do
      get :play
      expect(response.status).to eq(200)
    end
  end
end