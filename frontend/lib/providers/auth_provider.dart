import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _role;
  String? _userName;

  String? get token => _token;
  String? get role => _role;
  String? get userName => _userName;
  bool get isLoggedIn => _token != null;

  void setUser(
      {required String token, required String role, required String name}) {
    _token = token;
    _role = role;
    _userName = name;
    notifyListeners();
  }

  void logout() {
    _token = null;
    _role = null;
    _userName = null;
    notifyListeners();
  }
}
