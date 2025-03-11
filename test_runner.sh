#!/bin/bash
# Test runner script for the Brain Server game API
# To run the test script, make sure your Phoenix server is running in a separate terminal window, and then execute:
# ./test_runner.sh

echo "=== STARTING GAME TEST ==="
echo ""

echo "=== 1. Creating a new game with Alice (player 1) ==="
curl -v -X POST http://localhost:4000/api/create_game \
  -H "Content-Type: application/json" \
  -d '{"game_id": "game123", "player1": "Alice"}'
echo -e "\n"

echo "=== 2. Checking the game state ==="
curl -v -X GET http://localhost:4000/api/game/game123
echo -e "\n"

echo "=== 3. Getting the first question ==="
curl -v -X GET http://localhost:4000/api/question/game123
echo -e "\n"

echo "=== 4. Player 2 joins (Bob) ==="
curl -v -X POST http://localhost:4000/api/join_game \
  -H "Content-Type: application/json" \
  -d '{"game_id": "game123", "player2": "Bob"}'
echo -e "\n"

echo "=== 5. Checking the game state after Bob joins ==="
curl -v -X GET http://localhost:4000/api/game/game123
echo -e "\n"

echo "=== ROUND 1 ==="
echo "=== 6. Alice submits a correct answer to question 1 (faster) ==="
curl -v -X POST http://localhost:4000/api/submit_turn \
  -H "Content-Type: application/json" \
  -d '{"game_id": "game123", "player": "Alice", "answer": 10, "time": 2.5}'
echo -e "\n"

echo "=== 7. Bob submits a correct answer to question 1 (slower) ==="
curl -v -X POST http://localhost:4000/api/submit_turn \
  -H "Content-Type: application/json" \
  -d '{"game_id": "game123", "player": "Bob", "answer": 10, "time": 3.2}'
echo -e "\n"

echo "=== 8. Checking the game state after round 1 (Alice should win round 1) ==="
curl -v -X GET http://localhost:4000/api/game/game123
echo -e "\n"

echo "=== ROUND 2 ==="
echo "=== 9. Getting the second question ==="
curl -v -X GET http://localhost:4000/api/question/game123
echo -e "\n"

echo "=== 10. Bob submits a correct answer to question 2 ==="
curl -v -X POST http://localhost:4000/api/submit_turn \
  -H "Content-Type: application/json" \
  -d '{"game_id": "game123", "player": "Bob", "answer": 3, "time": 4.1}'
echo -e "\n"

echo "=== 11. Alice submits an incorrect answer to question 2 ==="
curl -v -X POST http://localhost:4000/api/submit_turn \
  -H "Content-Type: application/json" \
  -d '{"game_id": "game123", "player": "Alice", "answer": 4, "time": 3.5}'
echo -e "\n"

echo "=== 12. Checking the game state after round 2 (Bob should win round 2) ==="
curl -v -X GET http://localhost:4000/api/game/game123
echo -e "\n"

echo "=== ROUND 3 ==="
echo "=== 13. Getting the third question ==="
curl -v -X GET http://localhost:4000/api/question/game123
echo -e "\n"

echo "=== 14. Alice submits a correct answer to question 3 ==="
curl -v -X POST http://localhost:4000/api/submit_turn \
  -H "Content-Type: application/json" \
  -d '{"game_id": "game123", "player": "Alice", "answer": 10, "time": 2.0}'
echo -e "\n"

echo "=== 15. Bob submits a correct answer to question 3 (faster) ==="
curl -v -X POST http://localhost:4000/api/submit_turn \
  -H "Content-Type: application/json" \
  -d '{"game_id": "game123", "player": "Bob", "answer": 10, "time": 1.5}'
echo -e "\n"

echo "=== 16. Checking the game state after round 3 (Bob should win round 3) ==="
curl -v -X GET http://localhost:4000/api/game/game123
echo -e "\n"

echo "=== ROUND 4 ==="
echo "=== 17. Getting the fourth question ==="
curl -v -X GET http://localhost:4000/api/question/game123
echo -e "\n"

echo "=== 18. Alice submits a correct answer to question 4 ==="
curl -v -X POST http://localhost:4000/api/submit_turn \
  -H "Content-Type: application/json" \
  -d '{"game_id": "game123", "player": "Alice", "answer": 7, "time": 1.5}'
echo -e "\n"

echo "=== 19. Bob submits an incorrect answer to question 4 ==="
curl -v -X POST http://localhost:4000/api/submit_turn \
  -H "Content-Type: application/json" \
  -d '{"game_id": "game123", "player": "Bob", "answer": 8, "time": 2.0}'
echo -e "\n"

echo "=== 20. Checking the game state after round 4 (Alice should win round 4) ==="
curl -v -X GET http://localhost:4000/api/game/game123
echo -e "\n"

echo "=== ROUND 5 ==="
echo "=== 21. Getting the fifth question ==="
curl -v -X GET http://localhost:4000/api/question/game123
echo -e "\n"

echo "=== 22. Alice submits a correct answer to question 5 (faster) ==="
curl -v -X POST http://localhost:4000/api/submit_turn \
  -H "Content-Type: application/json" \
  -d '{"game_id": "game123", "player": "Alice", "answer": 50.24, "time": 3.0}'
echo -e "\n"

echo "=== 23. Bob submits a correct answer to question 5 (slower) ==="
curl -v -X POST http://localhost:4000/api/submit_turn \
  -H "Content-Type: application/json" \
  -d '{"game_id": "game123", "player": "Bob", "answer": 50.24, "time": 3.5}'
echo -e "\n"

echo "=== 24. Checking the final game state (Alice should win the game with 3 rounds) ==="
curl -v -X GET http://localhost:4000/api/game/game123
echo -e "\n"

echo "=== 25. Resetting the game ==="
curl -v -X POST http://localhost:4000/api/reset_game \
  -H "Content-Type: application/json" \
  -d '{"game_id": "game123"}'
echo -e "\n"

echo "=== 26. Checking the game state after reset ==="
curl -v -X GET http://localhost:4000/api/game/game123
echo -e "\n"

echo "=== TEST COMPLETE ==="
