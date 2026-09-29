import '../../../quiz/domain/models/exercise.dart';

class SrsCard {
  final String id;
  final String userId;
  final String exerciseId;
  final String worldId;
  final int repetitions;
  final int intervalDays;
  final double easeFactor;
  final int? lastQuality;
  final DateTime nextReviewAt;
  final DateTime lastReviewedAt;
  final Exercise? exercise;

  const SrsCard({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.worldId,
    this.repetitions = 0,
    this.intervalDays = 1,
    this.easeFactor = 2.50,
    this.lastQuality,
    required this.nextReviewAt,
    required this.lastReviewedAt,
    this.exercise,
  });

  bool get isDueToday => nextReviewAt.isBefore(DateTime.now());
  bool get isMastered => repetitions >= 3 && intervalDays >= 14;

  factory SrsCard.fromJson(Map<String, dynamic> json) {
    return SrsCard(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      exerciseId: json['exercise_id'] as String,
      worldId: (json['world_id'] as String?) ?? 'nivel_0',
      repetitions: json['repetitions'] as int? ?? 0,
      intervalDays: json['interval_days'] as int? ?? 1,
      easeFactor: (json['ease_factor'] is num) ? (json['ease_factor'] as num).toDouble() : 2.50,
      lastQuality: json['last_quality'] as int?,
      nextReviewAt: DateTime.tryParse(json['next_review_at']?.toString() ?? '') ?? DateTime.now(),
      lastReviewedAt: DateTime.tryParse(json['last_reviewed_at']?.toString() ?? '') ?? DateTime.now(),
      exercise: json['exercise'] != null ? Exercise.fromJson(json['exercise']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'exercise_id': exerciseId,
      'world_id': worldId,
      'repetitions': repetitions,
      'interval_days': intervalDays,
      'ease_factor': easeFactor,
      'last_quality': lastQuality,
      'next_review_at': nextReviewAt.toIso8601String(),
      'last_reviewed_at': lastReviewedAt.toIso8601String(),
      if (exercise != null) 'exercise': exercise!.toJson(),
    };
  }

  SrsCard copyWith({
    int? repetitions,
    int? intervalDays,
    double? easeFactor,
    int? lastQuality,
    DateTime? nextReviewAt,
    DateTime? lastReviewedAt,
    Exercise? exercise,
  }) {
    return SrsCard(
      id: id,
      userId: userId,
      exerciseId: exerciseId,
      worldId: worldId,
      repetitions: repetitions ?? this.repetitions,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      lastQuality: lastQuality ?? this.lastQuality,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      exercise: exercise ?? this.exercise,
    );
  }
}
