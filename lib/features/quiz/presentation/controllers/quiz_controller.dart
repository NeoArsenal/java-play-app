import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/exercise.dart';
import '../../../learning_path/domain/models/lesson.dart';

enum AnswerStatus {
  unselected,
  readyToVerify,
  correct,
  incorrect,
}

class QuizState {
  final Lesson lesson;
  final int currentExerciseIndex;
  final int lives;
  final int currentXp;
  final int streakDays;
  
  // Multiple Choice State
  // Multiple Choice State
  final int? selectedOptionIndex;
  final List<int> eliminatedOptionIndices;

  // Spot The Bug State
  final int? selectedBugLineIndex;
  
  // Fill in blanks State
  final List<String> filledBlanks;
  final List<String> availableBlankOptions;
  
  // Token Reorder State
  final List<String> userOrderedTokens;
  final List<String> availableTokens;
  
  // Assist Mode State
  final bool isAssistModeActive;
  final String? assistHint;

  final AnswerStatus answerStatus;
  final bool isLessonCompleted;

  const QuizState({
    required this.lesson,
    this.currentExerciseIndex = 0,
    this.lives = 5,
    this.currentXp = 0,
    this.streakDays = 3,
    this.selectedOptionIndex,
    this.eliminatedOptionIndices = const [],
    this.selectedBugLineIndex,
    this.filledBlanks = const [],
    this.availableBlankOptions = const [],
    this.userOrderedTokens = const [],
    this.availableTokens = const [],
    this.isAssistModeActive = false,
    this.assistHint,
    this.answerStatus = AnswerStatus.unselected,
    this.isLessonCompleted = false,
  });

  Exercise get currentExercise => lesson.exercises[currentExerciseIndex];
  double get progressRatio => (currentExerciseIndex + 1) / lesson.exercises.length;
  bool get isGameOver => lives <= 0;

