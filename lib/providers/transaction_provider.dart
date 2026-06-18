import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _loading = false;

  List<Transaction> get transactions => _transactions;
  bool get loading => _loading;

  Future<void> fetchTransactions() async {
    _loading = true; notifyListeners();
    try {
      final res = await ApiService.dio.get('/transactions');
      _transactions = (res.data as List).map((j) => Transaction.fromJson(j)).toList();
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> createTransaction({
    required double amount, required String description,
    required String date, required String type, required int accountId,
  }) async {
    await ApiService.dio.post('/transactions', data: {
      'amount': amount, 'description': description,
      'date': date, 'type': type, 'accountId': accountId,
    });
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await ApiService.dio.delete('/transactions/$id');
    await fetchTransactions();
  }
}
