import 'package:flutter/material.dart';
import '../config.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)));
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ));
      }
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors)),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(scale: _scaleAnimation.value, child: Opacity(opacity: _fadeAnimation.value, child: Container(width: 140, height: 140, decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(35), boxShadow: [BoxShadow(color: Colors.black.withAlpha(51), blurRadius: 30, offset: const Offset(0, 15))]), child: const Icon(Icons.merge, size: 70, color: Colors.white)))),
                    const SizedBox(height: 40),
                    Opacity(opacity: _fadeAnimation.value, child: const Text(appName, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2), textAlign: TextAlign.center)),
                    const SizedBox(height: 12),
                    Opacity(opacity: _fadeAnimation.value * 0.7, child: const Text('by \$developerName', style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500))),
                    const SizedBox(height: 60),
                    Opacity(opacity: _fadeAnimation.value, child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withAlpha(204))))),
                    const SizedBox(height: 100),
                    Opacity(opacity: _fadeAnimation.value * 0.5, child: const Text('Powered by Global Ventures – gloven.org', style: TextStyle(fontSize: 12, color: Colors.white54))),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
