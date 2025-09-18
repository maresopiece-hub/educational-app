import 'package:flutter_test/flutter_test.dart';

// Lightweight fake AuthService for unit tests
class FakeAuthService {
  String? _email;

  String? get currentUserEmail => _email;

  Future<void> signIn(String email, String password) async {
    if (password.isEmpty) throw Exception('wrong-password');
    _email = email;
  }

  Future<void> createUser(String email, String password) async {
    if (password.length < 6) throw Exception('weak-password');
    _email = email;
  }

  Future<void> signOut() async {
    _email = null;
  }
}

void main() {
  test('FakeAuthService can sign up and sign in', () async {
    final auth = FakeAuthService();
    await auth.createUser('test@example.com', 'hunter2');
    expect(auth.currentUserEmail, 'test@example.com');

    await auth.signOut();
    expect(auth.currentUserEmail, isNull);

    await auth.signIn('test@example.com', 'hunter2');
    expect(auth.currentUserEmail, 'test@example.com');
  });

  test('signIn throws on empty password', () async {
    final auth = FakeAuthService();
    expect(() => auth.signIn('a@b.com', ''), throwsA(isA<Exception>()));
  });
}
