class AiEvaluationResult {
  final int score;
  final int technicalScore;
  final int communicationScore;
  final int tradeoffScore;
  final String seniorityVerdict;
  final String verdictBadge;
  final List<String> conceptsCovered;
  final List<String> conceptsMissed;
  final List<String> strengths;
  final List<String> improvements;
  final String feedback;
  final String followUpQuestion;
  final String idealResponse;
  final int xpEarned;

  const AiEvaluationResult({
    required this.score,
    required this.technicalScore,
    required this.communicationScore,
    required this.tradeoffScore,
    required this.seniorityVerdict,
    required this.verdictBadge,
    required this.conceptsCovered,
    required this.conceptsMissed,
    required this.strengths,
    required this.improvements,
    required this.feedback,
    required this.followUpQuestion,
    required this.idealResponse,
    required this.xpEarned,
  });

  factory AiEvaluationResult.fromJson(Map<String, dynamic> json) {
    return AiEvaluationResult(
      score: (json['score'] as num?)?.toInt() ?? 0,
      technicalScore: (json['technicalScore'] as num?)?.toInt() ?? 0,
      communicationScore: (json['communicationScore'] as num?)?.toInt() ?? 0,
      tradeoffScore: (json['tradeoffScore'] as num?)?.toInt() ?? 0,
      seniorityVerdict: json['seniorityVerdict'] as String? ?? 'Mid-Level',
      verdictBadge: json['verdictBadge'] as String? ?? 'SENIOR',
      conceptsCovered: List<String>.from(json['conceptsCovered'] ?? []),
      conceptsMissed: List<String>.from(json['conceptsMissed'] ?? []),
      strengths: List<String>.from(json['strengths'] ?? []),
      improvements: List<String>.from(json['improvements'] ?? []),
      feedback: json['feedback'] as String? ?? '',
      followUpQuestion: json['followUpQuestion'] as String? ?? '',
      idealResponse: json['idealResponse'] as String? ?? '',
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 50,
    );
  }
}
