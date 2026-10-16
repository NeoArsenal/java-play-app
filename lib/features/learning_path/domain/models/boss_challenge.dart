import 'package:java_play_app/features/quiz/domain/models/exercise.dart';

class BossChallenge {
  final String id;
  final String title;
  final String bossName;
  final String bossAvatar;
  final String description;
  final int passThreshold;
  final int xpReward;
  final int timeLimitSeconds;
  final List<Exercise> exercises;

  const BossChallenge({
    required this.id,
    required this.title,
    required this.bossName,
    required this.bossAvatar,
    required this.description,
    required this.passThreshold,
    required this.xpReward,
    required this.timeLimitSeconds,
    required this.exercises,
  });

  factory BossChallenge.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'] as List? ?? [];
    return BossChallenge(
      id: json['id'] as String? ?? 'boss_default',
      title: json['title'] as String? ?? 'Desafío Final',
      bossName: json['bossName'] as String? ?? 'Guardián del Módulo',
      bossAvatar: json['bossAvatar'] as String? ?? '👑',
      description: json['description'] as String? ?? '',
      passThreshold: json['passThreshold'] as int? ?? 80,
      xpReward: json['xpReward'] as int? ?? 150,
      timeLimitSeconds: json['timeLimitSeconds'] as int? ?? 180,
      exercises: rawExercises
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
