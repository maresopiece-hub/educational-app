import 'package:flutter_test/flutter_test.dart';
import 'package:educational_app/services/database_service.dart';

void main() {
  group('DatabaseService', () {
    test('insert and get user', () async {
      final db = DatabaseService.instance;
      final user = {
        'id': 'testuser',
        'email': 'test@example.com',
        'name': 'Test User',
        'plans': '',
        'progress': '',
      };
      await db.insertUser(user);
      final fetched = await db.getUser('testuser');
      expect(fetched, isNotNull);
      expect(fetched!['email'], 'test@example.com');
    });
  });
}
