Rails.application.routes.draw do
  root 'tic_tac_toe#index'
  get 'tic_tac_toe/show_board'
  post 'tic_tac_toe/make_move'
  get 'tic_tac_toe/game_over'
end
