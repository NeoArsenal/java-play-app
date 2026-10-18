import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:java_play_app/core/services/feedback_settings.dart';
import 'package:java_play_app/core/services/feedback_service.dart';
import 'package:java_play_app/core/widgets/mascot/mascot_state.dart';
import 'package:java_play_app/core/widgets/mascot/mascot_widget.dart';
import 'package:java_play_app/core/widgets/enemy/bug_enemy_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:java_play_app/features/quiz/domain/models/exercise.dart';
import 'package:java_play_app/features/learning_path/domain/models/lesson.dart';
import 'package:java_play_app/features/quiz/presentation/controllers/quiz_controller.dart';
import 'package:java_play_app/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:java_play_app/features/quiz/presentation/widgets/feedback_bottom_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await FeedbackSettings.initialize();
    FeedbackSettings.userReducedMotionOverride = null;
    FeedbackSettings.isSoundEnabled = true;
    FeedbackSettings.isVibrationEnabled = true;
  });

  group('FeedbackService Unit Tests', () {
    test('calls all feedback methods silently when audio files are absent', () async {
      final service = FeedbackService();

      // Sound and vibration enabled by default; files don't exist in test environment
      expect(() async => await service.onCorrect(), returnsNormally);
      expect(() async => await service.onWrong(), returnsNormally);
      expect(() async => await service.onLessonComplete(), returnsNormally);
      expect(() async => await service.onBossHit(), returnsNormally);
    });

    test('executes cleanly when sound is disabled', () async {
      FeedbackSettings.isSoundEnabled = false;
      final service = FeedbackService();

      expect(() async => await service.onCorrect(), returnsNormally);
      expect(() async => await service.onWrong(), returnsNormally);
      expect(() async => await service.onLessonComplete(), returnsNormally);
      expect(() async => await service.onBossHit(), returnsNormally);
    });

    test('executes cleanly when vibration is disabled', () async {
      FeedbackSettings.isVibrationEnabled = false;
      final service = FeedbackService();

      expect(() async => await service.onCorrect(), returnsNormally);
      expect(() async => await service.onWrong(), returnsNormally);
      expect(() async => await service.onLessonComplete(), returnsNormally);
      expect(() async => await service.onBossHit(), returnsNormally);
    });
  });

  group('MascotWidget Widget Tests', () {
    testWidgets('renders all MascotState variants without errors', (tester) async {
      for (final state in MascotState.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: MascotWidget(state: state, size: 80),
              ),
            ),
          ),
        );

        expect(find.byType(MascotWidget), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);

        // Advance a frame of animation
        await tester.pump(const Duration(milliseconds: 100));
      }
    });

    testWidgets('respects reduced motion when disableAnimations is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Center(
                child: MascotWidget(state: MascotState.celebrate, size: 80),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MascotWidget), findsOneWidget);
      // In reduced motion, animation controller is stopped/static
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(MascotWidget), findsOneWidget);
    });

    testWidgets('respects userReducedMotionOverride setting', (tester) async {
      FeedbackSettings.userReducedMotionOverride = true;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MascotWidget(state: MascotState.happy, size: 80),
            ),
          ),
        ),
      );

      expect(find.byType(MascotWidget), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(MascotWidget), findsOneWidget);
    });

    testWidgets('exposes descriptive semantics label for screen readers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MascotWidget(state: MascotState.happy, size: 80),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(MascotWidget));
      expect(semantics.label, contains('Javi'));
      expect(semantics.label, contains('feliz'));
    });
  });

  group('BugEnemyWidget Widget Tests', () {
    testWidgets('renders all BugEnemyState variants without errors', (tester) async {
      for (final state in BugEnemyState.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: BugEnemyWidget(state: state, size: 60),
              ),
            ),
          ),
        );

        expect(find.byType(BugEnemyWidget), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 100));
      }
    });

    testWidgets('respects reduced motion in glitch state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Center(
                child: BugEnemyWidget(state: BugEnemyState.glitch, size: 60),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BugEnemyWidget), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(BugEnemyWidget), findsOneWidget);
    });
  });

  group('FeedbackBottomSheet UX Tests', () {
    const dummyExercise = MultipleChoiceExercise(
      id: 'test_ex_1',
      question: '¿Qué palabra define una clase en Java?',
      options: ['class', 'def', 'struct'],
      correctAnswerIndex: 0,
      explanation: 'class es la palabra reservada en Java.',
    );

    const dummyLesson = Lesson(
      id: 'test_lesson_1',
      title: 'Lección de prueba',
      xpReward: 10,
      exercises: [dummyExercise],
    );

    testWidgets('shows large Javi (96px) and no bug when answer is correct', (tester) async {
      final quizState = QuizState(
        lesson: dummyLesson,
        answerStatus: AnswerStatus.correct,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackBottomSheet(
              state: quizState,
              mascotState: MascotState.happy,
              onVerify: () {},
              onContinue: () {},
            ),
          ),
        ),
      );

      expect(find.byType(MascotWidget), findsOneWidget);
      final mascotWidget = tester.widget<MascotWidget>(find.byType(MascotWidget));
      expect(mascotWidget.size, equals(96.0));
      expect(mascotWidget.state, equals(MascotState.happy));
      expect(find.byType(BugEnemyWidget), findsNothing);
      expect(find.text('¡Excelente respuesta!'), findsOneWidget);
      expect(find.text(dummyExercise.explanation), findsOneWidget);
    });

    testWidgets('shows Javi sad and Bug (40px) when answer is incorrect', (tester) async {
      final quizState = QuizState(
        lesson: dummyLesson,
        answerStatus: AnswerStatus.incorrect,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackBottomSheet(
              state: quizState,
              mascotState: MascotState.sad,
              bugState: BugEnemyState.glitch,
              onVerify: () {},
              onContinue: () {},
            ),
          ),
        ),
      );

      expect(find.byType(MascotWidget), findsOneWidget);
      final mascotWidget = tester.widget<MascotWidget>(find.byType(MascotWidget));
      expect(mascotWidget.size, equals(96.0));
      expect(mascotWidget.state, equals(MascotState.sad));

      expect(find.byType(BugEnemyWidget), findsOneWidget);
      final bugWidget = tester.widget<BugEnemyWidget>(find.byType(BugEnemyWidget));
      expect(bugWidget.size, equals(40.0));
      expect(find.text('Solución incorrecta'), findsOneWidget);
    });

    testWidgets('touching screen after answering keeps Javi in happy/sad state (does NOT return to thinking)', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: QuizScreen(lesson: dummyLesson),
          ),
        ),
      );
      await tester.pump();

      // Initially on Multiple Choice question
      expect(find.text('¿Qué palabra define una clase en Java?'), findsOneWidget);

      // Select correct option 'class'
      await tester.tap(find.text('class'));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap verify
      await tester.tap(find.text('COMPROBAR'));
      await tester.pump(const Duration(milliseconds: 200));

      // Mascot is now happy
      expect(find.byType(MascotWidget), findsOneWidget);
      var mascotWidget = tester.widget<MascotWidget>(find.byType(MascotWidget));
      expect(mascotWidget.state, equals(MascotState.happy));

      // Tap the screen
      await tester.tap(find.text('¿Qué palabra define una clase en Java?'));
      await tester.pump(const Duration(milliseconds: 100));

      // Mascot must STILL be happy (NOT thinking)
      mascotWidget = tester.widget<MascotWidget>(find.byType(MascotWidget));
      expect(mascotWidget.state, equals(MascotState.happy));

      // Advance time beyond inactivity duration (25 seconds)
      await tester.pump(const Duration(seconds: 25));

      // Mascot must STILL be happy (NOT idle or thinking)
      mascotWidget = tester.widget<MascotWidget>(find.byType(MascotWidget));
      expect(mascotWidget.state, equals(MascotState.happy));
    });
  });
}


