import 'package:flutter_test/flutter_test.dart';
import 'package:java_play_app/features/mock_interview/data/mock_interview_catalog.dart';

void main() {
  test('MockInterviewCatalog contains valid questions for all 11 worlds', () {
    expect(MockInterviewCatalog.allQuestions.isNotEmpty, isTrue);

    for (int i = 0; i <= 10; i++) {
      final worldId = 'mundo_$i';
      final questions = MockInterviewCatalog.getQuestionsForWorld(worldId);
      expect(questions.isNotEmpty, isTrue, reason: 'World $worldId should have interview questions');
      for (final q in questions) {
        expect(q.worldId, equals(worldId));
        expect(q.title.isNotEmpty, isTrue);
        expect(q.question.isNotEmpty, isTrue);
        expect(q.keyConcepts.isNotEmpty, isTrue);
        expect(q.idealResponse.isNotEmpty, isTrue);
        expect(q.timeLimitSeconds, greaterThanOrEqualTo(45));
      }
    }
  });

  test('Mundo 0 questions are beginner-friendly and Mundo 10 are advanced architecture', () {
    final m0 = MockInterviewCatalog.getQuestionsForWorld('mundo_0');
    final m10 = MockInterviewCatalog.getQuestionsForWorld('mundo_10');

    // Mundo 0 tests variables, if/else, loops, main
    expect(m0.any((q) => q.title.toLowerCase().contains('variable')), isTrue);
    expect(m0.any((q) => q.title.toLowerCase().contains('condicional') || q.title.toLowerCase().contains('bucle')), isTrue);

    // Mundo 10 tests Virtual Threads, JMM, Spring Security
    expect(m10.any((q) => q.title.toLowerCase().contains('virtual threads') || q.title.toLowerCase().contains('loom')), isTrue);
    expect(m10.any((q) => q.title.toLowerCase().contains('volatile') || q.title.toLowerCase().contains('memory model')), isTrue);
  });
}
