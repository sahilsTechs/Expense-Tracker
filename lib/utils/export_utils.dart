import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';

class ExportUtils {
  /// Export expenses to CSV file
  static Future<void> exportToCsv(List<Expense> expenses) async {
    try {
      final rows = [
        ['Title', 'Category', 'Amount', 'Date', 'Note'],
        ...expenses.map(
          (e) => [
            e.title,
            e.category,
            e.amount.toStringAsFixed(2),
            e.date.toIso8601String(),
            e.notes,
          ],
        ),
      ];

      String csvData = const ListToCsvConverter().convert(rows);

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/expenses_export.csv';
      final file = File(path);
      await file.writeAsString(csvData);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: '💰 My Expenses (CSV Export)');
    } catch (e) {
      debugPrint('Error exporting CSV: $e');
    }
  }

  /// Export expenses to JSON file
  static Future<void> exportToJson(List<Expense> expenses) async {
    try {
      final jsonList = expenses.map((e) => e.toMap()).toList();
      final jsonData = jsonEncode(jsonList);

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/expenses_export.json';
      final file = File(path);
      await file.writeAsString(jsonData);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: '💰 My Expenses (JSON Export)');
    } catch (e) {
      debugPrint('Error exporting JSON: $e');
    }
  }
}
