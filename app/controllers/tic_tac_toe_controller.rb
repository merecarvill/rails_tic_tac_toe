class TicTacToeController < ApplicationController
  def play
    TicTacToe::Board.new(size: 3)
  end
end
