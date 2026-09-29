import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../quiz/domain/models/exercise.dart';

class MultipleChoiceView extends StatelessWidget {
  final MultipleChoiceExercise exercise;
  final int? selectedIndex;
  final List<int> eliminatedIndices;
  final ValueChanged<int> onSelect;

  const MultipleChoiceView({
    super.key,
    required this.exercise,
    required this.selectedIndex,
    this.eliminatedIndices = const [],
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "PREGUNTA TÉCNICA",
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          exercise.question,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),
        if (exercise.codeSnippet != null) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.codeBackground,
              borderRadius: BorderRadius.circular(14),
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
        ],
        const SizedBox(height: 20),
        ...List.generate(exercise.options.length, (index) {
          final isSelected = selectedIndex == index;
          final isEliminated = eliminatedIndices.contains(index);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Opacity(
              opacity: isEliminated ? 0.25 : 1.0,
              child: InkWell(
                onTap: isEliminated
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        onSelect(index);
                      },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGreen.withOpacity(0.12) : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryGreen : AppColors.surfaceBorder,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected ? AppColors.primaryGreen.withOpacity(0.3) : Colors.black26,
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primaryGreen : AppColors.textDisabled,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          exercise.options[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            decoration: isEliminated ? TextDecoration.lineThrough : null,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
