class TicTacToeController < ApplicationController
  BLANK_MARK_STRING = "  "
  X_MARK = "x"
  O_MARK = "o"

  def show_board
    board_configuration = params[:board_configuration] || blank_board_configuration
    @board = BoardPresenter.new(new_board(board_configuration))
  end

  def make_move
    @board = new_board(params[:board_configuration])
    coordinates = params[:coordinates].map(&:to_i)

    if @board.marked?(coordinates)
      flash.alert = "Cannot alter a marked space - please select an empty space to make your move."
      redirect_to tic_tac_toe_show_board_path(board_configuration: board_configuration)
      return
    else
      make_human_move(coordinates)
    end
    handle_game_over(X_MARK) && return if game_over?

    make_computer_move
    handle_game_over(O_MARK) && return if game_over?

    redirect_to tic_tac_toe_show_board_path(board_configuration: board_configuration)
  end

  private

  def make_human_move(coordinates)
    @board = @board.mark_space(X_MARK, coordinates)
  end

  def make_computer_move
    computer_player = new_computer_player(O_MARK, X_MARK)
    computer_move_coordinates = computer_player.move(TicTacToe::Game.new(board: @board))
    @board = @board.mark_space(O_MARK, computer_move_coordinates)
  end

  def new_computer_player(player_mark, opponent_mark)
    TicTacToe::ComputerPlayer.new(player_mark: player_mark, opponent_mark: opponent_mark)
  end

  def game_over?
    @board.has_winning_line? || @board.all_marked?
  end

  def handle_game_over(current_player)
    if @board.has_winning_line?
      redirect_to tic_tac_toe_game_over_path(message: "Player #{current_player} won!")
    else
      redirect_to tic_tac_toe_game_over_path(message: "The game ended in a draw.")
    end
  end

  def board_configuration
    @board.all_coordinates.map do |coordinates|
      mark = @board.read_space(coordinates)
      mark == TicTacToe::Board::BLANK_MARK ? BLANK_MARK_STRING : mark
    end
  end

  def blank_board_configuration
    Array.new(9) { BLANK_MARK_STRING }
  end

  def new_board(marked_spaces)
    TicTacToe::Board.new(marked_spaces: replace_blank_mark_strings(marked_spaces))
  end

  def replace_blank_mark_strings(marked_spaces)
    marked_spaces.map { |mark| mark == BLANK_MARK_STRING ? TicTacToe::Board::BLANK_MARK : mark }
  end
end

class BoardPresenter
  def initialize(board)
    @board = board
  end

  def read_space(coordinates)
    mark = @board.read_space(coordinates)
    mark == TicTacToe::Board::BLANK_MARK ? TicTacToeController::BLANK_MARK_STRING : mark
  end

  def all_coordinates
    @board.all_coordinates
  end

  def all_blank?
    @board.all_blank?
  end

  def configuration
    all_coordinates.map { |coordinates| read_space(coordinates) }
  end
end
