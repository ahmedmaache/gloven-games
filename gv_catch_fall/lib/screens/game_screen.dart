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
  
  // Basket position
  double _basketX = 0;
  
  // Falling objects
  List<FallingObject> _objects = [];
  
  // Game state
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _highScore = 0;
  int _misses = 0;
  double _currentFallSpeed = fallSpeed;
  
  // Combo system (v1.0.1)
  int _combo = 0;
  int _maxCombo = 0;
  
  // Power-ups (v1.0.1)
  bool _wideBasket = false;
  double _currentBasketWidth = basketWidth;
  
  // Screen dimensions
  double _screenWidth = 0;
  double _screenHeight = 0;
  
  // Timers
  Timer? _gameTimer;
  Timer? _spawnTimer;
  Timer? _powerUpTimer;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('catch_fall_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('catch_fall_high_score', _score);
      setState(() {
        _highScore = _score;
      });
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _powerUpTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _objects.clear();
      _score = 0;
      _misses = 0;
      _combo = 0;
      _maxCombo = 0;
      _isGameOver = false;
      _isPlaying = true;
      _currentFallSpeed = fallSpeed;
      _wideBasket = false;
      _currentBasketWidth = basketWidth;
      _basketX = (_screenWidth - basketWidth) / 2;
    });

    // Game loop
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _updateGame();
    });

    // Spawn objects
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      _spawnObject();
    });

    // Increase difficulty
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentFallSpeed += 1.0;
      });
    });
  }

  void _spawnObject() {
    if (!_isPlaying) return;
    
    double padding = 20;
    double x = padding + _random.nextDouble() * (_screenWidth - objectSize - padding * 2);
    
    // 10% chance to spawn a power-up (v1.0.1)
    bool isPowerUp = _random.nextDouble() < 0.1;
    
    setState(() {
      _objects.add(FallingObject(x: x, y: -objectSize, isPowerUp: isPowerUp));
    });
  }

  void _updateGame() {
    if (!_isPlaying || _isGameOver) return;

    setState(() {
      // Move objects down
      for (var obj in _objects) {
        obj.y += _currentFallSpeed;
      }

      // Check catches and misses
      List<FallingObject> toRemove = [];
      
      for (var obj in _objects) {
        // Check if caught
        double basketTop = _screenHeight - basketHeight - 30;
        double basketLeft = _basketX;
        double basketRight = _basketX + _currentBasketWidth;
        
        bool horizontalHit = (obj.x + objectSize / 2) > basketLeft && 
                             (obj.x + objectSize / 2) < basketRight;
        bool verticalHit = obj.y + objectSize >= basketTop && 
                           obj.y + objectSize <= basketTop + basketHeight;

        if (horizontalHit && verticalHit) {
          if (obj.isPowerUp) {
            // Activate wide basket power-up
            _activateWideBasket();
          } else {
            _combo++;
            if (_combo > _maxCombo) _maxCombo = _combo;
            // Combo bonus: 1 + combo/5 multiplier
            int comboBonus = 1 + (_combo ~/ 5);
            _score += comboBonus;
          }
          toRemove.add(obj);
        }
        // Check if missed (fell past basket)
        else if (obj.y > _screenHeight) {
          if (!obj.isPowerUp) {
            _misses++;
            _combo = 0; // Reset combo on miss
          }
          toRemove.add(obj);
          
          if (_misses >= maxMisses) {
            _gameOver();
          }
        }
      }

      _objects.removeWhere((obj) => toRemove.contains(obj));
    });
  }

  void _activateWideBasket() {
    _powerUpTimer?.cancel();
    setState(() {
      _wideBasket = true;
      _currentBasketWidth = basketWidth * 1.5;
    });
    
    _powerUpTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _wideBasket = false;
        _currentBasketWidth = basketWidth;
      });
    });
  }

  void _gameOver() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _saveHighScore();
    setState(() {
      _isGameOver = true;
      _isPlaying = false;
    });
  }

  void _onDrag(DragUpdateDetails details) {
    if (!_isPlaying) return;
    
    setState(() {
      _basketX += details.delta.dx;
      
      // Clamp to screen bounds
      if (_basketX < 0) _basketX = 0;
      if (_basketX > _screenWidth - _currentBasketWidth) {
        _basketX = _screenWidth - _currentBasketWidth;
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

          return GestureDetector(
            onHorizontalDragUpdate: _onDrag,
            onTap: () {
              if (!_isPlaying && !_isGameOver) {
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
                    Colors.lightBlue[200]!,
                    Colors.lightBlue[400]!,
                    Colors.green[300]!,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Top UI
                  _buildTopUI(),

                  // Falling objects
                  ..._objects.map((obj) => _buildFallingObject(obj)),

                  // Basket
                  if (_isPlaying || _isGameOver)
                    _buildBasket(),

                  // Lives indicator
                  _buildLivesIndicator(),

                  // Combo indicator (v1.0.1)
                  if (_isPlaying && _combo > 0)
                    _buildComboIndicator(),

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
                      icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.8)),
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

  Widget _buildComboIndicator() {
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedOpacity(
          opacity: _combo > 2 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "🔥 COMBO x$_combo",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopUI() {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: objectColor, size: 28),
              const SizedBox(width: 10),
              Text(
                "$_score",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                "$_highScore",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLivesIndicator() {
    int livesLeft = maxMisses - _misses;
    
    return Positioned(
      top: 50,
      right: 20,
      child: Row(
        children: List.generate(maxMisses, (index) {
          return Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Icons.favorite,
              color: index < livesLeft ? Colors.red : Colors.grey[400],
              size: 24,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFallingObject(FallingObject obj) {
    return Positioned(
      left: obj.x,
      top: obj.y,
      child: Container(
        width: objectSize,
        height: objectSize,
        decoration: BoxDecoration(
          color: obj.isPowerUp ? Colors.purple : objectColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (obj.isPowerUp ? Colors.purple : objectColor).withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          obj.isPowerUp ? Icons.expand : Icons.star,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildBasket() {
    return Positioned(
      left: _basketX,
      bottom: 30,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _currentBasketWidth,
        height: basketHeight,
        decoration: BoxDecoration(
          color: _wideBasket ? Colors.purple : basketColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.shopping_basket,
          color: Colors.white,
          size: 28,
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
            Icon(
              Icons.star,
              size: 80,
              color: objectColor,
            ),
            const SizedBox(height: 20),
            const Text(
              "TAP TO START",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Drag to move the basket",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "🟣 Catch purple stars for power-ups!",
              style: TextStyle(
                fontSize: 14,
                color: Colors.purple[200],
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
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "GAME OVER",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: objectColor, size: 40),
                  const SizedBox(width: 10),
                  Text(
                    "$_score",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Stars Caught",
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              if (_maxCombo > 2) ...[
                const SizedBox(height: 8),
                Text(
                  "🔥 Max Combo: $_maxCombo",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
              if (_score >= _highScore && _score > 0) ...[
                const SizedBox(height: 8),
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
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "PLAY AGAIN",
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

class FallingObject {
  double x;
  double y;
  bool isPowerUp;

  FallingObject({required this.x, required this.y, this.isPowerUp = false});
}
