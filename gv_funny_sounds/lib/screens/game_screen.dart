import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int totalTaps = 0;
  int highScore = 0;
  int currentStreak = 0;
  int bestStreak = 0;
  
  // Sound button data with emojis and funny names
  final List<SoundButton> soundButtons = [
    SoundButton(emoji: '😂', name: 'LOL', color: Colors.red, soundFile: 'lol.mp3'),
    SoundButton(emoji: '🤣', name: 'ROFL', color: Colors.orange, soundFile: 'rofl.mp3'),
    SoundButton(emoji: '😹', name: 'Cat Laugh', color: Colors.yellow, soundFile: 'cat.mp3'),
    SoundButton(emoji: '🎺', name: 'Toot', color: Colors.green, soundFile: 'toot.mp3'),
    SoundButton(emoji: '💨', name: 'Whoosh', color: Colors.teal, soundFile: 'whoosh.mp3'),
    SoundButton(emoji: '🔔', name: 'Ding', color: Colors.blue, soundFile: 'ding.mp3'),
    SoundButton(emoji: '💥', name: 'Boom', color: Colors.indigo, soundFile: 'boom.mp3'),
    SoundButton(emoji: '🎉', name: 'Party', color: Colors.purple, soundFile: 'party.mp3'),
    SoundButton(emoji: '👏', name: 'Clap', color: Colors.pink, soundFile: 'clap.mp3'),
    SoundButton(emoji: '🦆', name: 'Quack', color: Colors.amber, soundFile: 'quack.mp3'),
    SoundButton(emoji: '🐸', name: 'Ribbit', color: Colors.lightGreen, soundFile: 'ribbit.mp3'),
    SoundButton(emoji: '🤡', name: 'Honk', color: Colors.deepOrange, soundFile: 'honk.mp3'),
  ];
  
  // Animation controllers for each button
  List<AnimationController> _animControllers = [];
  List<Animation<double>> _scaleAnimations = [];
  
  // Floating emojis for effects
  List<FloatingEmoji> floatingEmojis = [];

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  @override
  void initState() {
    super.initState();
    _loadStats();
    _initAnimations();
  }
  
  void _initAnimations() {
    for (int i = 0; i < soundButtons.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      );
      final animation = Tween<double>(begin: 1.0, end: 0.85).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
      _animControllers.add(controller);
      _scaleAnimations.add(animation);
    }
  }
  
  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('high_score') ?? 0;
      bestStreak = prefs.getInt('best_streak') ?? 0;
    });
  }
  
  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    if (totalTaps > highScore) {
      await prefs.setInt('high_score', totalTaps);
      highScore = totalTaps;
    }
    if (currentStreak > bestStreak) {
      await prefs.setInt('best_streak', currentStreak);
      bestStreak = currentStreak;
    }
  }
  
  Future<void> _onButtonTap(int index) async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Play sound
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/${soundButtons[index].soundFile}'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
    
    // Play animation
    _animControllers[index].forward().then((_) {
      _animControllers[index].reverse();
    });
    
    // Update stats
    setState(() {
      totalTaps++;
      currentStreak++;
      
      // Add floating emoji
      _addFloatingEmoji(soundButtons[index].emoji);
    });
    
    // Save periodically
    if (totalTaps % 10 == 0) {
      _saveStats();
    }
  }
  
  void _addFloatingEmoji(String emoji) {
    final random = Random();
    final screenWidth = MediaQuery.of(context).size.width;
    
    setState(() {
      floatingEmojis.add(FloatingEmoji(
        emoji: emoji,
        x: random.nextDouble() * (screenWidth - 50) + 25,
        y: MediaQuery.of(context).size.height * 0.5,
        id: DateTime.now().millisecondsSinceEpoch,
      ));
    });
    
    // Remove after animation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          floatingEmojis.removeWhere(
            (e) => DateTime.now().millisecondsSinceEpoch - e.id > 1800,
          );
        });
      }
    });
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    for (var controller in _animControllers) {
      controller.dispose();
    }
    _saveStats();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header with stats
                  _buildHeader(),
                  
                  // Sound buttons grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: soundButtons.length,
                        itemBuilder: (context, index) {
                          return _buildSoundButton(index);
                        },
                      ),
                    ),
                  ),
                  
                  // Streak indicator
                  _buildStreakIndicator(),
                ],
              ),
              
              // Floating emojis overlay
              ...floatingEmojis.map((emoji) => _buildFloatingEmoji(emoji)),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          
          // Total taps
          Column(
            children: [
              const Text(
                'TAPS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                '$totalTaps',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // High score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                const SizedBox(width: 6),
                Text(
                  '$highScore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSoundButton(int index) {
    final button = soundButtons[index];
    
    return AnimatedBuilder(
      animation: _scaleAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimations[index].value,
          child: GestureDetector(
            onTapDown: (_) => _onButtonTap(index),
            child: Container(
              decoration: BoxDecoration(
                color: button.color.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: button.color.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    button.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    button.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStreakIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🔥 Streak: ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          Text(
            '$currentStreak',
            style: TextStyle(
              color: currentStreak > 10 ? Colors.amber : Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (currentStreak > 0) ...[
            const SizedBox(width: 20),
            Text(
              '🏆 Best: $bestStreak',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildFloatingEmoji(FloatingEmoji emoji) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Positioned(
          left: emoji.x,
          bottom: emoji.y + (value * 200),
          child: Opacity(
            opacity: 1 - value,
            child: Transform.scale(
              scale: 1 + (value * 0.5),
              child: Text(
                emoji.emoji,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SoundButton {
  final String emoji;
  final String name;
  final Color color;
  final String soundFile;
  
  SoundButton({
    required this.emoji,
    required this.name,
    required this.color,
    required this.soundFile,
  });
}

class FloatingEmoji {
  final String emoji;
  final double x;
  final double y;
  final int id;
  
  FloatingEmoji({
    required this.emoji,
    required this.x,
    required this.y,
    required this.id,
  });
}
