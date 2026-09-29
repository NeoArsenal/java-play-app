import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../quiz/domain/models/exercise.dart';

class TokenReorderView extends StatelessWidget {
  final TokenReorderExercise exercise;
  final List<String> userOrderedTokens;
  final List<String> availableTokens;
  final Function(String) onSelectToken;
  final Function(int) onRemoveToken;

  const TokenReorderView({
    super.key,
    required this.exercise,
    required this.userOrderedTokens,
    required this.availableTokens,
    required this.onSelectToken,
    required this.onRemoveToken,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ORDENA LA SINTAXIS JAVA",
          style: TextStyle(
            color: AppColors.duolingoPurple,
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
        const SizedBox(height: 20),
        // Target Area (Selected Tokens in order)
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 90),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.codeBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: userOrderedTokens.isEmpty ? AppColors.surfaceBorder : AppColors.primaryGreen,
              width: 1.5,
            ),
          ),
          child: userOrderedTokens.isEmpty
              ? const Center(
                  child: Text(
                    "Toca las palabras de abajo para formar la sentencia",
                    style: TextStyle(color: AppColors.textDisabled, fontSize: 14),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: List.generate(userOrderedTokens.length, (index) {
                    final token = userOrderedTokens[index];
                    return ActionChip(
                      label: Text(
                        token,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppColors.primaryGreen),
                      ),
                      avatar: const Icon(Icons.close, size: 16, color: AppColors.primaryGreen),
                      onPressed: () => onRemoveToken(index),
                    );
                  }),
                ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Banco de Tokens:",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 12),
        // Pool of available tokens
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: availableTokens.map((token) {
            return ActionChip(
              label: Text(
                token,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
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
