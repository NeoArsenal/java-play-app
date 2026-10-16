import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BossRepository {
  final String baseUrl;
  final http.Client client;

  BossRepository({
    this.baseUrl = 'https://javaplay-app-btgxddftd2cxehhy.eastus2-01.azurewebsites.net/api',
    http.Client? client,
  }) : client = client ?? http.Client();

  /// Obtiene los IDs de mundos cuyos jefes han sido derrotados (Sincronizado con Supabase y SharedPreferences)
  Future<Set<String>> getCompletedBosses(String userId) async {
    final Set<String> completed = {};
    try {
      final prefs = await SharedPreferences.getInstance();
      final localList = prefs.getStringList('completed_bosses_$userId') ?? [];
      completed.addAll(localList);

      // Intento de sincronización con la base de datos Supabase a través del backend
      final res = await client.get(Uri.parse('$baseUrl/boss/$userId')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
        for (final item in data) {
          if (item['world_id'] != null) {
            completed.add(item['world_id'].toString());
          }
        }
        await prefs.setStringList('completed_bosses_$userId', completed.toList());
      }
    } catch (e) {
      debugPrint("BossRepository getCompletedBosses cache fallback: $e");
    }
    return completed;
  }

  /// Registra la victoria ante un Jefe en SharedPreferences y la persiste en Supabase
  Future<bool> recordBossDefeat({
    required String userId,
    required String worldId,
    required String bossId,
    required int score,
    int xpAwarded = 150,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localList = prefs.getStringList('completed_bosses_$userId') ?? [];
      if (!localList.contains(worldId)) {
        localList.add(worldId);
        await prefs.setStringList('completed_bosses_$userId', localList);
      }

      // Enviar a Supabase via Backend API
      final res = await client.post(
        Uri.parse('$baseUrl/boss/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'worldId': worldId,
          'bossId': bossId,
          'score': score,
          'xpAwarded': xpAwarded,
        }),
      ).timeout(const Duration(seconds: 5));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint("BossRepository recordBossDefeat local fallback: $e");
      return false;
    }
  }
}
