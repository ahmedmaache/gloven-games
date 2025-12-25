import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors)),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(top: 16, left: 16, child: IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())), icon: const Icon(Icons.settings, color: Colors.white70, size: 28), tooltip: 'Settings')),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]), child: const Icon(Icons.layers, size: 60, color: Colors.white)),
                      const SizedBox(height: 32),
                      const Text(appName, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4)]), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      const Text('by $developerName', style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      const Text('Powered by Global Ventures – gloven.org', style: TextStyle(fontSize: 12, color: Colors.white54)),
                      const SizedBox(height: 60),
                      ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen())), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: primaryColor, padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)), elevation: 8), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.play_arrow_rounded, size: 36), SizedBox(width: 8), Text('PLAY', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))])),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
