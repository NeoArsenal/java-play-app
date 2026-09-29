import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../quiz/domain/models/exercise.dart';

class FlashcardView extends StatelessWidget {
  final FlashcardExercise exercise;

  const FlashcardView({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.duolingoBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.duolingoBlue, size: 16),
                  SizedBox(width: 4),
                  Text(
                    "MICRO-TEORÍA NUCLEAR",
                    style: TextStyle(
                      color: AppColors.duolingoBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          exercise.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (exercise.codeSnippet != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.codeBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.codeBorder),
                  ),
                  child: Text(
                    exercise.codeSnippet!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13.5,
                      color: AppColors.codeText,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                exercise.explanation,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
