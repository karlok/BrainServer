defmodule BrainServerWeb.GameController do
    use BrainServerWeb, :controller
    alias BrainServer.Game
  
    def create_game(conn, %{"game_id" => game_id, "player1" => player1}) do
      Game.create_game(game_id, player1)
      json(conn, %{message: "Game created", game_id: game_id})
    end
  
    def join_game(conn, %{"game_id" => game_id, "player2" => player2}) do
      Game.join_game(game_id, player2)
      json(conn, %{message: "Game joined"})
    end
  
    def submit_turn(conn, %{"game_id" => game_id, "player" => player, "answer" => answer, "time" => time}) do
      Game.submit_turn(game_id, player, answer, time)
      json(conn, %{message: "Turn submitted"})
    end
  
    def get_game(conn, %{"game_id" => game_id}) do
      game = Game.get_game(game_id)
      json(conn, game)
    end
  end