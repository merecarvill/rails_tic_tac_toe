require "rails_helper"

RSpec.describe TicTacToeController, :type => :controller do
  describe "play" do
    it "works" do
      get :play
      expect(response.status).to eq(200)
    end
  end

  describe "make_move" do
    it "marks a board when space is blank" do
      config = Array.new(9) { "" }
      post :make_move, {coordinates: ["0", "0"], config: config, current_player: "x"}
      config[0] = "x"

      expect(response).to redirect_to root_path(config: config, current_player: "o")
    end

    it "does not mark a board when space is not blank" do
      config = Array.new(9) { "" }
      config[0] = "x"
      post :make_move, {coordinates: ["0", "0"], config: config, current_player: "o"}

      expect(response).to redirect_to root_path(config: config, current_player: "o")
    end

    it "yells at you when marking a board and designated space is not blank" do
      config = Array.new(9) { "" }
      config[0] = "x"
      post :make_move, {coordinates: ["0", "0"], config: config, current_player: "o"}

      expect(flash[:alert]).to be_present
    end

    it "tells you when a player has won" do
      config = ["", "x", "x", "", "", "", "", "", ""]
      post :make_move, {coordinates: ["0", "0"], config: config, current_player: "x"}

      expect(response).to redirect_to tic_tac_toe_game_over_path(message: "Player x won!")
    end

    it "tells you when the game ends in a draw" do
      config = ["", "x", "o", "o", "o", "x", "x", "o", "x"]
      post :make_move, {coordinates: ["0", "0"], config: config, current_player: "x"}

      expect(response).to redirect_to tic_tac_toe_game_over_path(message: "The game ended in a draw.")
    end
  end
end