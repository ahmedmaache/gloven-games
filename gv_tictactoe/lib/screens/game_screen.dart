import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Board: 9 cells, '' = empty, 'X' = player, 'O' = AI
  List<String> _board = List.filled(9, '');
  
  // Game state
  bool _isPlayerTurn = true;
  String _winner = ''; // '', 'X', 'O', or 'draw'
  bool _gameOver = false;
  
  // Stats (persistent - v1.0.1)
  int _playerWins = 0;
  int _aiWins = 0;
  int _draws = 0;
  
  // v1.0.1: Difficulty setting
  bool _hardMode = false;
  
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadStats();
    _resetBoard();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _playerWins = prefs.getInt('tictactoe_player_wins') ?? 0;
      _aiWins = prefs.getInt('tictactoe_ai_wins') ?? 0;
      _draws = prefs.getInt('tictactoe_draws') ?? 0;
      _hardMode = prefs.getBool('tictactoe_hard_mode') ?? false;
    });
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tictactoe_player_wins', _playerWins);
    await prefs.setInt('tictactoe_ai_wins', _aiWins);
    await prefs.setInt('tictactoe_draws', _draws);
  }

  Future<void> _saveDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tictactoe_hard_mode', _hardMode);
  }

  void _resetBoard() {
    setState(() {
      _board = List.filled(9, '');
      _isPlayerTurn = true;
      _winner = '';
      _gameOver = false;
    });
  }

  void _onCellTap(int index) {
    if (_gameOver || !_isPlayerTurn || _board[index].isNotEmpty) return;

    setState(() {
      _board[index] = 'X';
      _isPlayerTurn = false;
    });

    _checkWinner();

    if (!_gameOver) {
      // AI moves after short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _aiMove();
      });
    }
  }

  void _aiMove() {
    if (_gameOver) return;

    int? move;
    
    if (_hardMode) {
      // v1.0.1: Smart AI using minimax
      move = _findBestMove();
    } else {
      // Easy AI: Try to win, then block, then random
      move = _findWinningMove('O'); // Try to win
      move ??= _findWinningMove('X'); // Block player
      move ??= _findRandomMove();
    }

    if (move != null) {
      setState(() {
        _board[move!] = 'O';
        _isPlayerTurn = true;
      });
      _checkWinner();
    }
  }

  // v1.0.1: Minimax algorithm for hard mode
  int? _findBestMove() {
    int bestScore = -1000;
    int? bestMove;
    
    for (int i = 0; i < 9; i++) {
      if (_board[i].isEmpty) {
        _board[i] = 'O';
        int score = _minimax(_board, 0, false);
        _board[i] = '';
        
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    
    return bestMove;
  }

  int _minimax(List<String> board, int depth, bool isMaximizing) {
    String? result = _checkWinnerForBoard(board);
    
    if (result == 'O') return 10 - depth;
    if (result == 'X') return depth - 10;
    if (result == 'draw') return 0;
    
    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (board[i].isEmpty) {
          board[i] = 'O';
          int score = _minimax(board, depth + 1, false);
          board[i] = '';
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (board[i].isEmpty) {
          board[i] = 'X';
          int score = _minimax(board, depth + 1, true);
          board[i] = '';
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  String? _checkWinnerForBoard(List<String> board) {
    const List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      String a = board[pattern[0]];
      String b = board[pattern[1]];
      String c = board[pattern[2]];

      if (a.isNotEmpty && a == b && b == c) {
        return a;
      }
    }

    if (!board.contains('')) {
      return 'draw';
    }
    
    return null;
  }

  int? _findWinningMove(String player) {
    // Check all winning combinations
    const List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var pattern in winPatterns) {
      int count = 0;
      int? emptyIndex;
      
      for (int i in pattern) {
        if (_board[i] == player) {
          count++;
        } else if (_board[i].isEmpty) {
          emptyIndex = i;
        }
      }

      if (count == 2 && emptyIndex != null) {
        return emptyIndex;
      }
    }
    return null;
  }

  int? _findRandomMove() {
    // Prefer center, then corners, then edges
    List<int> priority = [4, 0, 2, 6, 8, 1, 3, 5, 7];
    
    for (int i in priority) {
      if (_board[i].isEmpty) {
        return i;
      }
    }
    return null;
  }

  void _checkWinner() {
    const List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      String a = _board[pattern[0]];
      String b = _board[pattern[1]];
      String c = _board[pattern[2]];

      if (a.isNotEmpty && a == b && b == c) {
        setState(() {
          _winner = a;
          _gameOver = true;
          if (a == 'X') {
            _playerWins++;
          } else {
            _aiWins++;
          }
        });
        _saveStats();
        return;
      }
    }

    // Check draw
    if (!_board.contains('')) {
      setState(() {
        _winner = 'draw';
        _gameOver = true;
        _draws++;
      });
      _saveStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Tic Tac Toe"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // v1.0.1: Difficulty toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text(
                  _hardMode ? "HARD" : "EASY",
                  style: TextStyle(
                    fontSize: 12,
                    color: _hardMode ? Colors.red[200] : Colors.green[200],
                  ),
                ),
                Switch(
                  value: _hardMode,
                  onChanged: (value) {
                    setState(() {
                      _hardMode = value;
                      _saveDifficulty();
                      _resetBoard();
                    });
                  },
                  activeColor: Colors.red[300],
                  inactiveThumbColor: Colors.green[300],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _resetBoard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          _buildStatsBar(),

          // Difficulty indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _hardMode ? "🔥 Hard Mode - AI is unbeatable!" : "😊 Easy Mode",
              style: TextStyle(
                fontSize: 14,
                color: _hardMode ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Turn indicator
          _buildTurnIndicator(),

          const Spacer(),

          // Game board
          _buildBoard(),

          const Spacer(),

          // Result / Play Again
          if (_gameOver)
            _buildResultSection(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: primaryColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("You (X)", _playerWins, xColor),
          _buildStatItem("Draws", _draws, Colors.grey),
          _buildStatItem("AI (O)", _aiWins, oColor),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTurnIndicator() {
    String text;
    Color color;

    if (_gameOver) {
      if (_winner == 'X') {
        text = "You Win! 🎉";
        color = xColor;
      } else if (_winner == 'O') {
        text = "AI Wins! 🤖";
        color = oColor;
      } else {
        text = "It's a Draw! 🤝";
        color = Colors.grey;
      }
    } else {
      text = _isPlayerTurn ? "Your Turn (X)" : "AI Thinking...";
      color = _isPlayerTurn ? xColor : oColor;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 9,
          itemBuilder: (context, index) => _buildCell(index),
        ),
      ),
    );
  }

  Widget _buildCell(int index) {
    String value = _board[index];
    
    return GestureDetector(
      onTap: () => _onCellTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: value.isEmpty ? Colors.grey[200] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value.isEmpty ? Colors.grey[300]! : (value == 'X' ? xColor : oColor),
            width: 2,
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: value.isNotEmpty
                ? Text(
                    value,
                    key: ValueKey(value),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: value == 'X' ? xColor : oColor,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: _resetBoard,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "PLAY AGAIN",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
