import 'package:flutter/material.dart';
import '../models/category.dart';
import '../db/category_db.dart';

class CategoryProvider extends ChangeNotifier {
  final _db = CategoryDB.instance;
  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

  Future<void> loadCategories() async {
    _categories = await _db.getAllCategories();
    // If no categories exist (first run), add defaults
    if (_categories.isEmpty) {
      const defaults = [
        'Food',
        'Transport',
        'Shopping',
        'Bills',
        'Entertainment',
        'Health',
        'Other',
      ];
      for (var c in defaults) {
        await addCategory(c);
      }
      _categories = await _db.getAllCategories();
    }
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    final category = CategoryModel(name: name);
    await _db.insertCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _db.deleteCategory(id);
    await loadCategories();
  }
}
