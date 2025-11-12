import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetProvider extends ChangeNotifier {
  static const _key = 'monthly_budget';
  double _budgetLimit = 0.0;

  double get budgetLimit => _budgetLimit;

  Future<void> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    _budgetLimit = prefs.getDouble(_key) ?? 0.0;
    notifyListeners(); // ✅ triggers UI
  }

  Future<void> setBudget(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, amount);
    _budgetLimit = amount;
    print("✅ Budget saved: $_budgetLimit");

    notifyListeners(); // ✅ important
  }

  bool get hasBudget => _budgetLimit > 0;
}
