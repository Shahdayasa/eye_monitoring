import 'package:eye_monitoring/features/settings/data/user_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads defaults and persists values', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await UserPreferences.load();

    expect(prefs.notificationsEnabled, true);
    expect(prefs.darkModeEnabled, false);
    expect(prefs.highContrastCharts, false);

    await prefs.setNotificationsEnabled(false);
    await prefs.setDarkModeEnabled(true);
    await prefs.setHighContrastCharts(true);

    final reloaded = await UserPreferences.load();
    expect(reloaded.notificationsEnabled, false);
    expect(reloaded.darkModeEnabled, true);
    expect(reloaded.highContrastCharts, true);
  });
}
