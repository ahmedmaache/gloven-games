import 'package:flutter/material.dart';

/// BRANDING CONFIGURATION - Gloven Games
/// App: Gloven Merge Puzzle
/// Developer: ApocalypseNever

const String appName = "Gloven Merge Puzzle";
const String developerName = "ApocalypseNever";
const String packageName = "org.gloven.mergepuzzle";
const String supportEmail = "z19690976@gmail.com";

// Brand colors
const Color primaryColor = Color(0xFFFF9800);
const Color secondaryColor = Color(0xFFF57C00);
const Color backgroundColor = Color(0xFFFAF8EF);
const List<Color> gradientColors = [Color(0xFFFF9800), Color(0xFFF57C00)];

// Game constants
const int gridSize = 4;
const int winValue = 2048;

// Tile colors based on value
const Map<int, Color> tileColors = {
  0: Color(0xFFCDC1B4),
  2: Color(0xFFEEE4DA),
  4: Color(0xFFEDE0C8),
  8: Color(0xFFF2B179),
  16: Color(0xFFF59563),
  32: Color(0xFFF67C5F),
  64: Color(0xFFF65E3B),
  128: Color(0xFFEDCF72),
  256: Color(0xFFEDCC61),
  512: Color(0xFFEDC850),
  1024: Color(0xFFEDC53F),
  2048: Color(0xFFEDC22E),
};

Color getTileTextColor(int value) {
  return value <= 4 ? const Color(0xFF776E65) : Colors.white;
}
