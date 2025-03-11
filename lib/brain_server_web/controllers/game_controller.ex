defmodule BrainServerWeb.GameController do
    use BrainServerWeb, :controller # imports the Phoenix controller module
    alias BrainServer.Game # imports the Game module from the BrainServer application
    alias GameServer.Questions


    def get_all_questions(conn, _params) do
      json(conn, Questions.all_questions())
    end

    def get_current_question(conn, %{"game_id" => game_id}) do
      case Game.get_current_question(game_id) do
        nil ->
          conn
          |> put_status(404)
          |> json(%{error: "Game not found"})
        question -> json(conn, question)
      end
    end

    def reset_game(conn, %{"game_id" => game_id}) do
      case Game.reset_game(game_id) do
        :ok -> json(conn, %{message: "Game reset successfully!"})
        :error ->
          conn
          |> put_status(404)
          |> json(%{error: "Game not found"})
      end
    end

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
      json(conn, %{message: "Turn submitted and validated by server"})
    end

    def get_game(conn, %{"game_id" => game_id}) do
      game = Game.get_game(game_id)
      json(conn, game)
    end
  end
