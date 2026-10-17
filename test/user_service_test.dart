import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:java_play_app/core/services/user_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    UserService.setMockUserId(null);
  });

  group('UserService Tests', () {
    test('generateUuidV4 produces valid RFC 4122 v4 UUID format', () {
      final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');

      for (int i = 0; i < 50; i++) {
        final id = UserService.generateUuidV4();
        expect(uuidRegex.hasMatch(id), isTrue, reason: 'Generated ID $id must be a valid UUID v4');
      }
    });

    test('getUserId generates and persists UUID on first run', () async {
      SharedPreferences.setMockInitialValues({});

      final id1 = await UserService.getUserId();
      expect(id1, isNotEmpty);
      expect(UserService.currentUserId, equals(id1));

      // Reset in-memory cache to ensure it reads from SharedPreferences
      UserService.setMockUserId(null);
      final id2 = await UserService.getUserId();
      expect(id2, equals(id1), reason: 'Subsequent calls must retrieve the persisted UUID');
    });

    test('getUserId preserves and migrates legacy user_1 completed bosses', () async {
      SharedPreferences.setMockInitialValues({
        'completed_bosses_user_1': ['mundo_0', 'mundo_1'],
      });

      final newUserId = await UserService.getUserId();
      final prefs = await SharedPreferences.getInstance();

      // Legacy progress is preserved
      expect(prefs.getStringList('completed_bosses_user_1'), equals(['mundo_0', 'mundo_1']));
      // And migrated to the new userId
      expect(prefs.getStringList('completed_bosses_$newUserId'), equals(['mundo_0', 'mundo_1']));
    });
  });
}