  QuizState copyWith({
    int? currentExerciseIndex,
    int? lives,
    int? currentXp,
    int? streakDays,
    int? selectedOptionIndex,
    List<int>? eliminatedOptionIndices,
    int? selectedBugLineIndex,
    List<String>? filledBlanks,
    List<String>? availableBlankOptions,
    List<String>? userOrderedTokens,
    List<String>? availableTokens,
    bool? isAssistModeActive,
    String? assistHint,
    AnswerStatus? answerStatus,
    bool? isLessonCompleted,
    bool clearSelection = false,
  }) {
    return QuizState(
      lesson: lesson,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      lives: lives ?? this.lives,
      currentXp: currentXp ?? this.currentXp,
      streakDays: streakDays ?? this.streakDays,
      selectedOptionIndex: clearSelection ? null : (selectedOptionIndex ?? this.selectedOptionIndex),
      eliminatedOptionIndices: eliminatedOptionIndices ?? this.eliminatedOptionIndices,
      selectedBugLineIndex: clearSelection ? null : (selectedBugLineIndex ?? this.selectedBugLineIndex),
      filledBlanks: filledBlanks ?? this.filledBlanks,
      availableBlankOptions: availableBlankOptions ?? this.availableBlankOptions,
      userOrderedTokens: userOrderedTokens ?? this.userOrderedTokens,
      availableTokens: availableTokens ?? this.availableTokens,
      isAssistModeActive: isAssistModeActive ?? this.isAssistModeActive,
      assistHint: assistHint ?? this.assistHint,
      answerStatus: answerStatus ?? this.answerStatus,
      isLessonCompleted: isLessonCompleted ?? this.isLessonCompleted,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(Lesson lesson) : super(QuizState(lesson: lesson)) {
    _initCurrentExercise();
  }

  void _initCurrentExercise() {
    final ex = state.currentExercise;
    if (ex is FillBlankExercise) {
      state = state.copyWith(
        filledBlanks: [],
        availableBlankOptions: List.from(ex.options),
        answerStatus: AnswerStatus.unselected,
        isAssistModeActive: false,
        eliminatedOptionIndices: [],
        assistHint: null,
      );
    } else if (ex is TokenReorderExercise) {
      final shuffled = List<String>.from(ex.tokens)..shuffle();
      state = state.copyWith(
        userOrderedTokens: [],
        availableTokens: shuffled,
        answerStatus: AnswerStatus.unselected,
        isAssistModeActive: false,
        eliminatedOptionIndices: [],
        assistHint: null,
      );
    } else {
      state = state.copyWith(
        clearSelection: true,
        answerStatus: AnswerStatus.unselected,
        isAssistModeActive: false,
        eliminatedOptionIndices: [],
        assistHint: null,
      );
    }
  }

  void selectMultipleChoiceOption(int index) {
    if (state.answerStatus == AnswerStatus.correct || state.answerStatus == AnswerStatus.incorrect) {
      return;
    }
    state = state.copyWith(
      selectedOptionIndex: index,
      answerStatus: AnswerStatus.readyToVerify,
    );
  }

  void selectBugLine(int index) {
    if (state.answerStatus == AnswerStatus.correct || state.answerStatus == AnswerStatus.incorrect) {
      return;
    }
    state = state.copyWith(
      selectedBugLineIndex: index,
      answerStatus: AnswerStatus.readyToVerify,
    );
  }

  void addBlankToken(String token) {
    if (state.answerStatus == AnswerStatus.correct || state.answerStatus == AnswerStatus.incorrect) return;
    final ex = state.currentExercise as FillBlankExercise;
    if (state.filledBlanks.length >= ex.correctAnswers.length) return;

    final newFilled = List<String>.from(state.filledBlanks)..add(token);
    final newAvailable = List<String>.from(state.availableBlankOptions)..remove(token);

    final isReady = newFilled.length == ex.correctAnswers.length;
    state = state.copyWith(
      filledBlanks: newFilled,
      availableBlankOptions: newAvailable,
      answerStatus: isReady ? AnswerStatus.readyToVerify : AnswerStatus.unselected,
    );
  }

  void removeBlankToken(int index) {
    if (state.answerStatus == AnswerStatus.correct || state.answerStatus == AnswerStatus.incorrect) return;
    if (index >= state.filledBlanks.length) return;

    final removed = state.filledBlanks[index];
    final newFilled = List<String>.from(state.filledBlanks)..removeAt(index);
    final newAvailable = List<String>.from(state.availableBlankOptions)..add(removed);

    state = state.copyWith(
      filledBlanks: newFilled,
      availableBlankOptions: newAvailable,
      answerStatus: AnswerStatus.unselected,
    );
  }

  void addReorderToken(String token) {
    if (state.answerStatus == AnswerStatus.correct || state.answerStatus == AnswerStatus.incorrect) return;
    final ex = state.currentExercise as TokenReorderExercise;

    final newUserTokens = List<String>.from(state.userOrderedTokens)..add(token);
    final newAvailable = List<String>.from(state.availableTokens)..remove(token);

    final isReady = newUserTokens.length == ex.tokens.length;
    state = state.copyWith(
      userOrderedTokens: newUserTokens,
      availableTokens: newAvailable,
      answerStatus: isReady ? AnswerStatus.readyToVerify : AnswerStatus.unselected,
    );
  }

  void removeReorderToken(int index) {
    if (state.answerStatus == AnswerStatus.correct || state.answerStatus == AnswerStatus.incorrect) return;
    if (index >= state.userOrderedTokens.length) return;

    final removed = state.userOrderedTokens[index];
    final newUserTokens = List<String>.from(state.userOrderedTokens)..removeAt(index);
    final newAvailable = List<String>.from(state.availableTokens)..add(removed);

    state = state.copyWith(
      userOrderedTokens: newUserTokens,
      availableTokens: newAvailable,
      answerStatus: AnswerStatus.unselected,
    );
  }

  void verifyAnswer() {
    final ex = state.currentExercise;

    if (ex is FlashcardExercise) {
      proceedToNext();
      return;
    }

    bool isCorrect = false;

    if (ex is MultipleChoiceExercise) {
      isCorrect = state.selectedOptionIndex == ex.correctAnswerIndex;
    } else if (ex is SpotTheBugExercise) {
      isCorrect = state.selectedBugLineIndex == ex.buggyLineIndex;
    } else if (ex is FillBlankExercise) {
      if (state.filledBlanks.length == ex.correctAnswers.length) {
        isCorrect = true;
        for (int i = 0; i < ex.correctAnswers.length; i++) {
          if (state.filledBlanks[i] != ex.correctAnswers[i]) {
            isCorrect = false;
            break;
          }
        }
      }
    } else if (ex is TokenReorderExercise) {
      if (state.userOrderedTokens.length == ex.correctOrder.length) {
        isCorrect = true;
        for (int i = 0; i < ex.correctOrder.length; i++) {
          if (state.userOrderedTokens[i] != ex.correctOrder[i]) {
            isCorrect = false;
            break;
          }
        }
      }
    }

    if (isCorrect) {
      final earnedXp = state.isAssistModeActive ? 5 : 15;
      final newStreak = state.isAssistModeActive ? state.streakDays : state.streakDays + 1;
      state = state.copyWith(
        answerStatus: AnswerStatus.correct,
        currentXp: state.currentXp + earnedXp,
        streakDays: newStreak,
      );
    } else {
      final remainingLives = (state.lives - 1).clamp(0, 5);
      state = state.copyWith(
        answerStatus: AnswerStatus.incorrect,
        lives: remainingLives,
      );
    }
  }

  void activateAssistMode() {
    final ex = state.currentExercise;

    if (ex is MultipleChoiceExercise) {
      final wrongIndices = <int>[];
      for (int i = 0; i < ex.options.length; i++) {
        if (i != ex.correctAnswerIndex) {
          wrongIndices.add(i);
        }
      }
      wrongIndices.shuffle();
      final toEliminate = wrongIndices.take(2).toList();

      state = state.copyWith(
        isAssistModeActive: true,
        eliminatedOptionIndices: toEliminate,
        assistHint: "💡 Modo Asistencia (50/50): Hemos descartado 2 opciones incorrectas para ayudarte a identificar la respuesta correcta. ¡Elige entre las restantes y salva tu racha!",
        selectedOptionIndex: null,
        clearSelection: true,
        answerStatus: AnswerStatus.unselected,
      );
    } else if (ex is TokenReorderExercise) {
      final total = ex.correctOrder.length;
      final prefillCount = (total * 0.55).ceil().clamp(1, total - 1);
      final prefilled = ex.correctOrder.take(prefillCount).toList();
      final remaining = ex.correctOrder.skip(prefillCount).toList()..shuffle();

      state = state.copyWith(
        isAssistModeActive: true,
        userOrderedTokens: prefilled,
        availableTokens: remaining,
        assistHint: "💡 Modo Semiterminado: Hemos colocado los primeros $prefillCount de $total tokens en orden. ¡Completa el resto para cerrar la sentencia!",
        answerStatus: AnswerStatus.unselected,
      );
    } else if (ex is SpotTheBugExercise) {
      final lineNum = ex.buggyLineIndex + 1;
      state = state.copyWith(
        isAssistModeActive: true,
        assistHint: "💡 Pista del Compilador / Linter: Inspecciona de cerca la Línea $lineNum.",
        answerStatus: AnswerStatus.unselected,
      );
    }
  }

  void proceedToNext() {
    if (state.currentExerciseIndex + 1 < state.lesson.exercises.length) {
      state = state.copyWith(
        currentExerciseIndex: state.currentExerciseIndex + 1,
        answerStatus: AnswerStatus.unselected,
        clearSelection: true,
      );
      _initCurrentExercise();
    } else {
      state = state.copyWith(
        isLessonCompleted: true,
        currentXp: state.currentXp + state.lesson.xpReward,
      );
    }
  }
}

final quizProvider = StateNotifierProvider.autoDispose.family<QuizNotifier, QuizState, Lesson>(
  (ref, lesson) => QuizNotifier(lesson),
);
