class TicTacToeController < ApplicationController
  def play
    @config = params[:config] || Array.new(9) { "" }
    @current_player = params[:current_player] || "x"
  end

  def make_move
    config = params[:config]
    current_player = params[:current_player]
    coordinates = params[:coordinates].map(&:to_i)
    board = TicTacToe::Board.new(size: 3, config: config.map { |mark| mark == "" ? nil : mark.to_sym })

    if board.blank?(coordinates)
      config[coordinates_to_flat_index(coordinates, 3)] = current_player
      board = board.mark_cell(current_player.to_sym, *coordinates)
      current_player = toggle_player(current_player)
    else
      flash.alert = "Cannot alter a marked space - please select an empty space to make your move."
    end

    if board.has_winning_line?
      redirect_to tic_tac_toe_game_over_path(message: "Player #{board.read_cell(*coordinates)} won!")
    elsif board.all_marked?
      redirect_to tic_tac_toe_game_over_path(message: "The game ended in a draw.")
    else
      redirect_to root_path(config: config, current_player: current_player)
    end
  end

  def game_over
  end

  private

  def toggle_player(current_player)
    (["x", "o"] - [current_player]).pop
  end

  def coordinates_to_flat_index(coordinates, board_size)
    row, col = coordinates

    row * board_size + col
  end
end
