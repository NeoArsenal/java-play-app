import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models/interview_question.dart';
import '../domain/models/ai_evaluation_result.dart';

class MockInterviewRepository {
  final String baseUrl;
  final http.Client client;

  MockInterviewRepository({
    this.baseUrl = 'http://localhost:8080/api',
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<List<InterviewQuestion>> getQuestions() async {
    try {
      final res = await client.get(Uri.parse('$baseUrl/mock/questions'));
      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(utf8.decode(res.bodyBytes));
        return list.map((item) => InterviewQuestion.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<AiEvaluationResult?> evaluateAnswer({
    required String userId,
    required String questionId,
    required String transcript,
    int durationSeconds = 45,
  }) async {
    try {
      final res = await client.post(
        Uri.parse('$baseUrl/mock/evaluate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'questionId': questionId,
          'transcript': transcript,
          'durationSeconds': durationSeconds,
        }),
      );
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data['evaluation'] != null) {
          return AiEvaluationResult.fromJson(data['evaluation'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }
}
