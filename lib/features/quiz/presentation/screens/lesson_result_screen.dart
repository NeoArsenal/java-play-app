import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:java_play_app/core/constants/app_colors.dart';
import 'package:java_play_app/core/services/feedback_service.dart';
import 'package:java_play_app/core/services/feedback_settings.dart';
import 'package:java_play_app/core/widgets/mascot/mascot_state.dart';
import 'package:java_play_app/core/widgets/mascot/mascot_widget.dart';
import '../controllers/quiz_controller.dart';

class LessonResultScreen extends StatefulWidget {
  final QuizState quizState;

  const LessonResultScreen({super.key, required this.quizState});

  @override
  State<LessonResultScreen> createState() => _LessonResultScreenState();
}

class _LessonResultScreenState extends State<LessonResultScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FeedbackService.instance.onLessonComplete();
      if (!FeedbackSettings.isReducedMotion(context)) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  int _calculateAccuracy() {
    final mistakes = (5 - widget.quizState.lives).clamp(0, 5);
    final total = widget.quizState.lesson.exercises.length;
    if (total == 0) return 100;
    final totalAttempts = total + mistakes;
    return ((total / totalAttempts) * 100).round().clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = _calculateAccuracy();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti Cannon
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2, // downwards
                maxBlastForce: 25,
                minBlastForce: 10,
                emissionFrequency: 0.05,
                numberOfParticles: 25,
                gravity: 0.25,
                colors: const [
                  AppColors.primaryGreen,
                  AppColors.duolingoGold,
                  AppColors.duolingoBlue,
                  AppColors.duolingoOrange,
                  AppColors.duolingoPurple,
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Celebrating Mascot
                  const MascotWidget(
                    state: MascotState.celebrate,
                    size: 110,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "¡Lección Completada!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.quizState.lesson.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Summary Performance Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.bolt_rounded,
                          iconColor: AppColors.duolingoGold,
                          value: "+${widget.quizState.currentXp} XP",
                          label: "TOTAL XP",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.track_changes_rounded,
                          iconColor: AppColors.primaryGreen,
                          value: "$accuracy%",
                          label: "PRECISIÓN",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.local_fire_department_rounded,
                          iconColor: AppColors.duolingoOrange,
                          value: "${widget.quizState.streakDays}",
                          label: "RACHA",
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      "CONTINUAR",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: iconColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
