class TicTacToeController < ApplicationController
  BLANK_MARK_STRING = "  "

  def index
  end

  def show_board
    @board_configuration = params[:board_configuration] || Array.new(9) { BLANK_MARK_STRING }
    @current_player = params[:current_player] || :x
  end

  def make_move
    @board = new_board(3, params[:board_configuration])
    coordinates = params[:coordinates].map(&:to_i)
    current_player = params[:current_player].to_sym

    make_human_move_at(coordinates)
    handle_game_over(current_player) && return if game_over?

    make_computer_move
    handle_game_over(:o) && return if game_over?

    redirect_to tic_tac_toe_show_board_path(board_configuration: board_configuration,
                                            current_player: current_player)
  end

  def game_over
    @current_player = params[:current_player]
  end

  private

  def make_human_move_at(coordinates)
    if @board.blank?(coordinates)
      @board = @board.mark_cell(:x, *coordinates)
    else
      flash.alert = "Cannot alter a marked space - please select an empty space to make your move."
    end
  end

  def make_computer_move
    computer_player = new_computer_player(:o, :x)
    computer_move_coordinates = computer_player.move(TicTacToe::Game.new(board: @board))
    @board = @board.mark_cell(:o, *computer_move_coordinates)
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
      mark = @board.read_cell(*coordinates)
      mark.nil? ? BLANK_MARK_STRING : mark
    end
  end

  def new_board(size, board_configuration)
    TicTacToe::Board.new(size: size, config: configuration_to_sym(board_configuration))
  end

  def configuration_to_sym(board_configuration)
    board_configuration.map do |mark|
      mark == BLANK_MARK_STRING ? nil : mark.to_sym
    end
  end

  def toggle_player(current_player)
    ([:x, :o] - [current_player]).pop
  end
end
