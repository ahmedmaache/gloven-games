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

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final Random _random = Random();
  
  // Game state
  bool _isWaiting = true; // Waiting for target to appear
  bool _isGameOver = false;
  int _currentRound = 0;
  
  // Target position
  double _targetX = 0;
  double _targetY = 0;
  double _targetSize = 70;
  bool _targetVisible = false;
  
  // Timing
  late Stopwatch _reactionStopwatch;
  List<int> _reactionTimes = [];
  Timer? _appearTimer;
  
  // v1.0.1: Miss penalty countdown
  Timer? _missTimer;
  int _missCountdown = 0;
  bool _isMissed = false;
  
  // v1.0.1: Streak bonus
  int _streak = 0;
  int _maxStreak = 0;
  int _bestAverage = 0;
  
  // Screen dimensions
  double _screenWidth = 0;
  double _screenHeight = 0;
  
  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _reactionStopwatch = Stopwatch();
    _loadBestScore();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Start first round after a delay
    _scheduleNextTarget();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bestAverage = prefs.getInt('reflex_best_average') ?? 0;
    });
  }

  Future<void> _saveBestScore() async {
    if (_averageReactionTime > 0 && (_bestAverage == 0 || _averageReactionTime < _bestAverage)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reflex_best_average', _averageReactionTime);
      setState(() {
        _bestAverage = _averageReactionTime;
      });
    }
  }

  void _scheduleNextTarget() {
    setState(() {
      _isWaiting = true;
      _targetVisible = false;
      _isMissed = false;
      _missCountdown = 0;
    });

    // Random delay between 1-3 seconds
    int delayMs = 1000 + _random.nextInt(2000);
    
    _appearTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted || _isGameOver) return;
      _showTarget();
    });
  }

  void _showTarget() {
    // Calculate safe area for target
    double padding = 50;
    double safeWidth = _screenWidth - _targetSize - padding * 2;
    double safeHeight = _screenHeight - _targetSize - padding * 2 - 150; // Account for UI
    
    setState(() {
      _targetX = padding + _random.nextDouble() * safeWidth;
      _targetY = padding + 100 + _random.nextDouble() * safeHeight; // 100 for top UI
      _targetSize = targetMinSize + _random.nextDouble() * (targetMaxSize - targetMinSize);
      _targetVisible = true;
      _isWaiting = false;
    });

    _reactionStopwatch.reset();
    _reactionStopwatch.start();
    
    // v1.0.1: Start miss countdown timer (2 seconds to tap)
    _missCountdown = 2000;
    _missTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !_targetVisible) {
        timer.cancel();
        return;
      }
      setState(() {
        _missCountdown -= 100;
        if (_missCountdown <= 0) {
          // Missed!
          timer.cancel();
          _onMissed();
        }
      });
    });
  }

  void _onMissed() {
    _reactionStopwatch.stop();
    _missTimer?.cancel();
    
    setState(() {
      _isMissed = true;
      _targetVisible = false;
      _streak = 0; // Reset streak
      _currentRound++;
    });
    
    if (_currentRound >= totalRounds) {
      _endGame();
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _scheduleNextTarget();
      });
    }
  }

  void _onTargetTapped() {
    if (!_targetVisible || _isGameOver) return;

    _reactionStopwatch.stop();
    _missTimer?.cancel();
    int reactionMs = _reactionStopwatch.elapsedMilliseconds;
    
    setState(() {
      _reactionTimes.add(reactionMs);
      _currentRound++;
      _targetVisible = false;
      
      // v1.0.1: Streak tracking
      _streak++;
      if (_streak > _maxStreak) _maxStreak = _streak;
    });

    if (_currentRound >= totalRounds) {
      _endGame();
    } else {
      _scheduleNextTarget();
    }
  }

  void _endGame() {
    _saveBestScore();
    setState(() {
      _isGameOver = true;
    });
  }

  void _restartGame() {
    setState(() {
      _reactionTimes.clear();
      _currentRound = 0;
      _isGameOver = false;
      _streak = 0;
      _maxStreak = 0;
    });
    _scheduleNextTarget();
  }

  int get _averageReactionTime {
    if (_reactionTimes.isEmpty) return 0;
    return (_reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length).round();
  }

  int get _bestReactionTime {
    if (_reactionTimes.isEmpty) return 0;
    return _reactionTimes.reduce((a, b) => a < b ? a : b);
  }

  @override
  void dispose() {
    _appearTimer?.cancel();
    _missTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          _screenWidth = constraints.maxWidth;
          _screenHeight = constraints.maxHeight;

          return Stack(
            children: [
              // Top bar
              _buildTopBar(),

              // Target
              if (_targetVisible)
                Positioned(
                  left: _targetX,
                  top: _targetY,
                  child: GestureDetector(
                    onTap: _onTargetTapped,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: _targetSize,
                            height: _targetSize,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: iconShape == "circle" 
                                  ? BoxShape.circle 
                                  : BoxShape.rectangle,
                              borderRadius: iconShape == "square" 
                                  ? BorderRadius.circular(12) 
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.touch_app,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          // v1.0.1: Countdown ring
                          if (_missCountdown > 0)
                            SizedBox(
                              width: _targetSize,
                              height: _targetSize,
                              child: CircularProgressIndicator(
                                value: _missCountdown / 2000,
                                strokeWidth: 4,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation(
                                  _missCountdown > 500 ? Colors.white : Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Waiting message
              if (_isWaiting && !_isGameOver)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Get Ready...",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(primaryColor),
                        ),
                      ),
                      if (_streak > 2) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "🔥 Streak: $_streak",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              // Missed message
              if (_isMissed)
                Center(
                  child: Text(
                    "MISS! ❌",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[400],
                    ),
                  ),
                ),

              // Game Over Overlay
              if (_isGameOver)
                _buildGameOverOverlay(),

              // Back button
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("Round", "$_currentRound/$totalRounds"),
            _buildStatItem("Last", _reactionTimes.isNotEmpty 
                ? "${_reactionTimes.last}ms" 
                : "--"),
            _buildStatItem("Best", _bestReactionTime > 0 
                ? "${_bestReactionTime}ms" 
                : "--"),
            _buildStatItem("🔥", "$_streak"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryColor,
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

  Widget _buildGameOverOverlay() {
    bool isNewBest = _bestAverage == 0 || (_averageReactionTime > 0 && _averageReactionTime <= _bestAverage);
    
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 60,
                color: Colors.amber,
              ),
              const SizedBox(height: 20),
              const Text(
                "Results",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              _buildResultRow("⚡ Average", "${_averageReactionTime}ms"),
              const SizedBox(height: 12),
              _buildResultRow("🏆 Best", "${_bestReactionTime}ms"),
              const SizedBox(height: 12),
              _buildResultRow("📊 Rounds", "$_currentRound"),
              const SizedBox(height: 12),
              _buildResultRow("🔥 Max Streak", "$_maxStreak"),
              if (isNewBest && _averageReactionTime > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "⭐ NEW BEST AVERAGE!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (_bestAverage > 0) ...[
                const SizedBox(height: 8),
                Text(
                  "All-time best: ${_bestAverage}ms",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _restartGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to Menu"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }
}
