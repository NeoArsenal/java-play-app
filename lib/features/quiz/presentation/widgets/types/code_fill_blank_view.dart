import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../quiz/domain/models/exercise.dart';

class CodeFillBlankView extends StatelessWidget {
  final FillBlankExercise exercise;
  final List<String> filledBlanks;
  final List<String> availableOptions;
  final Function(String) onSelectToken;
  final Function(int) onRemoveToken;

  const CodeFillBlankView({
    super.key,
    required this.exercise,
    required this.filledBlanks,
    required this.availableOptions,
    required this.onSelectToken,
    required this.onRemoveToken,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "COMPLETA EL CÓDIGO",
          style: TextStyle(
            color: AppColors.duolingoOrange,
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
            fontSize: 19,
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 18),
        // Code Box with clickable blanks
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.codeBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.codeBorder, width: 1.5),
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 10,
            children: [
              Text(
                "public",
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.codeSyntaxKeyword,
                ),
              ),
              ...List.generate(exercise.correctAnswers.length, (index) {
                final isFilled = index < filledBlanks.length;
                return InkWell(
                  onTap: isFilled ? () => onRemoveToken(index) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isFilled ? AppColors.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isFilled ? AppColors.primaryGreen : AppColors.textDisabled,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      isFilled ? filledBlanks[index] : " ______ ",
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isFilled ? AppColors.primaryGreen : AppColors.textDisabled,
                      ),
                    ),
                  ),
                );
              }),
              Text(
                "String APP_NAME = \"SpringDuo\";",
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  color: AppColors.codeText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Toca los tokens disponibles:",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 12),
        // Chips Pool
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: availableOptions.map((token) {
            return ActionChip(
              label: Text(
                token,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.surfaceBorder, width: 1.5),
              ),
              onPressed: () => onSelectToken(token),
            );
          }).toList(),
        ),
      ],
    );
  }
}
