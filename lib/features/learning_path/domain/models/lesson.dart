import '../../quiz/domain/models/exercise.dart';

class Lesson {
  final String id;
  final String title;
  final int xpReward;
  final List<Exercise> exercises;

  const Lesson({
    required this.id,
    required this.title,
    required this.xpReward,
    required this.exercises,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      xpReward: json['xpReward'] as int,
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
