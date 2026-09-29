class InterviewQuestion {
  final String id;
  final String title;
  final String question;
  final String category;
  final int timeLimitSeconds;
  final String idealResponse;
  final String followUpQuestion;
  final List<String> keyConcepts;

  const InterviewQuestion({
    required this.id,
    required this.title,
    required this.question,
    this.category = 'Java & Spring',
    required this.timeLimitSeconds,
    required this.idealResponse,
    this.followUpQuestion = '',
    required this.keyConcepts,
  });

  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      id: json['id'] as String,
      title: json['title'] as String,
      question: json['question'] as String,
      category: json['category'] as String? ?? 'Java & Spring',
      timeLimitSeconds: json['timeLimitSeconds'] as int? ?? 60,
      idealResponse: json['idealResponse'] as String? ?? '',
      followUpQuestion: json['followUpQuestion'] as String? ?? '',
      keyConcepts: List<String>.from(json['keyConcepts'] ?? []),
    );
  }
}
