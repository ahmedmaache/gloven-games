import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Game Settings Provider for managing game options
/// v1.0.2 - Added based on user feedback
class GameSettingsProvider extends ChangeNotifier {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  
  GameSettingsProvider() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
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
