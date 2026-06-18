import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/api_service.dart';

class AccountProvider extends ChangeNotifier {
  List<Account> _accounts = [];
  bool _loading = false;

  List<Account> get accounts => _accounts;
  bool get loading => _loading;
  double get totalBalance => _accounts.fold(0, (sum, a) => sum + a.balance);

  Future<void> fetchAccounts() async {
    _loading = true; notifyListeners();
    try {
      final res = await ApiService.dio.get('/accounts');
      _accounts = (res.data as List).map((j) => Account.fromJson(j)).toList();
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> createAccount(String name, String type, double initialBalance) async {
    await ApiService.dio.post('/accounts', data: {
      'name': name, 'type': type,
      'initialBalance': initialBalance, 'currency': 'USD',
    });
    await fetchAccounts();
  }

  Future<void> deleteAccount(int id) async {
    await ApiService.dio.delete('/accounts/$id');
    await fetchAccounts();
  }
}
