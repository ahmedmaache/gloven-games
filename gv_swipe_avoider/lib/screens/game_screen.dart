import 'dart:async';
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
  
  // Player position (0, 1, 2 for left, center, right lanes)
  int _playerLane = 1; // Start in center
  
  // Obstacles and coins
  List<Obstacle> _obstacles = [];
  List<Coin> _coins = []; // v1.0.1: Collectible coins
  
  // Game state
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _highScore = 0;
  int _coinCount = 0;
  double _currentSpeed = baseObstacleSpeed;
  
  // v1.0.1: Shield power-up
  bool _hasShield = false;
  int _shieldHits = 0;
  
  // Timer
  Timer? _gameTimer;
  Timer? _spawnTimer;
  Timer? _coinTimer;
  
  // Screen dimensions
  double _screenWidth = 0;
  double _screenHeight = 0;
  double _laneWidth = 0;
  
  // Player/obstacle sizes
  final double _playerSize = 50;
  final double _obstacleHeight = 60;
  final double _obstacleWidth = 50;
  final double _coinSize = 30;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('swipe_avoider_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('swipe_avoider_high_score', _score);
      setState(() {
        _highScore = _score;
      });
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _coinTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _coinCount = 0;
      _playerLane = 1;
      _obstacles.clear();
      _coins.clear();
      _currentSpeed = baseObstacleSpeed;
      _hasShield = false;
      _shieldHits = 0;
    });

    // Game loop - runs every 16ms (~60fps)
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _updateGame();
    });

    // Spawn obstacles
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      _spawnObstacle();
    });

    // v1.0.1: Spawn coins
    _coinTimer = Timer.periodic(const Duration(milliseconds: 2000), (_) {
      _spawnCoin();
    });

    // Increase difficulty over time
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentSpeed += speedIncrement;
      });
    });
  }

  void _spawnObstacle() {
    if (!_isPlaying) return;
    
    int lane = _random.nextInt(laneCount);
    setState(() {
      _obstacles.add(Obstacle(lane: lane, y: -_obstacleHeight));
    });
  }

  void _spawnCoin() {
    if (!_isPlaying) return;
    
    int lane = _random.nextInt(laneCount);
    // 20% chance to spawn a shield power-up instead of coin
    bool isShield = _random.nextDouble() < 0.2;
    
    setState(() {
      _coins.add(Coin(lane: lane, y: -_coinSize, isShield: isShield));
    });
  }

  void _updateGame() {
    if (!_isPlaying || _isGameOver) return;

    setState(() {
      // Move obstacles down
      for (var obs in _obstacles) {
        obs.y += _currentSpeed;
      }

      // Move coins down
      for (var coin in _coins) {
        coin.y += _currentSpeed;
      }

      // Remove off-screen obstacles and add score
      _obstacles.removeWhere((obs) {
        if (obs.y > _screenHeight) {
          _score++;
          return true;
        }
        return false;
      });

      // Remove off-screen coins
      _coins.removeWhere((coin) => coin.y > _screenHeight);

      // Check coin collection
      double playerY = _screenHeight - 100 - _playerSize;
      double playerX = _playerLane * _laneWidth + (_laneWidth - _playerSize) / 2;

      _coins.removeWhere((coin) {
        double coinX = coin.lane * _laneWidth + (_laneWidth - _coinSize) / 2;
        
        bool collisionX = playerX < coinX + _coinSize && 
                          playerX + _playerSize > coinX;
        bool collisionY = playerY < coin.y + _coinSize && 
                          playerY + _playerSize > coin.y;

        if (collisionX && collisionY) {
          if (coin.isShield) {
            // v1.0.1: Activate shield
            _hasShield = true;
            _shieldHits = 2; // Shield blocks 2 hits
          } else {
            _coinCount++;
            _score += 5; // Bonus points for coins
          }
          return true;
        }
        return false;
      });

      // Collision detection with obstacles
      for (var obs in _obstacles) {
        double obsX = obs.lane * _laneWidth + (_laneWidth - _obstacleWidth) / 2;
        
        // Check AABB collision
        bool collisionX = playerX < obsX + _obstacleWidth && 
                          playerX + _playerSize > obsX;
        bool collisionY = playerY < obs.y + _obstacleHeight && 
                          playerY + _playerSize > obs.y;

        if (collisionX && collisionY) {
          if (_hasShield && _shieldHits > 0) {
            // Shield absorbs hit
            _shieldHits--;
            _obstacles.remove(obs);
            if (_shieldHits <= 0) {
              _hasShield = false;
            }
            return;
          }
          _gameOver();
          return;
        }
      }
    });
  }

  void _gameOver() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _coinTimer?.cancel();
    _saveHighScore();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });
  }

  void _onSwipe(DragEndDetails details) {
    if (!_isPlaying || _isGameOver) return;

    double dx = details.velocity.pixelsPerSecond.dx;
    
    setState(() {
      if (dx > 0 && _playerLane < laneCount - 1) {
        // Swipe right
        _playerLane++;
      } else if (dx < 0 && _playerLane > 0) {
        // Swipe left
        _playerLane--;
      }
    });
  }

  void _onTapSide(TapUpDetails details) {
    if (!_isPlaying) {
      _startGame();
      return;
    }
    if (_isGameOver) return;

    double tapX = details.globalPosition.dx;
    
    setState(() {
      if (tapX > _screenWidth / 2 && _playerLane < laneCount - 1) {
        _playerLane++;
      } else if (tapX < _screenWidth / 2 && _playerLane > 0) {
        _playerLane--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          _screenWidth = constraints.maxWidth;
          _screenHeight = constraints.maxHeight;
          _laneWidth = _screenWidth / laneCount;

          return GestureDetector(
            onHorizontalDragEnd: _onSwipe,
            onTapUp: _onTapSide,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[900]!,
                    Colors.grey[800]!,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Lane dividers
                  ..._buildLaneDividers(),

                  // Coins
                  ..._coins.map((coin) => _buildCoin(coin)),

                  // Obstacles
                  ..._obstacles.map((obs) => _buildObstacle(obs)),

                  // Player
                  _buildPlayer(),

                  // Score and coin count
                  Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Text(
                          _score.toString(),
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events, color: Colors.amber.withOpacity(0.5), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$_highScore',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.monetization_on, color: Colors.amber.withOpacity(0.7), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$_coinCount',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.amber.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Shield indicator
                  if (_hasShield)
                    Positioned(
                      top: 130,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shield, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "SHIELD x$_shieldHits",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Start overlay
                  if (!_isPlaying && !_isGameOver)
                    _buildStartOverlay(),

                  // Game Over overlay
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

  List<Widget> _buildLaneDividers() {
    return [
      for (int i = 1; i < laneCount; i++)
        Positioned(
          left: i * _laneWidth - 1,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
    ];
  }

  Widget _buildPlayer() {
    double playerX = _playerLane * _laneWidth + (_laneWidth - _playerSize) / 2;
    double playerY = _screenHeight - 100 - _playerSize;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      left: playerX,
      top: playerY,
      child: Container(
        width: _playerSize,
        height: _playerSize,
        decoration: BoxDecoration(
          color: _hasShield ? Colors.cyan : playerColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (_hasShield ? Colors.cyan : playerColor).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
          border: _hasShield ? Border.all(color: Colors.white, width: 3) : null,
        ),
        child: Icon(
          _hasShield ? Icons.shield : Icons.rocket_launch,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildObstacle(Obstacle obs) {
    double obsX = obs.lane * _laneWidth + (_laneWidth - _obstacleWidth) / 2;

    return Positioned(
      left: obsX,
      top: obs.y,
      child: Container(
        width: _obstacleWidth,
        height: _obstacleHeight,
        decoration: BoxDecoration(
          color: obstacleColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: obstacleColor.withOpacity(0.5),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Icon(
          Icons.warning,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCoin(Coin coin) {
    double coinX = coin.lane * _laneWidth + (_laneWidth - _coinSize) / 2;

    return Positioned(
      left: coinX,
      top: coin.y,
      child: Container(
        width: _coinSize,
        height: _coinSize,
        decoration: BoxDecoration(
          color: coin.isShield ? Colors.cyan : Colors.amber,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (coin.isShield ? Colors.cyan : Colors.amber).withOpacity(0.5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(
          coin.isShield ? Icons.shield : Icons.monetization_on,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildStartOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "SWIPE TO DODGE",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Collect coins for bonus points!",
              style: TextStyle(
                fontSize: 14,
                color: Colors.amber.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "🛡️ Shields protect you from obstacles",
              style: TextStyle(
                fontSize: 14,
                color: Colors.cyan.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Tap anywhere to start",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
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
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "GAME OVER",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Score: $_score",
                style: TextStyle(
                  fontSize: 24,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    "Coins: $_coinCount",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              if (_score >= _highScore && _score > 0) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      "NEW HIGH SCORE!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[400],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
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

class Obstacle {
  int lane;
  double y;

  Obstacle({required this.lane, required this.y});
}

class Coin {
  int lane;
  double y;
  bool isShield;

  Coin({required this.lane, required this.y, this.isShield = false});
}
