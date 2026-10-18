import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:java_play_app/core/constants/app_colors.dart';
import 'package:java_play_app/core/services/feedback_service.dart';
import 'package:java_play_app/core/widgets/mascot/mascot_widget.dart';
import 'package:java_play_app/core/widgets/mascot/mascot_state.dart';
import 'package:java_play_app/core/widgets/enemy/bug_enemy_widget.dart';
import 'package:java_play_app/features/learning_path/domain/models/lesson.dart';
import 'package:java_play_app/features/quiz/domain/models/exercise.dart';
import '../controllers/quiz_controller.dart';
import '../widgets/exercise_header.dart';
import '../widgets/feedback_bottom_sheet.dart';
import '../widgets/types/flashcard_view.dart';
import '../widgets/types/multiple_choice_view.dart';
import '../widgets/types/code_fill_blank_view.dart';
import '../widgets/types/token_reorder_view.dart';
import '../widgets/types/spot_the_bug_view.dart';
import 'lesson_result_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final Lesson lesson;

  const QuizScreen({super.key, required this.lesson});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  MascotState _mascotState = MascotState.thinking;
  Timer? _idleTimer;
  Timer? _bugDefeatedTimer;
  int _consecutiveCorrect = 0;
  bool _showBug = false;
  BugEnemyState _bugState = BugEnemyState.glitch;

  @override
  void initState() {
    super.initState();
    _startIdleTimer();
  }

  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _mascotState = MascotState.idle;
        });
      }
    });
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _bugDefeatedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<QuizState>(quizProvider(widget.lesson), (previous, next) {
      if (previous == null) return;

      // Question changed
      if (next.currentExerciseIndex != previous.currentExerciseIndex) {
        setState(() {
          _mascotState = MascotState.thinking;
          if (_bugState == BugEnemyState.defeated) {
            _showBug = false;
          }
        });
        _startIdleTimer();
      }

      // Correct answer
      if (next.answerStatus == AnswerStatus.correct && previous.answerStatus != AnswerStatus.correct) {
        FeedbackService.instance.onCorrect();
        _consecutiveCorrect++;
        setState(() {
          _mascotState = _consecutiveCorrect >= 3 ? MascotState.celebrate : MascotState.happy;
          if (_showBug) {
            _bugState = BugEnemyState.defeated;
            _bugDefeatedTimer?.cancel();
            _bugDefeatedTimer = Timer(const Duration(milliseconds: 1000), () {
              if (mounted) {
                setState(() => _showBug = false);
              }
            });
          }
        });
        _startIdleTimer();
      }

      // Incorrect answer
      if (next.answerStatus == AnswerStatus.incorrect && previous.answerStatus != AnswerStatus.incorrect) {
        FeedbackService.instance.onWrong();
        _consecutiveCorrect = 0;
        setState(() {
          _mascotState = MascotState.sad;
          _showBug = true;
          _bugState = BugEnemyState.glitch;
        });
        _startIdleTimer();
      }
    });

    final quizState = ref.watch(quizProvider(widget.lesson));
    final quizNotifier = ref.read(quizProvider(widget.lesson).notifier);

    if (quizState.isGameOver) {
      return _buildGameOverView(context);
    }

    if (quizState.isLessonCompleted) {
      return LessonResultScreen(quizState: quizState);
    }

    final currentExercise = quizState.currentExercise;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmExit(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: ExerciseHeader(
          progress: quizState.progressRatio,
          lives: quizState.lives,
          currentIndex: quizState.currentExerciseIndex + 1,
          totalExercises: quizState.lesson.exercises.length,
          onClose: () => _confirmExit(context),
          mascot: MascotWidget(state: _mascotState, size: 34),
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (_showBug)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF261219),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.errorRed.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      BugEnemyWidget(state: _bugState, size: 40),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "¡Bug detectado en el código! Corrige la respuesta para derrotarlo.",
                          style: TextStyle(
                            color: Color(0xFFFF9E9E),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
