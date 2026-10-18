import 'package:flutter/material.dart';
import 'package:java_play_app/core/widgets/enemy/bug_enemy_widget.dart';
import 'package:java_play_app/core/widgets/mascot/mascot_state.dart';
import 'package:java_play_app/core/widgets/mascot/mascot_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/quiz_controller.dart';
import '../../../quiz/domain/models/exercise.dart';

class FeedbackBottomSheet extends StatelessWidget {
  final QuizState state;
  final VoidCallback onVerify;
  final VoidCallback onContinue;
  final VoidCallback? onAssist;
  final MascotState? mascotState;
  final BugEnemyState? bugState;

  const FeedbackBottomSheet({
    super.key,
    required this.state,
    required this.onVerify,
    required this.onContinue,
    this.onAssist,
    this.mascotState,
    this.bugState,
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

    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomPadding),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MascotWidget(
                  state: mascotState ?? MascotState.happy,
                  size: 96,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            state.isAssistModeActive ? Icons.stars : Icons.check_circle,
                            color: state.isAssistModeActive ? AppColors.gold : AppColors.primaryGreen,
                            size: 26,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              state.isAssistModeActive ? "¡Racha salvada!" : "¡Excelente respuesta!",
                              style: TextStyle(
                                color: state.isAssistModeActive ? AppColors.gold : AppColors.primaryGreen,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
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
                          color: Colors.white,
                          fontSize: 13.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ] else if (status == AnswerStatus.incorrect) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const MascotWidget(
                      state: MascotState.sad,
                      size: 96,
                    ),
                    Positioned(
                      right: -4,
                      bottom: 0,
                      child: BugEnemyWidget(
                        state: bugState ?? BugEnemyState.glitch,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.cancel, color: AppColors.errorRed, size: 26),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Solución incorrecta",
                              style: TextStyle(
                                color: AppColors.errorRed,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.currentExercise.explanation,
                        style: const TextStyle(
                          color: Color(0xFFFFD4D4),
                          fontSize: 13.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
