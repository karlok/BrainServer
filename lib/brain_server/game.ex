defmodule BrainServer.Game do
  use Agent # provides a simple in-memory store for keeping track of the active games
  alias GameServer.Questions
  require Logger


  def start_link(_) do
    Logger.info("Starting BrainServer.Game Agent")
    Agent.start_link(fn -> %{} end, name: __MODULE__) # initializes the game state as an empty map
  end

  def create_game(game_id, player1) do
    Logger.info("Creating game #{game_id} with player1 #{player1}")
    Agent.update(__MODULE__, fn games ->
      Map.put(games, game_id, %{
        player1: player1,
        player2: nil,
        rounds: [],
        status: "waiting",
        current_round: 0,
        current_round_answers: %{},
        score: %{player1 => 0},
        winner: nil  # Explicitly initialize winner as nil
      })
    end)
  end

  def join_game(game_id, player2) do
    Logger.info("Player #{player2} joining game #{game_id}")
    Agent.update(__MODULE__, fn games ->
      Map.update!(games, game_id, fn game ->
        %{game |
          player2: player2,
          status: "in_progress",
          score: Map.put(game.score, player2, 0),
          winner: nil  # Ensure winner is nil when joining
        }
      end)
    end)
  end

  # Gets the current question for the game
  def get_current_question(game_id) do
    Logger.info("Getting current question for game #{game_id}")
    game = Agent.get(__MODULE__, fn games -> Map.get(games, game_id) end)

    if game do
      Questions.get_question(game.current_round)
    else
      nil
    end
  end

  def submit_turn(game_id, player, answer, time) do
    Logger.info("Player #{player} submitting turn for game #{game_id} with answer #{answer} and time #{time}")

    # First, check if the game exists
    game_exists = Agent.get(__MODULE__, fn games -> Map.has_key?(games, game_id) end)

    if !game_exists do
      Logger.error("Game #{game_id} not found when submitting turn")
      {:error, :game_not_found}
    else
      Agent.update(__MODULE__, fn games ->
        try do
          Map.update!(games, game_id, fn game ->
            current_question = Questions.get_question(game.current_round)
            correct_answer = current_question.answer
            is_correct = correct_answer == answer

            # Add this player's answer to the current round
            current_round_answers = Map.put(
              game.current_round_answers,
              player,
              %{answer: answer, time: time, correct: is_correct}
            )

            # Check if both players have answered
            updated_game = %{game | current_round_answers: current_round_answers}

            if map_size(current_round_answers) >= 2 do
              # Both players have answered, evaluate the round

              # Determine round winner based on correctness and time
              round_result = evaluate_round(current_round_answers, game.player1, game.player2)

              # Add completed round to rounds history
              new_round = %{
                question_id: current_question.id,
                question: current_question.question,
                correct_answer: correct_answer,
                answers: current_round_answers,
                winner: round_result.winner,
                reason: round_result.reason
              }

              rounds = game.rounds ++ [new_round]

              # Update the score
              updated_score = if round_result.winner do
                Map.update(game.score, round_result.winner, 1, &(&1 + 1))
              else
                game.score
              end

              # Check if someone has won 3 rounds
              {winner, game_completed} = check_game_winner(updated_score)

              if game_completed do
                # Game is completed, someone has won 3 rounds
                %{updated_game |
                  rounds: rounds,
                  current_round: game.current_round + 1,
                  current_round_answers: %{},
                  status: "completed",
                  score: updated_score,
                  winner: winner  # Set the winner
                }
              else
                # Continue to next round
                %{updated_game |
                  rounds: rounds,
                  current_round: game.current_round + 1,
                  current_round_answers: %{},
                  score: updated_score,
                  winner: nil  # Explicitly set winner to nil for in-progress games
                }
              end
            else
              # Still waiting for the other player
              updated_game
            end
          end)
        rescue
          e ->
            Logger.error("Error in submit_turn: #{inspect(e)}")
            # Return the games map unchanged if there's an error
            games
        end
      end)

      # Return :ok to indicate success
      :ok
    end
  end

  # Helper function to evaluate round winner
  defp evaluate_round(answers, player1, player2) do
    p1_answer = Map.get(answers, player1)
    p2_answer = Map.get(answers, player2)

    cond do
      p1_answer.correct && !p2_answer.correct ->
        %{winner: player1, reason: "correct_answer"}

      !p1_answer.correct && p2_answer.correct ->
        %{winner: player2, reason: "correct_answer"}

      p1_answer.correct && p2_answer.correct ->
        # Both correct, faster time wins
        if p1_answer.time < p2_answer.time do
          %{winner: player1, reason: "faster_time"}
        else
          %{winner: player2, reason: "faster_time"}
        end

      true ->
        # Both wrong, it's a tie
        %{winner: nil, reason: "both_incorrect"}
    end
  end

  # Check if someone has won 3 rounds
  defp check_game_winner(score) do
    winner = Enum.find_value(score, fn {player, wins} ->
      if wins >= 3, do: player, else: nil
    end)

    {winner, winner != nil}
  end

  def reset_game(game_id) do
    Logger.info("Resetting game #{game_id}")
    Agent.update(__MODULE__, fn games ->
      if Map.has_key?(games, game_id) do
        Map.update!(games, game_id, fn game ->
          %{game |
            rounds: [],
            current_round: 0,
            status: "waiting",
            current_round_answers: %{},
            winner: nil,
            score: %{game.player1 => 0, game.player2 => 0}
          }
        end)
      else
        games
      end
    end)

    # Return :ok or :error outside the Agent.update callback
    if Agent.get(__MODULE__, fn games -> Map.has_key?(games, game_id) end) do
      :ok
    else
      :error
    end
  end

  def get_game(game_id) do
    Logger.info("Getting game #{game_id}")
    game = Agent.get(__MODULE__, fn games ->
      Logger.info("All games: #{inspect(Map.keys(games))}")
      Map.get(games, game_id)
    end)
    Logger.info("Game #{game_id} found: #{game != nil}")
    game
  end
end
