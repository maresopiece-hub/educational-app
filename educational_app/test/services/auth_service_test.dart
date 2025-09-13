import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

class MockFirebaseAuth extends Mock implements fb.FirebaseAuth {}
class MockUser extends Mock implements fb.User {}
class MockUserCredential extends Mock implements fb.UserCredential {}
class MockFirestore extends Mock implements FirebaseFirestore {}

void main() {
  test('dummy test passes', () {
    expect(1 + 1, equals(2));
  });
}
