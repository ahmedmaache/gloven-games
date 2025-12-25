import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../data/questions.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int _highScore = 0;
  int? _selectedOption;
  bool _hasAnswered = false;
  
  // v1.0.1: Timer per question
  int _timeRemaining = 15; // 15 seconds per question
  Timer? _questionTimer;
  
  // v1.0.1: Streak bonus
  int _streak = 0;
  int _maxStreak = 0;
  int _bonusPoints = 0;

  QuizQuestion get _currentQuestion => quizQuestions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _startQuestionTimer();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('quiz_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    int totalScore = _score + _bonusPoints;
    if (totalScore > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('quiz_high_score', totalScore);
    }
  }

  void _startQuestionTimer() {
    _timeRemaining = 15;
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _timeRemaining--;
        if (_timeRemaining <= 0) {
          timer.cancel();
          // Time's up - auto-select wrong answer
          if (!_hasAnswered) {
            _selectOption(-1); // -1 means no selection (wrong)
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    super.dispose();
  }

  void _selectOption(int index) {
    if (_hasAnswered) return;

    _questionTimer?.cancel();
    
    setState(() {
      _selectedOption = index;
      _hasAnswered = true;
      if (index == _currentQuestion.correctIndex) {
        _score++;
        _streak++;
        if (_streak > _maxStreak) _maxStreak = _streak;
        
        // v1.0.1: Streak bonus points
        if (_streak >= 3) {
          _bonusPoints += _streak;
        }
        
        // Speed bonus: extra point if answered in under 5 seconds
        if (_timeRemaining > 10) {
          _bonusPoints += 1;
        }
      } else {
        _streak = 0;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < quizQuestions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _hasAnswered = false;
      });
      _startQuestionTimer();
    } else {
      // Quiz complete
      _saveHighScore();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            score: _score,
            total: quizQuestions.length,
            bonusPoints: _bonusPoints,
            maxStreak: _maxStreak,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Question ${_currentIndex + 1}/${quizQuestions.length}"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentIndex + 1) / quizQuestions.length,
            backgroundColor: primaryColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            minHeight: 6,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Score and timer row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Score indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: correctColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: correctColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "$_score${_bonusPoints > 0 ? '+$_bonusPoints' : ''}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: correctColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // v1.0.1: Timer
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _timeRemaining <= 5 
                              ? Colors.red.withOpacity(0.1) 
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer,
                              color: _timeRemaining <= 5 ? Colors.red : Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${_timeRemaining}s",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _timeRemaining <= 5 ? Colors.red : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // v1.0.1: Streak indicator
                  if (_streak >= 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "🔥 Streak x$_streak!",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Question
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Text(
                      _currentQuestion.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Options
                  ...List.generate(4, (index) => _buildOption(index)),

                  // Explanation (if answered)
                  if (_hasAnswered && _currentQuestion.explanation != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: primaryColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _currentQuestion.explanation!,
                              style: TextStyle(
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Next button
                  if (_hasAnswered)
                    ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentIndex < quizQuestions.length - 1
                            ? "NEXT QUESTION"
                            : "SEE RESULTS",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(int index) {
    bool isSelected = _selectedOption == index;
    bool isCorrect = index == _currentQuestion.correctIndex;
    
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    Color textColor = Colors.black87;

    if (_hasAnswered) {
      if (isCorrect) {
        bgColor = correctColor.withOpacity(0.1);
        borderColor = correctColor;
        textColor = correctColor;
      } else if (isSelected && !isCorrect) {
        bgColor = wrongColor.withOpacity(0.1);
        borderColor = wrongColor;
        textColor = wrongColor;
      }
    } else if (isSelected) {
      borderColor = primaryColor;
      bgColor = primaryColor.withOpacity(0.05);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _selectOption(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: borderColor.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _currentQuestion.options[index],
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ),
              if (_hasAnswered && isCorrect)
                const Icon(Icons.check_circle, color: correctColor),
              if (_hasAnswered && isSelected && !isCorrect)
                const Icon(Icons.cancel, color: wrongColor),
            ],
          ),
        ),
      ),
    );
  }
}
