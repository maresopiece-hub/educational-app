import 'package:flutter/material.dart';

/// Minimal AuthState ChangeNotifier as a placeholder for real auth logic.
/// Replace with your project's authentication implementation.
class AuthState extends ChangeNotifier {
  String? _userId;

  String? get userId => _userId;

  bool get isSignedIn => _userId != null;

  void signIn(String userId) {
    _userId = userId;
    notifyListeners();
  }

  void signOut() {
    _userId = null;
    notifyListeners();
  }
}
