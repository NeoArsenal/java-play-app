import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> curriculumData;
  late List<Map<String, dynamic>> worlds;
  late List<Map<String, dynamic>> allLessonExercises;
  late List<Map<String, dynamic>> allBossExercises;
  late List<Map<String, dynamic>> allExercises;

  setUpAll(() {
    final file = File('assets/data/curriculum.json');
    expect(file.existsSync(), isTrue, reason: 'assets/data/curriculum.json must exist');
    final jsonStr = file.readAsStringSync();
    curriculumData = json.decode(jsonStr) as Map<String, dynamic>;
    worlds = (curriculumData['worlds'] as List).cast<Map<String, dynamic>>();

    allLessonExercises = [];
    allBossExercises = [];

    for (final world in worlds) {
      final lessons = (world['lessons'] as List).cast<Map<String, dynamic>>();
      for (final lesson in lessons) {
        final exercises = (lesson['exercises'] as List).cast<Map<String, dynamic>>();
        allLessonExercises.addAll(exercises);
      }

      final boss = world['bossChallenge'] as Map<String, dynamic>?;
      if (boss != null) {
        final exercises = (boss['exercises'] as List).cast<Map<String, dynamic>>();
        allBossExercises.addAll(exercises);
      }
    }

    allExercises = [...allLessonExercises, ...allBossExercises];
  });

  group('Curriculum Structure & Integrity Tests', () {
    test('Every lesson has exactly 10 exercises', () {
      int totalLessons = 0;
      for (final world in worlds) {
        final worldId = world['id'] as String;
        final lessons = (world['lessons'] as List).cast<Map<String, dynamic>>();
        for (final lesson in lessons) {
          totalLessons++;
          final lessonId = lesson['id'] as String;
          final exercises = (lesson['exercises'] as List).cast<Map<String, dynamic>>();
          expect(
            exercises.length,
            10,
            reason: 'Lesson $lessonId in world $worldId must have exactly 10 exercises, but has ${exercises.length}',
          );
        }
      }
      expect(totalLessons, 105, reason: 'Total lessons must be 105 across 11 worlds');
      expect(allLessonExercises.length, 1050, reason: 'Total lesson exercises must be 1050');
      expect(allBossExercises.length, 58, reason: 'Total boss exercises must be 58');
      expect(allExercises.length, 1108, reason: 'Total exercises must be 1108');
    });

    test('All exercise IDs are globally unique across all lessons and bosses', () {
      final seenIds = <String, String>{};
      final duplicates = <String>[];

      for (final world in worlds) {
        final worldId = world['id'] as String;
        final lessons = (world['lessons'] as List).cast<Map<String, dynamic>>();
        for (final lesson in lessons) {
          final lessonId = lesson['id'] as String;
          final exercises = (lesson['exercises'] as List).cast<Map<String, dynamic>>();
          for (final ex in exercises) {
            final id = ex['id'] as String;
            final loc = '$worldId/$lessonId';
            if (seenIds.containsKey(id)) {
              duplicates.add('Duplicate ID: "$id" in $loc and ${seenIds[id]}');
            } else {
              seenIds[id] = loc;
            }
          }
        }

        final boss = world['bossChallenge'] as Map<String, dynamic>?;
        if (boss != null) {
          final exercises = (boss['exercises'] as List).cast<Map<String, dynamic>>();
          for (final ex in exercises) {
            final id = ex['id'] as String;
            final loc = '$worldId/boss';
            if (seenIds.containsKey(id)) {
              duplicates.add('Duplicate ID: "$id" in $loc and ${seenIds[id]}');
            } else {
              seenIds[id] = loc;
            }
          }
        }
      }

      expect(duplicates, isEmpty, reason: 'Duplicate exercise IDs found:\n${duplicates.join('\n')}');
      expect(seenIds.length, 1108);
    });

    test('All exercises have recognized type and non-empty explanation', () {
      const recognizedTypes = {
        'FLASHCARD',
        'MULTIPLE_CHOICE',
        'FILL_BLANK',
        'TOKEN_REORDER',
        'SPOT_THE_BUG',
      };

      for (final ex in allExercises) {
        final id = ex['id'] as String;
        final type = ex['type'] as String?;
        expect(
          recognizedTypes.contains(type),
          isTrue,
          reason: 'Exercise $id has unrecognized type: "$type"',
        );

        final explanation = (ex['explanation'] as String?) ?? (ex['exp'] as String?);
        expect(
          explanation != null && explanation.trim().isNotEmpty,
          isTrue,
          reason: 'Exercise $id must have a non-empty explanation',
        );
      }
    });

    test('MULTIPLE_CHOICE: at least 2 options and correctAnswerIndex within valid range', () {
      final mcExercises = allExercises.where((e) => e['type'] == 'MULTIPLE_CHOICE');
      expect(mcExercises, isNotEmpty);

      for (final ex in mcExercises) {
        final id = ex['id'] as String;
        final options = (ex['options'] as List?)?.cast<String>();
        expect(options, isNotNull, reason: 'Exercise $id must have options list');
        expect(
          options!.length >= 2,
          isTrue,
          reason: 'Exercise $id must have at least 2 options (has ${options.length})',
        );

        final correctIndex = ex['correctAnswerIndex'] as int?;
        expect(correctIndex, isNotNull, reason: 'Exercise $id must have correctAnswerIndex');
        expect(
          correctIndex! >= 0 && correctIndex < options.length,
          isTrue,
          reason: 'Exercise $id correctAnswerIndex ($correctIndex) is out of range for options length ${options.length}',
        );
      }
    });

    test('FILL_BLANK: each item of correctAnswers exists in options', () {
      final fbExercises = allExercises.where((e) => e['type'] == 'FILL_BLANK');
      expect(fbExercises, isNotEmpty);

      for (final ex in fbExercises) {
        final id = ex['id'] as String;
        final options = (ex['options'] as List?)?.cast<String>();
        expect(options, isNotNull, reason: 'Exercise $id must have options list');
        expect(options!.isNotEmpty, isTrue, reason: 'Exercise $id options must not be empty');

        final correctAnswers = (ex['correctAnswers'] as List?)?.cast<String>();
        expect(correctAnswers, isNotNull, reason: 'Exercise $id must have correctAnswers list');
        expect(correctAnswers!.isNotEmpty, isTrue, reason: 'Exercise $id correctAnswers must not be empty');

        for (final answer in correctAnswers) {
          expect(
            options.contains(answer),
            isTrue,
            reason: 'Exercise $id correct answer "$answer" is missing from options: $options',
          );
        }
      }
    });

    test('SPOT_THE_BUG: 0 <= buggyLineIndex < codeLines.length', () {
      final stbExercises = allExercises.where((e) => e['type'] == 'SPOT_THE_BUG');
      expect(stbExercises, isNotEmpty);

      for (final ex in stbExercises) {
        final id = ex['id'] as String;
        final codeLines = (ex['codeLines'] as List?)?.cast<String>();
        expect(codeLines, isNotNull, reason: 'Exercise $id must have codeLines');
        expect(codeLines!.isNotEmpty, isTrue, reason: 'Exercise $id codeLines must not be empty');

        final buggyIndex = ex['buggyLineIndex'] as int?;
        expect(buggyIndex, isNotNull, reason: 'Exercise $id must have buggyLineIndex');
        expect(
          buggyIndex! >= 0 && buggyIndex < codeLines.length,
          isTrue,
          reason: 'Exercise $id buggyLineIndex ($buggyIndex) is out of range for codeLines count ${codeLines.length}',
        );
      }
    });

    test('TOKEN_REORDER: correctOrder is a valid permutation of tokens', () {
      final trExercises = allExercises.where((e) => e['type'] == 'TOKEN_REORDER');
      expect(trExercises, isNotEmpty);

      for (final ex in trExercises) {
        final id = ex['id'] as String;
        final tokens = (ex['tokens'] as List?)?.cast<String>();
        final correctOrder = (ex['correctOrder'] as List?)?.cast<String>();

        expect(tokens, isNotNull, reason: 'Exercise $id must have tokens list');
        expect(correctOrder, isNotNull, reason: 'Exercise $id must have correctOrder list');
        expect(
          tokens!.length,
          correctOrder!.length,
          reason: 'Exercise $id tokens length (${tokens.length}) != correctOrder length (${correctOrder.length})',
        );

        final sortedTokens = List<String>.from(tokens)..sort();
        final sortedOrder = List<String>.from(correctOrder)..sort();
        expect(
          sortedOrder,
          equals(sortedTokens),
          reason: 'Exercise $id correctOrder $correctOrder is not a permutation of tokens $tokens',
        );
      }
    });

    test('FLASHCARD: codeSnippet or explanation is non-empty', () {
      final fcExercises = allExercises.where((e) => e['type'] == 'FLASHCARD');
      expect(fcExercises, isNotEmpty);

      for (final ex in fcExercises) {
        final id = ex['id'] as String;
        final codeSnippet = ex['codeSnippet'] as String?;
        final explanation = (ex['explanation'] as String?) ?? (ex['exp'] as String?);

        final hasCode = codeSnippet != null && codeSnippet.trim().isNotEmpty;
        final hasExp = explanation != null && explanation.trim().isNotEmpty;

        expect(
          hasCode || hasExp,
          isTrue,
          reason: 'Exercise $id FLASHCARD must have either a non-empty codeSnippet or explanation',
        );
      }
    });
  });
}
