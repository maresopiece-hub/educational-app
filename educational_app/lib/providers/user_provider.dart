import 'package:flutter/material.dart';
import '../models/user_model.dart';
// import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  AppUser? _user;
  bool loading = false;
  AppUser? get user => _user;
  set user(AppUser? u) {
    _user = u;
    notifyListeners();
  }
  // final AuthService _auth = AuthService();
  // You may need to implement a user stream in AuthService for this to work
  // void listenToAuth() {
  //   _auth.user.listen((u) {
  //     user = u;
  //   });
  // }
}
