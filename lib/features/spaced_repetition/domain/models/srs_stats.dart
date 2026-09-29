class SrsStats {
  final int totalCards;
  final int dueToday;
  final int mastered;
  final int learning;
  final double avgEaseFactor;
  final String retentionRate;

  const SrsStats({
    this.totalCards = 0,
    this.dueToday = 0,
    this.mastered = 0,
    this.learning = 0,
    this.avgEaseFactor = 2.50,
    this.retentionRate = '85%',
  });

  factory SrsStats.fromJson(Map<String, dynamic> json) {
    return SrsStats(
      totalCards: json['totalCards'] as int? ?? 0,
      dueToday: json['dueToday'] as int? ?? 0,
      mastered: json['mastered'] as int? ?? 0,
      learning: json['learning'] as int? ?? 0,
      avgEaseFactor: (json['avgEaseFactor'] is num) ? (json['avgEaseFactor'] as num).toDouble() : 2.50,
      retentionRate: json['retentionRate'] as String? ?? '85%',
    );
  }
}
