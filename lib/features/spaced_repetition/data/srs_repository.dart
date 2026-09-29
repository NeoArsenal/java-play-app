import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models/srs_card.dart';
import '../domain/models/srs_stats.dart';

class SrsRepository {
  final String baseUrl;
  final http.Client client;

  SrsRepository({
    this.baseUrl = 'http://localhost:8080/api',
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<List<SrsCard>> getDueCards(String userId) async {
    try {
      final res = await client.get(Uri.parse('$baseUrl/srs/$userId/due'));
      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        return list.map((item) => SrsCard.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<SrsStats> getStats(String userId) async {
    try {
      final res = await client.get(Uri.parse('$baseUrl/srs/$userId/stats'));
      if (res.statusCode == 200) {
        return SrsStats.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return const SrsStats();
  }

  Future<bool> submitReview({
    required String userId,
    required String exerciseId,
    required String worldId,
    required int quality,
  }) async {
    try {
      final res = await client.post(
        Uri.parse('$baseUrl/srs/$userId/review'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'exerciseId': exerciseId,
          'worldId': worldId,
          'quality': quality,
        }),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
