defmodule BrainServer.Game do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def create_game(game_id, player1) do
    Agent.update(__MODULE__, fn games ->
      Map.put(games, game_id, %{player1: player1, player2: nil, rounds: [], status: "waiting"})
    end)
  end

  def join_game(game_id, player2) do
    Agent.update(__MODULE__, fn games ->
      Map.update!(games, game_id, fn game -> Map.put(game, :player2, player2) end)
    end)
  end

  def submit_turn(game_id, player, answer, time) do
    Agent.update(__MODULE__, fn games ->
      Map.update!(games, game_id, fn game ->
        rounds = game[:rounds] ++ [%{player => %{answer: answer, time: time}}]
        %{game | rounds: rounds}
      end)
    end)
  end

  def get_game(game_id) do
    Agent.get(__MODULE__, fn games -> Map.get(games, game_id) end)
  end
end