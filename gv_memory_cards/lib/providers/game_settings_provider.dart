import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Game difficulty levels
enum Difficulty { easy, medium, hard }

/// Game Settings Provider for managing difficulty and other game options
/// v1.0.2 - Added difficulty levels based on user feedback
class GameSettingsProvider extends ChangeNotifier {
  // Difficulty settings
  Difficulty _difficulty = Difficulty.medium;
  
  // Sound and vibration settings
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  
  // Getters
  Difficulty get difficulty => _difficulty;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  
  // Grid size based on difficulty
  int get gridRows {
    switch (_difficulty) {
      case Difficulty.easy:
        return 3;
      case Difficulty.medium:
        return 4;
      case Difficulty.hard:
        return 5;
    }
  }
  
  int get gridCols {
    switch (_difficulty) {
      case Difficulty.easy:
        return 4; // 3x4 = 12 cards = 6 pairs
      case Difficulty.medium:
        return 4; // 4x4 = 16 cards = 8 pairs
      case Difficulty.hard:
        return 6; // 5x6 = 30 cards = 15 pairs
    }
  }
  
  int get totalPairs => (gridRows * gridCols) ~/ 2;
  
  // Peek hints based on difficulty
  int get peeksAllowed {
    switch (_difficulty) {
      case Difficulty.easy:
        return 3;
      case Difficulty.medium:
        return 2;
      case Difficulty.hard:
        return 1;
    }
  }
  
  String get difficultyName {
    switch (_difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }
  
  GameSettingsProvider() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    final diffIndex = prefs.getInt('difficulty') ?? 1; // Default to medium
    _difficulty = Difficulty.values[diffIndex];
    notifyListeners();
  }
  
  Future<void> setDifficulty(Difficulty diff) async {
    _difficulty = diff;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('difficulty', diff.index);
    notifyListeners();
  }
  
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', enabled);
    notifyListeners();
  }
}
