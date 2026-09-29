import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../quiz/domain/models/exercise.dart';

class SpotTheBugView extends StatelessWidget {
  final SpotTheBugExercise exercise;
  final int? selectedLineIndex;
  final ValueChanged<int> onSelectLine;

  const SpotTheBugView({
    super.key,
    required this.exercise,
    required this.selectedLineIndex,
    required this.onSelectLine,
  });

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
                color: AppColors.errorRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bug_report_rounded, color: AppColors.errorRed, size: 16),
                  SizedBox(width: 4),
                  Text(
                    "SPOT THE BUG (CODE INSPECTION)",
                    style: TextStyle(
                      color: AppColors.errorRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          exercise.question,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.codeBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.codeBorder, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                offset: Offset(0, 4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            children: List.generate(exercise.codeLines.length, (index) {
              final isSelected = selectedLineIndex == index;
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelectLine(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.errorRed.withOpacity(0.22)
                        : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: isSelected ? AppColors.errorRed : Colors.transparent,
                        width: 4,
                      ),
                      bottom: BorderSide(
                        color: index < exercise.codeLines.length - 1
                            ? AppColors.codeBorder.withOpacity(0.5)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: isSelected
                                ? AppColors.errorRed
                                : AppColors.textDisabled,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          exercise.codeLines[index],
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13.5,
                            color: isSelected ? Colors.white : AppColors.codeText,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.errorRed,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
