require "rails_helper"

RSpec.describe TicTacToeController, :type => :controller do
  let(:_) { TicTacToeController::BLANK_MARK_STRING }
  let(:x) { TicTacToeController::X_MARK }
  let(:o) { TicTacToeController::O_MARK }

  describe "#show_board" do
    it "renders show_board template" do
      get :show_board

      expect(response).to render_template("show_board")
    end

    it "creates a BoardPresenter" do
      get :show_board

      expect(assigns[:board]).to be_a BoardPresenter
    end

    context "when given a board configuration" do
      it "creates a board that is marked according to the given configuration" do
        get :show_board, {:board_configuration => [x, x, x, o, o, o, _, _, _]}

        expect(assigns[:board].read_space([0, 0])).to eq x
        expect(assigns[:board].read_space([0, 1])).to eq x
        expect(assigns[:board].read_space([0, 2])).to eq x
        expect(assigns[:board].read_space([1, 0])).to eq o
        expect(assigns[:board].read_space([1, 1])).to eq o
        expect(assigns[:board].read_space([1, 2])).to eq o
        expect(assigns[:board].read_space([2, 0])).to eq _
        expect(assigns[:board].read_space([2, 1])).to eq _
        expect(assigns[:board].read_space([2, 2])).to eq _
      end
    end

    context "when not given a board configuration" do
      it "creates a blank board" do
        get :show_board

        expect(assigns[:board].all_blank?).to be true
      end
    end
  end

  describe "#make_move" do
    it "creates a board that has marks according to the given configuration" do
      get :show_board, {:board_configuration => [x, x, x, o, o, o, _, _, _], :coordinates => [0, 0]}

      expect(assigns[:board].read_space([0, 0])).to eq x
      expect(assigns[:board].read_space([0, 1])).to eq x
      expect(assigns[:board].read_space([0, 2])).to eq x
      expect(assigns[:board].read_space([1, 0])).to eq o
      expect(assigns[:board].read_space([1, 1])).to eq o
      expect(assigns[:board].read_space([1, 2])).to eq o
    end

    context "when board is blank at the given coordinates" do
      it "marks the board with an x at the given coordinates" do
        coordinates = [0, 0]
        get :make_move, {:board_configuration => [_, _, _, _, _, _, _, _, _], :coordinates => coordinates}

        expect(assigns[:board].marked?(coordinates)).to be true
        expect(assigns[:board].read_space(coordinates)).to eq x
      end

      it "marks the board with a move chosen by the computer player" do
        get :make_move, {:board_configuration => [_, _, _, _, _, _, _, _, _], :coordinates => [0, 0]}
        marks = assigns[:board].all_coordinates.map { |coordinates| assigns[:board].read_space(coordinates) }

        expect(assigns[:board].blank_space_coordinates.count).to eq 7
        expect(marks).to include o
      end
    end

    context "when board is not blank at the given coordinates" do
      it "does not mark the board at the given coordinates" do
        coordinates = [0, 0]
        get :make_move, {:board_configuration => [o, _, _, _, _, _, _, _, _], :coordinates => coordinates}

        expect(assigns[:board].read_space(coordinates)).not_to eq x
        expect(assigns[:board].read_space(coordinates)).to eq o
      end

      it "creates an alert that the board could not be marked via the flash" do
        coordinates = [0, 0]
        get :make_move, {:board_configuration => [o, _, _, _, _, _, _, _, _], :coordinates => coordinates}

        expect(flash[:alert]).to eq "Cannot alter a marked space - please select an empty space to make your move."
      end
    end

    context "when a winning move is made" do
      it "redirects to a game over page telling the player they won" do
        get :make_move, {:board_configuration => [_, x, x, o, o, _, _, _, _], :coordinates => [0, 0]}

        expect(response).to redirect_to tic_tac_toe_game_over_path(:message => "Player x won!")
      end
    end

    context "when the board is filled with no winner" do
      it "redirects to a game over page announcing the game ended in a draw" do
        get :make_move, {:board_configuration => [_, o, x, x, o, x, o, x, _], :coordinates => [0, 0]}

        expect(response).to redirect_to tic_tac_toe_game_over_path(:message => "The game ended in a draw.")
      end
    end
  end
end