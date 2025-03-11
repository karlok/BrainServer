defmodule BrainServer.Game do
  use Agent # provides a simple in-memory store for keeping track of the active games
  alias GameServer.Questions


  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__) # initializes the game state as an empty map
  end

  # Sample Questions (Would be replaced with database for a real game)
  # @questions %{
  #   "q1" => %{question: "What is 5 + 3?", answer: 8},
  #   "q2" => %{question: "Solve for x: 2x + 4 = 10", answer: 3},
  #   "q3" => %{question: "What is 7 * 6?", answer: 42}
  # }

  def create_game(game_id, player1) do
    Agent.update(__MODULE__, fn games ->
      Map.put(games, game_id, %{
        player1: player1,
        player2: nil,
        rounds: [],
        status: "waiting",
        current_round: 0
      })
    end)
  end

  def join_game(game_id, player2) do
    Agent.update(__MODULE__, fn games ->
      Map.update!(games, game_id, fn game -> Map.put(game, :player2, player2) end) # ensures that only existing games can be joined
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
        correct_answer = Questions.correct_answer(current_question.id)

        is_correct = correct_answer == answer

        rounds = game[:rounds] ++ [%{player => %{question_id: current_question.id, answer: answer, time: time, correct: is_correct}}]

        new_round = game.current_round + 1

        %{game | rounds: rounds, current_round: new_round}
      end)
    end)
  end

  def get_game(game_id) do
    Agent.get(__MODULE__, fn games -> Map.get(games, game_id) end)
  end
end
