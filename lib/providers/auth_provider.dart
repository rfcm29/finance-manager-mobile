import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;
  final _storage = const FlutterSecureStorage();

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;

  Future<void> loadToken() async {
    final token = await _storage.read(key: 'token');
    final name = await _storage.read(key: 'name');
    final email = await _storage.read(key: 'email');
    if (token != null && name != null && email != null) {
      _user = User(token: token, name: name, email: email);
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _loading = true; notifyListeners();
    try {
      final res = await ApiService.dio.post('/auth/login',
          data: {'email': email, 'password': password});
      await _saveUser(User.fromJson(res.data));
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _loading = true; notifyListeners();
    try {
      final res = await ApiService.dio.post('/auth/register',
          data: {'name': name, 'email': email, 'password': password});
      await _saveUser(User.fromJson(res.data));
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _user = null;
    notifyListeners();
  }

  Future<void> _saveUser(User user) async {
    await _storage.write(key: 'token', value: user.token);
    await _storage.write(key: 'name', value: user.name);
    await _storage.write(key: 'email', value: user.email);
    _user = user;
  }
}
