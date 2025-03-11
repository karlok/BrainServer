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
        # Get the game state before submitting the turn
        game_before = Game.get_game(game_id)

        cond do
          game_before == nil ->
            conn
            |> put_status(404)
            |> json(%{error: "Game not found"})

          game_before.player2 == nil ->
            conn
            |> put_status(400)
            |> json(%{error: "Cannot submit answer until player 2 has joined"})

          true ->
            # Get the current question
            current_question = Questions.get_question(game_before.current_round)
            is_correct = current_question.answer == answer

            # Submit the turn
            case Game.submit_turn(game_id, player, answer, time) do
              :ok ->
                # Get the updated game state
                game_after = Game.get_game(game_id)

                # Prepare the response
                response = %{
                  message: "Turn submitted",
                  correct: is_correct,
                  correct_answer: current_question.answer,
                  question: current_question.question,
                  waiting_for_opponent: map_size(game_after.current_round_answers) < 2,
                  game_status: game_after.status,
                  score: game_after.score
                }

                # Add game completion info if the game is now completed
                response = if game_after.status == "completed" do
                  # Safely access the winner field with a default of nil
                  winner = Map.get(game_after, :winner, nil)

                  Map.merge(response, %{
                    game_completed: true,
                    winner: winner,
                    is_winner: player == winner,
                    summary: %{
                      rounds_played: length(game_after.rounds),
                      final_score: game_after.score
                    }
                  })
                else
                  Map.merge(response, %{
                    game_completed: false
                  })
                end

                # Return the result
                json(conn, response)

              {:error, :game_not_found} ->
                conn
                |> put_status(404)
                |> json(%{error: "Game not found"})

              _ ->
                conn
                |> put_status(500)
                |> json(%{error: "An error occurred while submitting the turn"})
            end
        end
    end

    def get_game(conn, %{"game_id" => game_id}) do
      game = Game.get_game(game_id)

      if game do
        response = case game.status do
          "completed" ->
            # For completed games, add a summary section
            winner = Map.get(game, :winner)

            %{
              game_id: game_id,
              status: game.status,
              player1: game.player1,
              player2: game.player2,
              rounds: game.rounds,
              current_round: game.current_round,
              score: game.score,
              winner: winner,
              summary: %{
                winner: winner,
                rounds_played: length(game.rounds),
                final_score: game.score
              }
            }

          _ ->
            # For games in progress or waiting, return the standard game state
            game
        end

        json(conn, response)
      else
        conn
        |> put_status(404)
        |> json(%{error: "Game not found"})
      end
    end
  end
