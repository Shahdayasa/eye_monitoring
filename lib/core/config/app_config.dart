/// Compile-time application configuration.
///
/// Values can be overridden with `--dart-define` without changing code:
/// `flutter run --dart-define=AI_API_BASE_URL=https://example.com`
class AppConstants {
  static const String appName = 'EOG Eye Monitoring';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
}

enum AppEnvironment { development, staging, production }

class AppConfig {
  AppConfig._();

  static const String appName = AppConstants.appName;
  static const String appVersion = AppConstants.appVersion;

  static const String _envName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const AppEnvironment environment = _envName == 'production'
      ? AppEnvironment.production
      : _envName == 'staging'
          ? AppEnvironment.staging
          : AppEnvironment.development;

  static bool get isDevelopment => environment == AppEnvironment.development;
  static bool get isProduction => environment == AppEnvironment.production;

  /// Android emulators reach the host machine at 10.0.2.2.
  static const String aiApiBaseUrl = String.fromEnvironment(
    'AI_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const bool useMockBle = bool.fromEnvironment(
    'USE_MOCK_BLE',
    defaultValue: true,
  );

  static const int sampleRateHz = 128;
  static const double windowDurationSeconds = 10;
  static const double windowOverlap = 0.5;
  static const int windowSampleCount = sampleRateHz * 10;

  static const String usersCollection = 'users';
  static const String sessionsCollection = 'sessions';
  static const String predictionsCollection = 'predictions';

  static const int networkRetryMaxAttempts = 3;
  static const Duration networkRetryInitialDelay = Duration(milliseconds: 500);
  static const Duration apiTimeout = Duration(seconds: 20);

  static const Duration animationDuration = Duration(milliseconds: 400);
  static const Duration staggerDelay = Duration(milliseconds: 80);
  static const int maxStaggeredItems = 5;
}
