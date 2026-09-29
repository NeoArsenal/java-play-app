import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ExerciseHeader extends StatelessWidget implements PreferredSizeWidget {
  final double progress;
  final int lives;
  final VoidCallback onClose;

  const ExerciseHeader({
    super.key,
    required this.progress,
    required this.lives,
    required this.onClose,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 28),
              onPressed: onClose,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(begin: 0, end: progress),
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 14,
                      backgroundColor: AppColors.surfaceBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: AppColors.errorRed, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    '$lives',
                    style: const TextStyle(
                      color: AppColors.errorRed,
                      fontSize: 16,
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
