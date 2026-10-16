import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ExerciseHeader extends StatelessWidget implements PreferredSizeWidget {
  final double progress;
  final int lives;
  final int currentIndex;
  final int totalExercises;
  final VoidCallback onClose;

  const ExerciseHeader({
    super.key,
    required this.progress,
    required this.lives,
    this.currentIndex = 1,
    this.totalExercises = 7,
    required this.onClose,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    String modeLabel = "🎯 NORMAL";
    Color modeColor = AppColors.primaryGreen;
    if (totalExercises == 10) {
      modeLabel = "🔥 SENIOR";
      modeColor = AppColors.duolingoOrange;
    } else if (totalExercises == 5) {
      modeLabel = "⚡ ÁGIL";
      modeColor = AppColors.duolingoGold;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 26),
              onPressed: onClose,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: modeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: modeColor.withOpacity(0.4), width: 1),
                        ),
                        child: Text(
                          modeLabel,
                          style: TextStyle(
                            color: modeColor,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        "$currentIndex de $totalExercises",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(begin: 0, end: progress),
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 12,
                          backgroundColor: AppColors.surfaceBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(modeColor),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: AppColors.errorRed, size: 20),
                  const SizedBox(width: 5),
                  Text(
                    '$lives',
                    style: const TextStyle(
                      color: AppColors.errorRed,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
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
}
