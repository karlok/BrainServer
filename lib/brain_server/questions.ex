defmodule GameServer.Questions do # ok, this would eventually be replaced with a properdatabase
  @questions [
    %{id: "q1", question: "20% of 50 is equal to what?", answer: 10},
    %{id: "q2", question: "Solve for x: 2x + 4 = 10", answer: 3},
    %{id: "q3", question: "A right triangle has legs of 6 and 8. What is the length of the hypotenuse?", answer: 10},
    %{id: "q4", question: "If 3x - 7 = 14, what is the value of x?", answer: 7},
    %{id: "q5", question: "What is the area of a circle with radius 4? (Use π = 3.14)", answer: 50.24},
    %{id: "q6", question: "If a car travels at 60 mph for 2.5 hours, how far does it travel?", answer: 150},
    %{id: "q7", question: "What is the square root of 144?", answer: 12},
    %{id: "q8", question: "If 4y + 3 = 15, what is the value of y?", answer: 3},
    %{id: "q9", question: "What is the value of 3² + 4²?", answer: 25},
    %{id: "q10", question: "If a rectangle has length 12 and width 5, what is its perimeter?", answer: 34}
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
