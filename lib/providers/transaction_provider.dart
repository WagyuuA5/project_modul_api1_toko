import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('transactions');
    if (data != null) {
      List<dynamic> decoded = json.decode(data);
      _transactions = decoded.map((item) => TransactionModel.fromJson(item)).toList();
      _transactions.sort((a, b) => b.date.compareTo(a.date)); 
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    _transactions.insert(0, transaction); 
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_transactions.map((t) => t.toJson()).toList());
    await prefs.setString('transactions', encoded);
  }

  Future<void> clearTransactions() async {
    _transactions.clear();
    await _saveTransactions();
    notifyListeners();
  }

  TransactionModel? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}