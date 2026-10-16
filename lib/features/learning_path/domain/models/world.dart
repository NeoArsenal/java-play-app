import 'package:flutter/material.dart';
import 'lesson.dart';
import 'boss_challenge.dart';

class World {
  final String id;
  final String title;
  final String description;
  final String badge;
  final Color color;
  final int order;
  final List<Lesson> lessons;
  final BossChallenge? bossChallenge;

  const World({
    required this.id,
    required this.title,
    required this.description,
    this.badge = '🐣',
    required this.color,
    required this.order,
    required this.lessons,
    this.bossChallenge,
  });

  factory World.fromJson(Map<String, dynamic> json) {
    Color parseColor(String? hexString) {
      if (hexString == null) return const Color(0xFF58CC02);
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    }

    final rawBoss = json['bossChallenge'] as Map<String, dynamic>?;

    return World(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      badge: json['badge'] as String? ?? '🌱',
      color: parseColor(json['color'] as String?),
      order: json['order'] as int? ?? 1,
      lessons: (json['lessons'] as List)
          .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
          .toList(),
      bossChallenge: rawBoss != null ? BossChallenge.fromJson(rawBoss) : null,
    );
  }
}

