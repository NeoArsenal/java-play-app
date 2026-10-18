import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models/interview_question.dart';
import '../domain/models/ai_evaluation_result.dart';
import 'mock_interview_catalog.dart';

class MockInterviewRepository {
  final String baseUrl;
  final http.Client client;
  String? lastNotice;

  MockInterviewRepository({
    this.baseUrl = 'https://javaplay-app-btgxddftd2cxehhy.eastus2-01.azurewebsites.net/api',
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<List<InterviewQuestion>> getQuestions() async {
    try {
      final res = await client.get(Uri.parse('$baseUrl/mock/questions'));
      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(utf8.decode(res.bodyBytes));
        if (list.isNotEmpty) {
          return list.map((item) => InterviewQuestion.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}
    return MockInterviewCatalog.allQuestions;
  }

  Future<AiEvaluationResult?> evaluateAnswer({
    required String userId,
    required String questionId,
    required String transcript,
    int durationSeconds = 45,
  }) async {
    lastNotice = null;
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
      } else if (res.statusCode == 429) {
        lastNotice = 'Límite de evaluaciones por hora alcanzado. Evaluado con el motor local.';
      } else if (res.statusCode == 503) {
        lastNotice = 'Cuota diaria de IA del servidor alcanzada. Evaluado con el motor local.';
      } else {
        lastNotice = 'Servicio remoto no disponible. Evaluado con el motor local.';
      }
    } catch (_) {
      lastNotice = 'Sin conexión con el servidor. Evaluado con el motor local.';
    }
    return null;
  }
}
