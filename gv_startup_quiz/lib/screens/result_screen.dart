import 'package:flutter/material.dart';
import '../config.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final int bonusPoints;
  final int maxStreak;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    this.bonusPoints = 0,
    this.maxStreak = 0,
  });

  int get _totalScore => score + bonusPoints;

  String get _feedback {
    double percentage = (score / total) * 100;
    if (percentage >= 90) return "🏆 Startup Genius!";
    if (percentage >= 70) return "🚀 Future Founder!";
    if (percentage >= 50) return "💡 Learning Fast!";
    if (percentage >= 30) return "📚 Keep Studying!";
    return "🌱 Just Getting Started!";
  }

  String get _message {
    double percentage = (score / total) * 100;
    if (percentage >= 90) {
      return "Amazing! You're ready to pitch to investors.";
    }
    if (percentage >= 70) {
      return "Great job! You have solid startup knowledge.";
    }
    if (percentage >= 50) {
      return "Good effort! Keep learning about entrepreneurship.";
    }
    if (percentage >= 30) {
      return "You're on your way! Review the basics.";
    }
    return "Every expert was once a beginner. Try again!";
  }

  @override
  Widget build(BuildContext context) {
    double percentage = (score / total) * 100;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Result Card
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _feedback,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Score circle
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor,
                            width: 8,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$score/$total",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              "${percentage.toInt()}%",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // v1.0.1: Bonus points and streak info
                      if (bonusPoints > 0 || maxStreak >= 3) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              if (bonusPoints > 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.bolt, color: Colors.amber, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Bonus Points: +$bonusPoints",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber[700],
                                      ),
                                    ),
                                  ],
                                ),
                              if (maxStreak >= 3) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("🔥", style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Max Streak: $maxStreak",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 8),
                              const Divider(),
                              const SizedBox(height: 8),
                              Text(
                                "Total Score: $_totalScore",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    "Back to Home",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
