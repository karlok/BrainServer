defmodule BrainServer.Game do
  use Agent # provides a simple in-memory store for keeping track of the active games
  alias GameServer.Questions


  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__) # initializes the game state as an empty map
  end

  def create_game(game_id, player1) do
    Agent.update(__MODULE__, fn games ->
      Map.put(games, game_id, %{
        player1: player1,
        player2: nil,
        rounds: [],
        status: "waiting",
        current_round: 0,
        current_round_answers: %{}
      })
    end)
  end

  def join_game(game_id, player2) do
    Agent.update(__MODULE__, fn games ->
      Map.update!(games, game_id, fn game ->
        %{game | player2: player2, status: "in_progress"}
      end)
    end)
  end

  # Gets the current question for the game
  def get_current_question(game_id) do
    game = Agent.get(__MODULE__, fn games -> Map.get(games, game_id) end)

    if game do
      Questions.get_question(game.current_round)
    else
      nil
    end
  end

  def submit_turn(game_id, player, answer, time) do
    Agent.update(__MODULE__, fn games ->
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

        if map_size(current_round_answers) >= 2 ||
           (game.player1 == player && game.player2 == nil) do
          # Both players have answered or single player mode, move to next round

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

          # Check if we've reached the end of available questions
          next_round = game.current_round + 1
          new_status = if next_round >= length(Questions.all_questions()) do
            "completed"
          else
            game.status
          end

          # Clear current round answers and move to next round
          %{updated_game |
            rounds: rounds,
            current_round: next_round,
            current_round_answers: %{},
            status: new_status
          }
        else
          # Still waiting for the other player
          updated_game
        end
      end)
    end)
  end

  # Helper function to evaluate round winner
  defp evaluate_round(answers, player1, player2) do
    p1_answer = Map.get(answers, player1)
    p2_answer = Map.get(answers, player2)

    cond do
      p2_answer == nil ->
        # Single player mode or player 2 hasn't joined yet
        %{winner: player1, reason: "single_player"}

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
        # Both wrong
        %{winner: nil, reason: "both_incorrect"}
    end
  end

  def reset_game(game_id) do
    Agent.update(__MODULE__, fn games ->
      if Map.has_key?(games, game_id) do
        Map.update!(games, game_id, fn game ->
          %{game |
            rounds: [],
            current_round: 0,
            status: "waiting",
            current_round_answers: %{}
          }
        end)
        :ok
      else
        :error
      end
    end)
  end

  def get_game(game_id) do
    Agent.get(__MODULE__, fn games -> Map.get(games, game_id) end)
  end
end
