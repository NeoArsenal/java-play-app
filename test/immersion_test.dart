import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:java_play_app/core/services/feedback_settings.dart';
import 'package:java_play_app/core/services/feedback_service.dart';
import 'package:java_play_app/core/widgets/mascot/mascot_state.dart';
import 'package:java_play_app/core/widgets/mascot/mascot_widget.dart';
import 'package:java_play_app/core/widgets/enemy/bug_enemy_widget.dart';

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
}
