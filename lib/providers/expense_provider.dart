import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Expense> _expenses = [];

  List<Expense> get expenses => List.unmodifiable(_expenses);

  double get totalAmount => _expenses.fold(0.0, (s, e) => s + e.amount);

  Future<void> loadExpenses() async {
    _expenses = await _db.getAllExpenses();
    notifyListeners();
  }

  Future<void> addExpense(Expense e) async {
    final id = await _db.insertExpense(e);
    e.id = id;
    _expenses.insert(0, e);
    notifyListeners();
  }

  Future<void> updateExpense(Expense e) async {
    await _db.updateExpense(e);
    final idx = _expenses.indexWhere((x) => x.id == e.id);
    if (idx != -1) {
      _expenses[idx] = e;
      notifyListeners();
    } else {
      await loadExpenses();
    }
  }

  Future<void> deleteExpense(int id) async {
    await _db.deleteExpense(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
