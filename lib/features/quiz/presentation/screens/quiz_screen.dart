import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../learning_path/domain/models/lesson.dart';
import '../domain/models/exercise.dart';
import '../controllers/quiz_controller.dart';
import '../widgets/exercise_header.dart';
import '../widgets/feedback_bottom_sheet.dart';
import '../widgets/types/flashcard_view.dart';
import '../widgets/types/multiple_choice_view.dart';
import '../widgets/types/code_fill_blank_view.dart';
import '../widgets/types/token_reorder_view.dart';
import '../widgets/types/spot_the_bug_view.dart';

class QuizScreen extends ConsumerWidget {
  final Lesson lesson;

  const QuizScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider(lesson));
    final quizNotifier = ref.read(quizProvider(lesson).notifier);

    if (quizState.isGameOver) {
      return _buildGameOverView(context);
    }

    if (quizState.isLessonCompleted) {
      return _buildCompletedView(context, quizState);
    }

    final currentExercise = quizState.currentExercise;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ExerciseHeader(
        progress: quizState.progressRatio,
        lives: quizState.lives,
        onClose: () => _confirmExit(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _buildExerciseBody(currentExercise, quizState, quizNotifier),
              ),
            ),
            FeedbackBottomSheet(
              state: quizState,
              onVerify: () => quizNotifier.verifyAnswer(),
              onContinue: () => quizNotifier.proceedToNext(),
              onAssist: () => quizNotifier.activateAssistMode(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseBody(Exercise exercise, QuizState state, QuizNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.assistHint != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("💡", style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    state.assistHint!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (exercise is FlashcardExercise)
          FlashcardView(exercise: exercise)
        else if (exercise is MultipleChoiceExercise)
          MultipleChoiceView(
            exercise: exercise,
            selectedIndex: state.selectedOptionIndex,
            eliminatedIndices: state.eliminatedOptionIndices,
            onSelect: (index) => notifier.selectMultipleChoiceOption(index),
          )
        else if (exercise is SpotTheBugExercise)
          SpotTheBugView(
            exercise: exercise,
            selectedLineIndex: state.selectedBugLineIndex,
            onSelectLine: (index) => notifier.selectBugLine(index),
          )
        else if (exercise is FillBlankExercise)
          CodeFillBlankView(
            exercise: exercise,
            filledBlanks: state.filledBlanks,
            availableOptions: state.availableBlankOptions,
            onSelectToken: (token) => notifier.addBlankToken(token),
            onRemoveToken: (index) => notifier.removeBlankToken(index),
          )
        else if (exercise is TokenReorderExercise)
          TokenReorderView(
            exercise: exercise,
            userOrderedTokens: state.userOrderedTokens,
            availableTokens: state.availableTokens,
            onSelectToken: (token) => notifier.addReorderToken(token),
            onRemoveToken: (index) => notifier.removeReorderToken(index),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildGameOverView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.heart_broken_rounded, color: AppColors.errorRed, size: 80),
                const SizedBox(height: 18),
                const Text(
                  "¡Te has quedado sin vidas!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Repasa la teoría nuclear e inténtalo de nuevo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorRed,
                    minimumSize: const Size(double.infinity, 54),
                  ),
                  child: const Text("SALIR A LA RUTA"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedView(BuildContext context, QuizState state) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_rounded, color: AppColors.duolingoGold, size: 90),
                const SizedBox(height: 20),
                const Text(
                  "¡Lección Completada!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "+${state.currentXp} XP ganados para tu preparación",
                  style: const TextStyle(
                    color: AppColors.duolingoGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 36),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(double.infinity, 54),
                  ),
                  child: const Text("CONTINUAR"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("¿Salir de la lección?"),
        content: const Text("Perderás el progreso de esta sesión."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("CANCELAR", style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text("SALIR", style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}
