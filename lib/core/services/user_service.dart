import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio centralizado para gestionar la identidad única de la instalación (userId).
/// Genera un UUID v4 criptográficamente seguro en el primer arranque y lo persiste
/// en SharedPreferences para garantizar que cada dispositivo tenga su propio userId.
class UserService {
  static const String _prefKey = 'app_user_id';
  static String? _cachedUserId;

  /// Inicializa el servicio en el arranque de la app.
  static Future<String> initialize() async {
    return getUserId();
  }

  /// Retorna el userId actual. Si no existe, genera un UUID v4, migra
  /// el progreso local existente (si lo hay) y lo persiste.
  static Future<String> getUserId() async {
    if (_cachedUserId != null) {
      return _cachedUserId!;
    }

    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString(_prefKey);

    if (storedId == null || storedId.trim().isEmpty) {
      storedId = generateUuidV4();
      await prefs.setString(_prefKey, storedId);

      // Si existe progreso local previo asociado al usuario 'user_1' (legacy),
      // migrarlo al nuevo UUID sin borrar nada.
      final legacyBosses = prefs.getStringList('completed_bosses_user_1');
      if (legacyBosses != null && legacyBosses.isNotEmpty) {
        final existingForNew = prefs.getStringList('completed_bosses_$storedId');
        if (existingForNew == null || existingForNew.isEmpty) {
          await prefs.setStringList('completed_bosses_$storedId', legacyBosses);
        }
      }
    }

    _cachedUserId = storedId;
    return storedId;
  }

  /// Acceso síncrono al userId en memoria.
  static String get currentUserId => _cachedUserId ?? 'user_1';

  /// Genera un UUID versión 4 (RFC 4122) utilizando Random.secure().
  static String generateUuidV4() {
    final Random rnd = Random.secure();
    final List<int> bytes = List<int>.generate(16, (_) => rnd.nextInt(256));

    // Versión 4: bits 12-15 del time_hi_and_version a 0100
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    // Variante RFC 4122: bits 6-7 del clock_seq_hi_and_reserved a 10
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// Permite sobrescribir el userId en pruebas unitarias.
  static void setMockUserId(String? id) {
    _cachedUserId = id;
  }
}
