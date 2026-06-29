import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const _pushNotificationsKey = 'push_notifications_enabled';
  static const _darkModeKey = 'dark_mode_enabled';

  Future<bool> readPushNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pushNotificationsKey) ?? true;
  }

  Future<void> savePushNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushNotificationsKey, value);
  }

  Future<bool> readDarkModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> saveDarkModeEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }
}
