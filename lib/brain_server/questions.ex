defmodule GameServer.Questions do # ok, this would eventually be replaced with a properdatabase
  @questions [
    %{id: "q1", question: "What is 5 + 3?", answer: 8},
    %{id: "q2", question: "Solve for x: 2x + 4 = 10", answer: 3},
    %{id: "q3", question: "What is 7 * 6?", answer: 42},
    %{id: "q4", question: "What is the square root of 49?", answer: 7},
    %{id: "q5", question: "What is 12 divided by 4?", answer: 3}
  ]

  def all_questions do
    @questions
  end

  def get_question(index) when index >= 0 and index < length(@questions) do
    Enum.at(@questions, index)
  end

  def get_question(_index) do
    # Return the first question if index is out of bounds
    Enum.at(@questions, 0)
  end

  def correct_answer(question_id) do
    case Enum.find(@questions, fn q -> q.id == question_id end) do
      %{answer: answer} -> answer
      _ -> nil
    end
  end
end
