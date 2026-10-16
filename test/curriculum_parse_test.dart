import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:java_play_app/features/learning_path/domain/models/world.dart';

void main() {
  test('Parses curriculum.json worlds without error', () {
    final file = File('assets/data/curriculum.json');
    final jsonStr = file.readAsStringSync();
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final worldsJson = data['worlds'] as List;
    final worlds = worldsJson.map((w) => World.fromJson(w as Map<String, dynamic>)).toList();
    expect(worlds.length, 11);
    for (final w in worlds) {
      expect(w.lessons.isNotEmpty, true);
    }
  });

  test('All worlds have fully configured Boss Challenges with exercises', () {
    final file = File('assets/data/curriculum.json');
    final jsonStr = file.readAsStringSync();
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final worldsJson = data['worlds'] as List;
    final worlds = worldsJson.map((w) => World.fromJson(w as Map<String, dynamic>)).toList();

    for (final w in worlds) {
      expect(w.bossChallenge, isNotNull, reason: 'World ${w.id} must have a bossChallenge');
      expect(w.bossChallenge!.exercises.isNotEmpty, true, reason: 'Boss in ${w.id} must have exercises');
      expect(w.bossChallenge!.passThreshold >= 80, true);
      expect(w.bossChallenge!.bossAvatar.isNotEmpty, true);
    }
  });

  test('Mundo 1, Mundo 2 and Mundo 3 have diverse, non-repeating questions across levels', () {
    final file = File('assets/data/curriculum.json');
    final jsonStr = file.readAsStringSync();
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final worldsJson = data['worlds'] as List;
    final worlds = worldsJson.map((w) => World.fromJson(w as Map<String, dynamic>)).toList();

    for (final worldId in ['mundo_1', 'mundo_2', 'mundo_3']) {
      final world = worlds.firstWhere((w) => w.id == worldId);
      final questionTitles = <String>{};
      int totalQuestions = 0;

      for (final lesson in world.lessons) {
        for (final exercise in lesson.exercises) {
          totalQuestions++;
          questionTitles.add(exercise.title);
        }
      }

      // Ensure 100% unique titles across lessons
      expect(questionTitles.length, totalQuestions,
          reason: 'World $worldId must have 100% unique questions without duplicates');
    }
  });

  test('Mundo 1 Level 3 and Level 4 have completely different last questions and unique content', () {
    final file = File('assets/data/curriculum.json');
    final jsonStr = file.readAsStringSync();
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final worldsJson = data['worlds'] as List;
    final worlds = worldsJson.map((w) => World.fromJson(w as Map<String, dynamic>)).toList();

    final m1 = worlds.firstWhere((w) => w.id == 'mundo_1');
    final l3 = m1.lessons.firstWhere((l) => l.id == 'mundo_1_l3');
    final l4 = m1.lessons.firstWhere((l) => l.id == 'mundo_1_l4');

    final l3Last = l3.exercises.last;
    final l4Last = l4.exercises.last;

    expect(l3Last.title != l4Last.title, true, reason: 'L3 and L4 must have different last questions');
    expect(l3Last.id != l4Last.id, true);
    expect(l3Last.explanation != l4Last.explanation, true);
  });

  test('Every lesson across all 11 worlds contains the interactive FILL_BLANK dynamic', () {
    final file = File('assets/data/curriculum.json');
    final jsonStr = file.readAsStringSync();
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final worldsJson = data['worlds'] as List;
    final worlds = worldsJson.map((w) => World.fromJson(w as Map<String, dynamic>)).toList();

    for (final w in worlds) {
      for (final l in w.lessons) {
        final hasFillBlank = l.exercises.any((e) => e.type.name == 'fillBlank');
        expect(hasFillBlank, true, reason: 'Lesson ${l.id} in ${w.id} must include FILL_BLANK exercise');
      }
    }
  });

  test('Difficulty question limits (5, 7, 10) generate exact count without duplicates', () {
    final file = File('assets/data/curriculum.json');
    final jsonStr = file.readAsStringSync();
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final worldsJson = data['worlds'] as List;
    final worlds = worldsJson.map((w) => World.fromJson(w as Map<String, dynamic>)).toList();

    for (final targetCount in [5, 7, 10]) {
      for (final world in worlds) {
        for (final lesson in world.lessons) {
          var exerciseSubset = List.from(lesson.exercises);
          if (exerciseSubset.length > targetCount) {
            exerciseSubset = exerciseSubset.take(targetCount).toList();
          } else if (exerciseSubset.length < targetCount) {
            final existingIds = exerciseSubset.map((e) => e.id).toSet();
            final existingTitles = exerciseSubset.map((e) => e.title.trim().toLowerCase()).toSet();

            for (final otherLesson in world.lessons) {
              if (otherLesson.id == lesson.id) continue;
              for (final ex in otherLesson.exercises) {
                final normTitle = ex.title.trim().toLowerCase();
                if (!existingIds.contains(ex.id) && !existingTitles.contains(normTitle)) {
                  exerciseSubset.add(ex);
                  existingIds.add(ex.id);
                  existingTitles.add(normTitle);
                  if (exerciseSubset.length >= targetCount) break;
                }
              }
              if (exerciseSubset.length >= targetCount) break;
            }
          }

          expect(exerciseSubset.length, targetCount,
              reason: 'Lesson ${lesson.id} in ${world.id} must have exactly $targetCount exercises');

          final ids = exerciseSubset.map((e) => e.id).toSet();
          expect(ids.length, targetCount,
              reason: 'Lesson ${lesson.id} must not have duplicate IDs for target $targetCount');
        }
      }
    }
  });
}

