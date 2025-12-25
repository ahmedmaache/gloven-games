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
  final Random _random = Random();
  
  // 8x8 Grid. Stores color index (0..4). -1 means empty.
  late List<List<int>> _grid;
  
  int _score = 0;
  int _highScore = 0;
  int _movesLeft = maxMoves;
  int _hintsRemaining = 3; // v1.0.1 feature
  
  // Selection
  int? _selectedRow;
  int? _selectedCol;
  
  // Hint highlight (v1.0.1)
  int? _hintRow1, _hintCol1, _hintRow2, _hintCol2;
  
  bool _isProcessing = false; // Prevent input while animating/checking

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _startNewGame();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('match3_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('match3_high_score', _score);
      setState(() {
        _highScore = _score;
      });
    }
  }

  void _startNewGame() {
    _score = 0;
    _movesLeft = maxMoves;
    _hintsRemaining = 3;
    _hintRow1 = _hintCol1 = _hintRow2 = _hintCol2 = null;
    _generateInitialGrid();
  }

  void _generateInitialGrid() {
    _grid = List.generate(gridSize, (row) {
      return List.generate(gridSize, (col) {
        return _random.nextInt(tileColors.length);
      });
    });
  }

  // v1.0.1: Shuffle feature
  void _shuffleGrid() {
    setState(() {
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          _grid[r][c] = _random.nextInt(tileColors.length);
        }
      }
      _hintRow1 = _hintCol1 = _hintRow2 = _hintCol2 = null;
    });
  }

  // v1.0.1: Hint feature
  void _showHint() {
    if (_hintsRemaining <= 0 || _isProcessing) return;
    
    // Find a valid move
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        // Check swap right
        if (c < gridSize - 1) {
          if (_wouldMatch(r, c, r, c + 1)) {
            setState(() {
              _hintRow1 = r; _hintCol1 = c;
              _hintRow2 = r; _hintCol2 = c + 1;
              _hintsRemaining--;
            });
            return;
          }
        }
        // Check swap down
        if (r < gridSize - 1) {
          if (_wouldMatch(r, c, r + 1, c)) {
            setState(() {
              _hintRow1 = r; _hintCol1 = c;
              _hintRow2 = r + 1; _hintCol2 = c;
              _hintsRemaining--;
            });
            return;
          }
        }
      }
    }
    // No valid moves found - shuffle
    _shuffleGrid();
  }

  bool _wouldMatch(int r1, int c1, int r2, int c2) {
    // Swap temporarily
    int temp = _grid[r1][c1];
    _grid[r1][c1] = _grid[r2][c2];
    _grid[r2][c2] = temp;
    
    bool hasMatch = _hasAnyMatch();
    
    // Swap back
    _grid[r2][c2] = _grid[r1][c1];
    _grid[r1][c1] = temp;
    
    return hasMatch;
  }

  bool _hasAnyMatch() {
    // Horizontal
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize - 2; c++) {
        int color = _grid[r][c];
        if (color == -1) continue;
        if (_grid[r][c+1] == color && _grid[r][c+2] == color) {
          return true;
        }
      }
    }
    // Vertical
    for (int c = 0; c < gridSize; c++) {
      for (int r = 0; r < gridSize - 2; r++) {
        int color = _grid[r][c];
        if (color == -1) continue;
        if (_grid[r+1][c] == color && _grid[r+2][c] == color) {
          return true;
        }
      }
    }
    return false;
  }

  void _onTileTap(int row, int col) async {
    if (_isProcessing || _movesLeft <= 0) return;

    setState(() {
      _hintRow1 = _hintCol1 = _hintRow2 = _hintCol2 = null; // Clear hint
      
      if (_selectedRow == null) {
        // First selection
        _selectedRow = row;
        _selectedCol = col;
      } else {
        // Second selection
        int r1 = _selectedRow!;
        int c1 = _selectedCol!;
        
        // If tapped same tile, deselect
        if (r1 == row && c1 == col) {
          _selectedRow = null;
          _selectedCol = null;
          return;
        }

        // Check adjacency
        bool isAdjacent = (r1 == row && (c1 - col).abs() == 1) || 
                          (c1 == col && (r1 - row).abs() == 1);
        
        if (isAdjacent) {
          _swapAndCheck(r1, c1, row, col);
          _selectedRow = null;
          _selectedCol = null;
        } else {
          // If not adjacent, just select the new one
          _selectedRow = row;
          _selectedCol = col;
        }
      }
    });
  }

  Future<void> _swapAndCheck(int r1, int c1, int r2, int c2) async {
    setState(() {
      _isProcessing = true;
      // Swap
      int temp = _grid[r1][c1];
      _grid[r1][c1] = _grid[r2][c2];
      _grid[r2][c2] = temp;
      
      _movesLeft--;
    });

    // Short delay to show swap
    await Future.delayed(const Duration(milliseconds: 200));

    // Check Matches
    bool hasMatch = await _processMatches();

    if (!hasMatch) {
      setState(() {
         int temp = _grid[r1][c1];
        _grid[r1][c1] = _grid[r2][c2];
        _grid[r2][c2] = temp;
        _movesLeft++; // Refund move
      });
    }

    // Process cascading matches
    while (hasMatch) {
       await Future.delayed(const Duration(milliseconds: 300));
       hasMatch = await _processMatches();
    }
    
    setState(() {
      _isProcessing = false;
    });

    if (_movesLeft <= 0) {
      _saveHighScore();
      _showGameOver();
    }
  }

  Future<bool> _processMatches() async {
    // 1. Find matches
    Set<Point<int>> matchedPoints = {};

    // Horizontal
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize - 2; c++) {
        int color = _grid[r][c];
        if (color == -1) continue;
        if (_grid[r][c+1] == color && _grid[r][c+2] == color) {
          matchedPoints.add(Point(r, c));
          matchedPoints.add(Point(r, c+1));
          matchedPoints.add(Point(r, c+2));
        }
      }
    }

    // Vertical
    for (int c = 0; c < gridSize; c++) {
      for (int r = 0; r < gridSize - 2; r++) {
        int color = _grid[r][c];
        if (color == -1) continue;
        if (_grid[r+1][c] == color && _grid[r+2][c] == color) {
          matchedPoints.add(Point(r, c));
          matchedPoints.add(Point(r+1, c));
          matchedPoints.add(Point(r+2, c));
        }
      }
    }

    if (matchedPoints.isEmpty) return false;

    // 2. Remove matches & Update Score
    setState(() {
      for (var p in matchedPoints) {
        _grid[p.x][p.y] = -1; // Empty
      }
      _score += matchedPoints.length * 10;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    // 3. Drop tiles
    setState(() {
      for (int c = 0; c < gridSize; c++) {
        for (int r = gridSize - 1; r >= 0; r--) {
          if (_grid[r][c] == -1) {
            // Find nearest block above
            int k = r - 1;
            while (k >= 0 && _grid[k][c] == -1) {
              k--;
            }
            if (k >= 0) {
              _grid[r][c] = _grid[k][c];
              _grid[k][c] = -1;
            } else {
              // Spawn new
              _grid[r][c] = _random.nextInt(tileColors.length);
            }
          }
        }
      }
    });

    return true; // We found matches, so we need to check again for cascades
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Final Score: $_score", style: const TextStyle(fontSize: 24)),
            if (_score >= _highScore && _score > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text("NEW HIGH SCORE!", style: TextStyle(color: Colors.amber[700], fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _startNewGame();
              });
            },
            child: const Text("Play Again"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Match-3"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Hint button (v1.0.1)
          IconButton(
            onPressed: _hintsRemaining > 0 ? _showHint : null,
            icon: Badge(
              label: Text('$_hintsRemaining'),
              child: Icon(Icons.lightbulb, color: _hintsRemaining > 0 ? Colors.amber : Colors.grey),
            ),
          ),
          // Shuffle button (v1.0.1)
          IconButton(
            onPressed: _shuffleGrid,
            icon: const Icon(Icons.shuffle, color: primaryColor),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Moves: $_movesLeft",
              style: TextStyle(
                color: _movesLeft < 5 ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Score Board
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Score: $_score",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 20),
                Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                const SizedBox(width: 4),
                Text(
                  "$_highScore",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(4),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: gridSize * gridSize,
                    itemBuilder: (context, index) {
                      int row = index ~/ gridSize;
                      int col = index % gridSize;
                      int colorIndex = _grid[row][col];
                      
                      bool isSelected = _selectedRow == row && _selectedCol == col;
                      bool isHinted = (row == _hintRow1 && col == _hintCol1) ||
                                      (row == _hintRow2 && col == _hintCol2);

                      return GestureDetector(
                        onTap: () => _onTileTap(row, col),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: colorIndex == -1 
                                ? Colors.transparent 
                                : tileColors[colorIndex],
                            borderRadius: BorderRadius.circular(4),
                            border: isSelected 
                                ? Border.all(color: Colors.black, width: 3) 
                                : isHinted
                                    ? Border.all(color: Colors.amber, width: 3)
                                    : null,
                            boxShadow: isSelected || isHinted
                                ? [BoxShadow(color: isHinted ? Colors.amber.withOpacity(0.5) : Colors.black26, blurRadius: 4)] 
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
