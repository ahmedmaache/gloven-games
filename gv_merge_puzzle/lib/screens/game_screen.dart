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
  static const int gridSize = 4;
  final Random _random = Random();
  
  // Grid: 4x4, values are 0 (empty), 2, 4, 8, etc.
  late List<List<int>> _grid;
  
  int _score = 0;
  int _bestScore = 0;
  bool _isGameOver = false;
  bool _hasWon = false;
  
  // Undo feature (v1.0.1)
  List<List<int>>? _previousGrid;
  int? _previousScore;
  bool _canUndo = false;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
    _startNewGame();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bestScore = prefs.getInt('merge_puzzle_best_score') ?? 0;
    });
  }

  Future<void> _saveBestScore() async {
    if (_score > _bestScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('merge_puzzle_best_score', _score);
      setState(() {
        _bestScore = _score;
      });
    }
  }

  void _startNewGame() {
    setState(() {
      _grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
      _score = 0;
      _isGameOver = false;
      _hasWon = false;
      _previousGrid = null;
      _previousScore = null;
      _canUndo = false;
      _spawnTile();
      _spawnTile();
    });
  }

  void _spawnTile() {
    List<Point<int>> emptySpots = [];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (_grid[r][c] == 0) {
          emptySpots.add(Point(r, c));
        }
      }
    }
    
    if (emptySpots.isEmpty) return;
    
    Point<int> spot = emptySpots[_random.nextInt(emptySpots.length)];
    _grid[spot.x][spot.y] = _random.nextDouble() < 0.9 ? 2 : 4;
  }

  // v1.0.1: Save state before move for undo
  void _saveState() {
    _previousGrid = _grid.map((row) => List<int>.from(row)).toList();
    _previousScore = _score;
    _canUndo = true;
  }

  // v1.0.1: Undo last move
  void _undoMove() {
    if (!_canUndo || _previousGrid == null) return;
    
    setState(() {
      _grid = _previousGrid!;
      _score = _previousScore!;
      _isGameOver = false;
      _canUndo = false;
    });
  }

  void _move(Direction direction) {
    if (_isGameOver) return;

    _saveState(); // Save state before move

    bool moved = false;
    
    switch (direction) {
      case Direction.up:
        moved = _moveUp();
        break;
      case Direction.down:
        moved = _moveDown();
        break;
      case Direction.left:
        moved = _moveLeft();
        break;
      case Direction.right:
        moved = _moveRight();
        break;
    }

    if (moved) {
      setState(() {
        _spawnTile();
        _checkGameState();
      });
    } else {
      // If no move happened, don't allow undo
      _canUndo = false;
    }
  }

  bool _moveLeft() {
    bool moved = false;
    for (int r = 0; r < gridSize; r++) {
      List<int> row = _grid[r].where((v) => v != 0).toList();
      // Merge
      for (int i = 0; i < row.length - 1; i++) {
        if (row[i] == row[i + 1]) {
          row[i] *= 2;
          _score += row[i];
          row[i + 1] = 0;
        }
      }
      row = row.where((v) => v != 0).toList();
      // Pad
      while (row.length < gridSize) {
        row.add(0);
      }
      if (!_listEquals(_grid[r], row)) moved = true;
      _grid[r] = row;
    }
    return moved;
  }

  bool _moveRight() {
    bool moved = false;
    for (int r = 0; r < gridSize; r++) {
      List<int> row = _grid[r].where((v) => v != 0).toList();
      // Merge from right
      for (int i = row.length - 1; i > 0; i--) {
        if (row[i] == row[i - 1]) {
          row[i] *= 2;
          _score += row[i];
          row[i - 1] = 0;
        }
      }
      row = row.where((v) => v != 0).toList();
      // Pad left
      while (row.length < gridSize) {
        row.insert(0, 0);
      }
      if (!_listEquals(_grid[r], row)) moved = true;
      _grid[r] = row;
    }
    return moved;
  }

  bool _moveUp() {
    bool moved = false;
    for (int c = 0; c < gridSize; c++) {
      List<int> col = [];
      for (int r = 0; r < gridSize; r++) {
        if (_grid[r][c] != 0) col.add(_grid[r][c]);
      }
      // Merge
      for (int i = 0; i < col.length - 1; i++) {
        if (col[i] == col[i + 1]) {
          col[i] *= 2;
          _score += col[i];
          col[i + 1] = 0;
        }
      }
      col = col.where((v) => v != 0).toList();
      while (col.length < gridSize) {
        col.add(0);
      }
      for (int r = 0; r < gridSize; r++) {
        if (_grid[r][c] != col[r]) moved = true;
        _grid[r][c] = col[r];
      }
    }
    return moved;
  }

  bool _moveDown() {
    bool moved = false;
    for (int c = 0; c < gridSize; c++) {
      List<int> col = [];
      for (int r = 0; r < gridSize; r++) {
        if (_grid[r][c] != 0) col.add(_grid[r][c]);
      }
      // Merge from bottom
      for (int i = col.length - 1; i > 0; i--) {
        if (col[i] == col[i - 1]) {
          col[i] *= 2;
          _score += col[i];
          col[i - 1] = 0;
        }
      }
      col = col.where((v) => v != 0).toList();
      while (col.length < gridSize) {
        col.insert(0, 0);
      }
      for (int r = 0; r < gridSize; r++) {
        if (_grid[r][c] != col[r]) moved = true;
        _grid[r][c] = col[r];
      }
    }
    return moved;
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _checkGameState() {
    // Check for 2048 win
    for (var row in _grid) {
      if (row.contains(2048)) {
        _hasWon = true;
        _saveBestScore();
        return;
      }
    }

    // Check for game over (no moves possible)
    // Has empty cell?
    for (var row in _grid) {
      if (row.contains(0)) return;
    }

    // Check for possible merges
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        int val = _grid[r][c];
        if (r < gridSize - 1 && _grid[r + 1][c] == val) return;
        if (c < gridSize - 1 && _grid[r][c + 1] == val) return;
      }
    }

    // No moves possible
    _isGameOver = true;
    _saveBestScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
        ),
        actions: [
          // Undo button (v1.0.1)
          IconButton(
            onPressed: _canUndo ? _undoMove : null,
            icon: Icon(
              Icons.undo,
              color: _canUndo ? primaryColor : Colors.grey[400],
            ),
          ),
          IconButton(
            onPressed: _startNewGame,
            icon: Icon(Icons.refresh, color: primaryColor),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Score Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildScoreBox("SCORE", _score),
                  _buildScoreBox("BEST", _bestScore),
                ],
              ),

              const SizedBox(height: 20),

              // Game Grid
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      onVerticalDragEnd: (details) {
                        if (details.velocity.pixelsPerSecond.dy < -100) {
                          _move(Direction.up);
                        } else if (details.velocity.pixelsPerSecond.dy > 100) {
                          _move(Direction.down);
                        }
                      },
                      onHorizontalDragEnd: (details) {
                        if (details.velocity.pixelsPerSecond.dx < -100) {
                          _move(Direction.left);
                        } else if (details.velocity.pixelsPerSecond.dx > 100) {
                          _move(Direction.right);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBBADA0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridSize,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: gridSize * gridSize,
                          itemBuilder: (context, index) {
                            int row = index ~/ gridSize;
                            int col = index % gridSize;
                            int value = _grid[row][col];
                            return _buildTile(value);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Instructions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Swipe to move tiles",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_canUndo)
                    Text(
                      "| Tap ↩ to undo",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),

              // Overlays
              if (_isGameOver || _hasWon)
                Positioned.fill(
                  child: _buildEndOverlay(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBox(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(int value) {
    Color bgColor = tileColors[value] ?? tileColors[2048]!;
    Color textColor = getTileTextColor(value);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: value > 0
            ? Text(
                value.toString(),
                style: TextStyle(
                  fontSize: value >= 1000 ? 20 : (value >= 100 ? 28 : 36),
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildEndOverlay() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _hasWon ? "🎉 YOU WIN!" : "GAME OVER",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _hasWon ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Score: $_score",
            style: const TextStyle(fontSize: 20),
          ),
          if (_score >= _bestScore && _score > 0) ...[
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  "NEW HIGH SCORE!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startNewGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }
}

enum Direction { up, down, left, right }
