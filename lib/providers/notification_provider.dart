import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  static const _key = 'daily_reminder_enabled';
  bool _isEnabled = false;

  bool get isEnabled => _isEnabled;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_key) ?? false;

    if (_isEnabled) {
      await NotificationService.scheduleDailyReminder();
    }
    notifyListeners();
  }

  Future<void> toggleReminder(bool value) async {
    _isEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);

    if (value) {
      await NotificationService.scheduleDailyReminder();
    } else {
      await NotificationService.cancelAll();
    }

    notifyListeners();
  }
}
