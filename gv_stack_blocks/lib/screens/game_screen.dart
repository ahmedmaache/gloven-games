import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Stacked blocks: List of (x position, width)
  List<StackedBlock> _stackedBlocks = [];
  
  // Current moving block
  double _currentBlockX = 0;
  double _currentBlockWidth = blockWidth;
  bool _movingRight = true;
  
  // Dropping state
  bool _isDropping = false;
  double _droppingY = 0;
  double _droppingBlockX = 0;
  double _droppingBlockWidth = 0;
  
  // Game state
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _highScore = 0;
  
  // v1.0.1: Perfect landing bonus
  int _perfectStreak = 0;
  bool _lastWasPerfect = false;
  
  // Screen
  double _screenWidth = 0;
  double _screenHeight = 0;
  
  // Timer
  Timer? _gameTimer;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('stack_blocks_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('stack_blocks_high_score', _score);
      setState(() {
        _highScore = _score;
      });
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _stackedBlocks = [];
      _score = 0;
      _isGameOver = false;
      _isPlaying = true;
      _isDropping = false;
      _currentBlockWidth = blockWidth;
      _currentBlockX = 0;
      _movingRight = true;
      _perfectStreak = 0;
      _lastWasPerfect = false;
      
      // Add base block
      _stackedBlocks.add(StackedBlock(
        x: (_screenWidth - blockWidth) / 2,
        width: blockWidth,
        y: _screenHeight - blockHeight - 50, // 50 from bottom
      ));
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _updateGame();
    });
  }

  void _updateGame() {
    if (!_isPlaying || _isGameOver) return;

    setState(() {
      if (_isDropping) {
        // Animate block dropping
        _droppingY += dropSpeed;
        
        // Calculate target Y (top of stack)
        double targetY = _getStackTopY() - blockHeight;
        
        if (_droppingY >= targetY) {
          // Block landed
          _droppingY = targetY;
          _landBlock();
        }
      } else {
        // Move block horizontally
        if (_movingRight) {
          _currentBlockX += blockSpeed;
          if (_currentBlockX + _currentBlockWidth >= _screenWidth) {
            _movingRight = false;
          }
        } else {
          _currentBlockX -= blockSpeed;
          if (_currentBlockX <= 0) {
            _movingRight = true;
          }
        }
      }
    });
  }

  double _getStackTopY() {
    if (_stackedBlocks.isEmpty) {
      return _screenHeight - 50;
    }
    return _stackedBlocks.last.y;
  }

  void _dropBlock() {
    if (_isDropping || _isGameOver || !_isPlaying) return;

    setState(() {
      _isDropping = true;
      _droppingBlockX = _currentBlockX;
      _droppingBlockWidth = _currentBlockWidth;
      _droppingY = 60; // Start from top
    });
  }

  void _landBlock() {
    // Calculate overlap with previous block
    StackedBlock lastBlock = _stackedBlocks.last;
    
    double overlapStart = _droppingBlockX > lastBlock.x 
        ? _droppingBlockX 
        : lastBlock.x;
    double overlapEnd = (_droppingBlockX + _droppingBlockWidth) < (lastBlock.x + lastBlock.width)
        ? (_droppingBlockX + _droppingBlockWidth)
        : (lastBlock.x + lastBlock.width);
    
    double overlapWidth = overlapEnd - overlapStart;

    if (overlapWidth <= 0) {
      // Complete miss - game over
      _gameOver();
      return;
    }

    // v1.0.1: Check for perfect landing (overlap within 5 pixels of target)
    double diff = (overlapWidth - lastBlock.width).abs();
    bool isPerfect = diff < 5;
    
    if (isPerfect) {
      _perfectStreak++;
      _lastWasPerfect = true;
      // Perfect landing: restore some width!
      overlapWidth = (overlapWidth + 5).clamp(0, blockWidth);
    } else {
      _perfectStreak = 0;
      _lastWasPerfect = false;
    }

    // Add the overlapping portion as new block
    _stackedBlocks.add(StackedBlock(
      x: overlapStart,
      width: overlapWidth,
      y: _getStackTopY() - blockHeight,
      isPerfect: isPerfect,
    ));

    // v1.0.1: Bonus points for perfect streak
    int bonus = isPerfect ? (1 + _perfectStreak) : 1;
    _score += bonus;
    
    // Setup next block with trimmed width
    _currentBlockWidth = overlapWidth;
    _currentBlockX = 0;
    _movingRight = true;
    _isDropping = false;

    // Check if block is too small
    if (_currentBlockWidth < 10) {
      _gameOver();
    }
  }

  void _gameOver() {
    _gameTimer?.cancel();
    _saveHighScore();
    setState(() {
      _isGameOver = true;
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          _screenWidth = constraints.maxWidth;
          _screenHeight = constraints.maxHeight;

          return GestureDetector(
            onTap: () {
              if (!_isPlaying && !_isGameOver) {
                _startGame();
              } else if (_isPlaying && !_isDropping) {
                _dropBlock();
              } else if (_isGameOver) {
                _startGame();
              }
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.indigo[900]!,
                    Colors.indigo[700]!,
                    primaryColor,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Stacked blocks
                  ..._stackedBlocks.map((block) => _buildBlock(
                    block.x, 
                    block.y, 
                    block.width,
                    isStacked: true,
                    isPerfect: block.isPerfect,
                  )),

                  // Dropping block
                  if (_isDropping)
                    _buildBlock(
                      _droppingBlockX,
                      _droppingY,
                      _droppingBlockWidth,
                    ),

                  // Moving block at top
                  if (_isPlaying && !_isDropping)
                    _buildBlock(
                      _currentBlockX,
                      60,
                      _currentBlockWidth,
                    ),

                  // Score and High Score
                  Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Text(
                          _score.toString(),
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events, color: Colors.amber.withOpacity(0.5), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '$_highScore',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // v1.0.1: Perfect streak indicator
                  if (_lastWasPerfect && _isPlaying)
                    Positioned(
                      top: 160,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _lastWasPerfect ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "⭐ PERFECT! +${1 + _perfectStreak}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Start overlay
                  if (!_isPlaying && !_isGameOver)
                    _buildStartOverlay(),

                  // Game over overlay
                  if (_isGameOver)
                    _buildGameOverOverlay(),

                  // Back button
                  Positioned(
                    top: 40,
                    left: 10,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlock(double x, double y, double width, {bool isStacked = false, bool isPerfect = false}) {
    // Generate color based on stack position
    int index = isStacked ? _stackedBlocks.indexWhere((b) => b.x == x && b.y == y) : -1;
    Color color = _getBlockColor(index);

    return Positioned(
      left: x,
      top: y,
      child: Container(
        width: width,
        height: blockHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: isPerfect ? Border.all(color: Colors.amber, width: 2) : null,
        ),
      ),
    );
  }

  Color _getBlockColor(int index) {
    if (index < 0) return blockColor;
    
    List<Color> colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF8BC34A),
      const Color(0xFFCDDC39),
      const Color(0xFFFFEB3B),
      const Color(0xFFFFC107),
      const Color(0xFFFF9800),
      const Color(0xFFFF5722),
      const Color(0xFFF44336),
    ];
    
    return colors[index % colors.length];
  }

  Widget _buildStartOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.touch_app,
              size: 60,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              "TAP TO START",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: blockColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Land perfectly for bonus points!",
              style: TextStyle(
                fontSize: 14,
                color: Colors.amber[200],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "TOWER COLLAPSED!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Blocks Stacked",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                "$_score",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              if (_score >= _highScore && _score > 0) ...[
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
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blockColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "TRY AGAIN",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StackedBlock {
  final double x;
  final double width;
  final double y;
  final bool isPerfect;

  StackedBlock({required this.x, required this.width, required this.y, this.isPerfect = false});
}
