import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const kNotifications = 'pref_notifications_enabled';
  static const kDarkMode = 'pref_dark_mode_enabled';
  static const kHighContrastCharts = 'pref_high_contrast_charts';

  final SharedPreferences _prefs;

  UserPreferences(this._prefs);

  static Future<UserPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return UserPreferences(prefs);
  }

  bool get notificationsEnabled => _prefs.getBool(kNotifications) ?? true;
  bool get darkModeEnabled => _prefs.getBool(kDarkMode) ?? false;
  bool get highContrastCharts => _prefs.getBool(kHighContrastCharts) ?? false;

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(kNotifications, value);
  }

  Future<void> setDarkModeEnabled(bool value) async {
    await _prefs.setBool(kDarkMode, value);
  }

  Future<void> setHighContrastCharts(bool value) async {
    await _prefs.setBool(kHighContrastCharts, value);
  }
}
