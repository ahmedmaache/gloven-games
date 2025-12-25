import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../providers/game_settings_provider.dart';

/// Game Screen - v1.0.2
/// - Added support for difficulty-based grid sizes
/// - Added haptic feedback
/// - Improved animations
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Card model
  late List<CardModel> _cards;
  
  // Game state
  int _moves = 0;
  int _matchedPairs = 0;
  int? _firstFlippedIndex;
  bool _isProcessing = false;
  
  // Grid configuration (based on difficulty)
  late int _gridRows;
  late int _gridCols;
  late int _totalPairs;
  
  // Best time tracking
  int _bestTime = 0;
  int _bestMoves = 0;
  
  // Peek hint
  late int _peeksRemaining;
  bool _isPeeking = false;
  
  // Timer
  late Stopwatch _stopwatch;
  Timer? _timer;
  String _elapsedTime = "00:00";
  
  // Extended icons for larger grids
  static const List<IconData> _allIcons = [
    Icons.star,
    Icons.favorite,
    Icons.bolt,
    Icons.music_note,
    Icons.pets,
    Icons.sports_soccer,
    Icons.cake,
    Icons.flight,
    Icons.anchor,
    Icons.beach_access,
    Icons.camera,
    Icons.directions_car,
    Icons.eco,
    Icons.fireplace,
    Icons.golf_course,
  ];

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<GameSettingsProvider>(context, listen: false);
    _gridRows = settings.gridRows;
    _gridCols = settings.gridCols;
    _totalPairs = settings.totalPairs;
    _peeksRemaining = settings.peeksAllowed;
    _loadBestScore();
    _initGame();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = Provider.of<GameSettingsProvider>(context, listen: false);
    final diffKey = settings.difficulty.name;
    setState(() {
      _bestTime = prefs.getInt('memory_best_time_$diffKey') ?? 0;
      _bestMoves = prefs.getInt('memory_best_moves_$diffKey') ?? 0;
    });
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = Provider.of<GameSettingsProvider>(context, listen: false);
    final diffKey = settings.difficulty.name;
    int currentTime = _stopwatch.elapsed.inSeconds;
    
    if (_bestTime == 0 || currentTime < _bestTime) {
      await prefs.setInt('memory_best_time_$diffKey', currentTime);
      _bestTime = currentTime;
    }
    if (_bestMoves == 0 || _moves < _bestMoves) {
      await prefs.setInt('memory_best_moves_$diffKey', _moves);
      _bestMoves = _moves;
    }
  }

  void _initGame() {
    // Get icons for the current grid size
    List<IconData> icons = _allIcons.take(_totalPairs).toList();
    List<CardModel> cards = [];
    
    for (int i = 0; i < _totalPairs; i++) {
      // Add two cards for each icon (pair)
      cards.add(CardModel(id: i * 2, iconIndex: i, icon: icons[i]));
      cards.add(CardModel(id: i * 2 + 1, iconIndex: i, icon: icons[i]));
    }
    
    // Shuffle
    cards.shuffle(Random());
    
    setState(() {
      _cards = cards;
      _moves = 0;
      _matchedPairs = 0;
      _firstFlippedIndex = null;
      _isProcessing = false;
      _isPeeking = false;
    });
    
    _stopwatch = Stopwatch()..start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        final seconds = _stopwatch.elapsed.inSeconds;
        final mins = (seconds ~/ 60).toString().padLeft(2, '0');
        final secs = (seconds % 60).toString().padLeft(2, '0');
        _elapsedTime = "$mins:$secs";
      });
    });
  }

  void _triggerHaptic() {
    final settings = Provider.of<GameSettingsProvider>(context, listen: false);
    if (settings.vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void _peekCards() {
    if (_peeksRemaining <= 0 || _isProcessing || _isPeeking) return;
    
    _triggerHaptic();
    setState(() {
      _peeksRemaining--;
      _isPeeking = true;
      for (var card in _cards) {
        if (!card.isMatched) {
          card.isFlipped = true;
        }
      }
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isPeeking = false;
        for (var card in _cards) {
          if (!card.isMatched) {
            card.isFlipped = false;
          }
        }
      });
    });
  }

  void _onCardTap(int index) {
    if (_isProcessing || _isPeeking) return;
    if (_cards[index].isFlipped || _cards[index].isMatched) return;

    _triggerHaptic();
    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {
      _moves++;
      _isProcessing = true;
      
      int firstIndex = _firstFlippedIndex!;
      _firstFlippedIndex = null;

      if (_cards[firstIndex].iconIndex == _cards[index].iconIndex) {
        // Match!
        HapticFeedback.mediumImpact();
        setState(() {
          _cards[firstIndex].isMatched = true;
          _cards[index].isMatched = true;
          _matchedPairs++;
          _isProcessing = false;
        });

        if (_matchedPairs == _totalPairs) {
          _stopwatch.stop();
          _timer?.cancel();
          _saveBestScore();
          _showWinDialog();
        }
      } else {
        // No match
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            _cards[firstIndex].isFlipped = false;
            _cards[index].isFlipped = false;
            _isProcessing = false;
          });
        });
      }
    }
  }

  void _showWinDialog() {
    int currentTime = _stopwatch.elapsed.inSeconds;
    bool isNewBestTime = _bestTime == 0 || currentTime <= _bestTime;
    bool isNewBestMoves = _bestMoves == 0 || _moves <= _bestMoves;
    final settings = Provider.of<GameSettingsProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: accentColor),
            const SizedBox(width: 10),
            const Text("You Won!"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${settings.difficultyName} Mode',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text("🎯 Moves: $_moves"),
                if (isNewBestMoves)
                  Text(" ⭐ BEST!", style: TextStyle(color: Colors.amber[700], fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text("⏱️ Time: $_elapsedTime"),
                if (isNewBestTime)
                  Text(" ⭐ BEST!", style: TextStyle(color: Colors.amber[700], fontWeight: FontWeight.bold)),
              ],
            ),
            if (_bestTime > 0) ...[
              const Divider(),
              Text("🏆 Best Time: ${(_bestTime ~/ 60).toString().padLeft(2, '0')}:${(_bestTime % 60).toString().padLeft(2, '0')}",
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              Text("🏆 Best Moves: $_bestMoves",
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final settings = Provider.of<GameSettingsProvider>(context, listen: false);
                _peeksRemaining = settings.peeksAllowed;
                _initGame();
              });
            },
            child: const Text("Play Again"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text("Home"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<GameSettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[100],
      appBar: AppBar(
        title: const Text("Memory Cards"),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Difficulty indicator chip
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                settings.difficultyName,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Peek button
          IconButton(
            onPressed: _peeksRemaining > 0 ? _peekCards : null,
            icon: Badge(
              label: Text('$_peeksRemaining'),
              child: Icon(
                Icons.visibility,
                color: _peeksRemaining > 0 ? Colors.white : Colors.white38,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _timer?.cancel();
              _stopwatch.stop();
              _peeksRemaining = settings.peeksAllowed;
              _initGame();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            color: isDark 
                ? accentColor.withOpacity(0.15) 
                : accentColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat("Moves", _moves.toString(), isDark),
                _buildStat("Pairs", "$_matchedPairs/$_totalPairs", isDark),
                _buildStat("Time", _elapsedTime, isDark),
              ],
            ),
          ),

          // Best score row
          if (_bestTime > 0)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "Best: ${(_bestTime ~/ 60).toString().padLeft(2, '0')}:${(_bestTime % 60).toString().padLeft(2, '0')} | $_bestMoves moves",
                    style: TextStyle(
                      fontSize: 12, 
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

          // Game grid
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: _gridCols / _gridRows,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridCols,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      return _buildCard(index, isDark);
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

  Widget _buildStat(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(int index, bool isDark) {
    final card = _cards[index];
    final bool showFace = card.isFlipped || card.isMatched;

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: card.isMatched
              ? Colors.green[isDark ? 800 : 100]
              : showFace
                  ? (isDark ? Colors.grey[800] : Colors.white)
                  : accentColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: card.isMatched
              ? Border.all(color: Colors.green, width: 2)
              : null,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: showFace
                ? Icon(
                    card.icon,
                    key: ValueKey('icon_$index'),
                    size: _gridCols > 4 ? 28 : 36,
                    color: card.isMatched ? Colors.green : accentColor,
                  )
                : Icon(
                    Icons.question_mark,
                    key: ValueKey('question_$index'),
                    size: _gridCols > 4 ? 24 : 30,
                    color: Colors.white.withOpacity(0.5),
                  ),
          ),
        ),
      ),
    );
  }
}

// Card Model
class CardModel {
  final int id;
  final int iconIndex;
  final IconData icon;
  bool isFlipped;
  bool isMatched;

  CardModel({
    required this.id,
    required this.iconIndex,
    required this.icon,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
