import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/quiz_controller.dart';
import '../../../quiz/domain/models/exercise.dart';

class FeedbackBottomSheet extends StatelessWidget {
  final QuizState state;
  final VoidCallback onVerify;
  final VoidCallback onContinue;
  final VoidCallback? onAssist;

  const FeedbackBottomSheet({
    super.key,
    required this.state,
    required this.onVerify,
    required this.onContinue,
    this.onAssist,
  });

  @override
  Widget build(BuildContext context) {
    final status = state.answerStatus;
    Color barBackground = AppColors.surface;
    String buttonText = "COMPROBAR";
    VoidCallback? onPressed;

    if (state.currentExercise is FlashcardExercise) {
      buttonText = "ENTENDIDO";
      onPressed = onContinue;
    } else {
      switch (status) {
        case AnswerStatus.unselected:
          onPressed = null;
          break;
        case AnswerStatus.readyToVerify:
          onPressed = onVerify;
          break;
        case AnswerStatus.correct:
          buttonText = "CONTINUAR";
          onPressed = onContinue;
          barBackground = AppColors.successBg;
          break;
        case AnswerStatus.incorrect:
          buttonText = "CONTINUAR";
          onPressed = onContinue;
          barBackground = AppColors.errorBg;
          break;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: barBackground,
        border: Border(
          top: BorderSide(
            color: status == AnswerStatus.correct
                ? AppColors.successBorder
                : status == AnswerStatus.incorrect
                    ? AppColors.errorBorder
                    : AppColors.surfaceBorder,
            width: 2,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (status == AnswerStatus.correct) ...[
            Row(
              children: [
                Icon(
                  state.isAssistModeActive ? Icons.stars : Icons.check_circle,
                  color: state.isAssistModeActive ? AppColors.gold : AppColors.primaryGreen,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  state.isAssistModeActive ? "¡Racha salvada!" : "¡Excelente respuesta!",
                  style: TextStyle(
                    color: state.isAssistModeActive ? AppColors.gold : AppColors.primaryGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              state.isAssistModeActive
                  ? "Ejercicio completado con asistencia (+5 XP). ${state.currentExercise.explanation}"
                  : state.currentExercise.explanation,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
          ] else if (status == AnswerStatus.incorrect) ...[
            Row(
              children: const [
                Icon(Icons.cancel, color: AppColors.errorRed, size: 28),
                SizedBox(width: 8),
                Text(
                  "Solución incorrecta",
                  style: TextStyle(
                    color: AppColors.errorRed,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              state.currentExercise.explanation,
              style: const TextStyle(
                color: Color(0xFFFFB8B8),
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (status == AnswerStatus.incorrect && onAssist != null) ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: onAssist,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: const Color(0xFF13141B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "💡 RESOLVER CON PISTAS (+5 XP)",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: onContinue,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.errorRed, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "SALTAR",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: status == AnswerStatus.incorrect
                    ? AppColors.errorRed
                    : AppColors.primaryGreen,
                disabledBackgroundColor: AppColors.surfaceBorder,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  color: onPressed == null ? AppColors.textDisabled : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
