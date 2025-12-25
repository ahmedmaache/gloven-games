import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final Random _random = Random();

  // Game State
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _highScore = 0;
  
  // Physics
  double _playerY = 0.0;
  double _playerVelocity = 0.0;
  
  // Double Jump Feature (v1.0.1)
  int _jumpsRemaining = 2;
  static const int maxJumps = 2;
  
  // Obstacles (store X positions)
  List<double> _obstacles = [];
  double _timeSinceLastObstacle = 0.0;
  double _nextObstacleInterval = 0.0;

  // Screen dimensions (updated in build/layout)
  double _screenWidth = 0.0;
  double _screenHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _loadHighScore();
    _resetGame();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('runner_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('runner_high_score', _score);
      setState(() {
        _highScore = _score;
      });
    }
  }

  void _resetGame() {
    setState(() {
      _isPlaying = false;
      _isGameOver = false;
      _score = 0;
      _playerY = 0.0;
      _playerVelocity = 0.0;
      _jumpsRemaining = maxJumps;
      _obstacles.clear();
      _timeSinceLastObstacle = 0.0;
      _nextObstacleInterval = 100.0; // Initial gap
    });
  }

  void _startGame() {
    _resetGame();
    setState(() {
      _isPlaying = true;
    });
    _ticker.start();
  }

  void _gameOver() {
    _ticker.stop();
    _saveHighScore();
    setState(() {
      _isGameOver = true;
      _isPlaying = false;
    });
  }

  void _onTick(Duration elapsed) {
    if (!_isPlaying || _isGameOver) return;

    setState(() {
      // 1. Update Player Physics
      _playerVelocity += gravity;
      _playerY -= _playerVelocity; 
      
      // Hit the Ground
      if (_playerY <= 0) {
        _playerY = 0;
        _playerVelocity = 0;
        _jumpsRemaining = maxJumps; // Reset jumps when landing
      }

      // 2. Spawn Obstacles
      _timeSinceLastObstacle += obstacleSpeed;
      if (_timeSinceLastObstacle >= _nextObstacleInterval) {
        _obstacles.add(_screenWidth + 50); // Spawn off-screen right
        _timeSinceLastObstacle = 0.0;
        // Randomize next gap (between 250 and 500 distance units)
        _nextObstacleInterval = 300.0 + _random.nextInt(300); 
      }

      // 3. Move Obstacles & Score
      for (int i = 0; i < _obstacles.length; i++) {
        _obstacles[i] -= obstacleSpeed;
      }

      // Remove off-screen obstacles and increment score
      if (_obstacles.isNotEmpty && _obstacles.first < -50) {
        _obstacles.removeAt(0);
        _score++;
        // Speed up slightly as score increases (optional challenge)
      }

      // 4. Collision Detection
      // Player is approx at X=50, width=40. Obstacle width=40.
      const double playerX = 60.0; 
      const double playerSize = 40.0;
      const double obstacleSize = 40.0;

      for (double obsX in _obstacles) {
        // Simple AABB collision
        // Horizontal overlap
        bool collisionX = (obsX < playerX + playerSize - 10) && (obsX + obstacleSize > playerX + 10);
        // Vertical overlap (Player Y is distance from ground. Obstacle is on ground)
        bool collisionY = _playerY < obstacleSize - 5; // -5 generous hitbox

        if (collisionX && collisionY) {
          _gameOver();
        }
      }
    });
  }

  void _jump() {
    if (_isGameOver) {
      _startGame();
      return;
    }
    if (!_isPlaying) {
      _startGame();
      return;
    }

    // Double jump feature: can jump if we have jumps remaining
    if (_jumpsRemaining > 0) {
      _playerVelocity = jumpStrength; 
      _jumpsRemaining--;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          _screenWidth = constraints.maxWidth;
          _screenHeight = constraints.maxHeight;

          return GestureDetector(
            onTap: _jump,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                // Background
                Container(color: Colors.blueGrey[50]),

                // Game World Painting
                CustomPaint(
                  painter: RunnerPainter(
                    playerY: _playerY,
                    obstacles: _obstacles,
                    primaryColor: primaryColor,
                  ),
                  size: Size.infinite,
                ),

                // Score and High Score
                Positioned(
                  top: 50,
                  right: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _score.toString(),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[300],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emoji_events, color: Colors.amber[300], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$_highScore',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Jump indicator (v1.0.1)
                if (_isPlaying)
                  Positioned(
                    top: 50,
                    left: 20,
                    child: Row(
                      children: List.generate(maxJumps, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.arrow_upward,
                            size: 24,
                            color: index < _jumpsRemaining 
                                ? primaryColor 
                                : Colors.grey[300],
                          ),
                        );
                      }),
                    ),
                  ),

                // Start / Game Over UI overlay
                if (!_isPlaying && !_isGameOver)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Tap to Start", style: TextStyle(fontSize: 24, color: primaryColor)),
                        const SizedBox(height: 8),
                        Text(
                          "Double-tap to double jump!",
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),

                if (_isGameOver)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "GAME OVER",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Score: $_score",
                              style: const TextStyle(fontSize: 20),
                            ),
                            if (_score >= _highScore && _score > 0) ...[
                              const SizedBox(height: 5),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    "NEW HIGH SCORE!",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _startGame,
                              child: const Text("Try Again"),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RunnerPainter extends CustomPainter {
  final double playerY;
  final List<double> obstacles;
  final Color primaryColor;

  RunnerPainter({
    required this.playerY,
    required this.obstacles,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Ground
    final groundPaint = Paint()..color = Colors.grey[400]!;
    final groundY = size.height - groundHeight;
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, groundHeight),
      groundPaint,
    );

    // Player (Simple Cube or Circle being "Startup Inc")
    // Fixed X position: 60
    final playerPaint = Paint()..color = primaryColor;
    const double playerX = 60;
    const double playerSize = 40;
    
    // Y is distance FROM ground.
    // Top of player rect = groundY - playerY - playerSize
    final playerRect = Rect.fromLTWH(
      playerX,
      groundY - playerY - playerSize,
      playerSize,
      playerSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(playerRect, const Radius.circular(8)),
      playerPaint,
    );

    // Obstacles (Spikes or Blocks)
    final obstaclePaint = Paint()..color = Colors.redAccent;
    const double maxObsHeight = 40;

    for (double obsX in obstacles) {
      // Draw obstacle
      final obsRect = Rect.fromLTWH(
        obsX,
        groundY - maxObsHeight,
        40, // width
        maxObsHeight, // height
      );
       canvas.drawRRect(
        RRect.fromRectAndRadius(obsRect, const Radius.circular(4)),
        obstaclePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RunnerPainter oldDelegate) {
    return oldDelegate.playerY != playerY || oldDelegate.obstacles != obstacles;
  }
}
