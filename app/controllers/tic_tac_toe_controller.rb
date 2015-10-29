class TicTacToeController < ApplicationController
  def play
    @config = params[:config] || Array.new(9) { "" }
  end

  def make_move
    config = params[:config]
    coordinates = params[:coordinates].map(&:to_i)
    board = TicTacToe::Board.new(size: 3, config: config.map { |mark| mark == "" ? nil : mark.to_sym })

    if board.blank?(coordinates)
      config[coordinates_to_flat_index(coordinates, 3)] = "x"
      board = board.mark_cell(:x, *coordinates)
    else
      flash.alert = "Cannot alter a marked space - please select an empty space to make your move."
    end

    if board.has_winning_line?
      redirect_to tic_tac_toe_game_over_path(message: "Player won!")
    elsif board.all_marked?
      redirect_to tic_tac_toe_game_over_path(message: "The game ended in a draw.")
    else
      computer_player = TicTacToe::ComputerPlayer.new(player_mark: :o, opponent_mark: :x)
      computer_move_coordinates = computer_player.move(TicTacToe::Game.new(board: board))
      config[coordinates_to_flat_index(computer_move_coordinates, 3)] = "o"
      board = board.mark_cell(:o, *computer_move_coordinates)

      if board.has_winning_line?
        redirect_to tic_tac_toe_game_over_path(message: "Computer won... D:")
      else
        redirect_to root_path(config: config)
      end
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
