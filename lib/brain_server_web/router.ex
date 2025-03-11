defmodule BrainServerWeb.Router do
  use BrainServerWeb, :router

  pipeline :api do
    plug :accepts, ["json"] # only allows JSON requests
  end

  scope "/api", BrainServerWeb do
    pipe_through :api


    get "/questions", GameController, :get_all_questions
    get "/question/:game_id", GameController, :get_current_question
    post "/reset_game", GameController, :reset_game

    post "/create_game", GameController, :create_game
    post "/join_game", GameController, :join_game
    post "/submit_turn", GameController, :submit_turn
    get "/game/:game_id", GameController, :get_game
  end
end
