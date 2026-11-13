import '../../core/config/app_config.dart';

class AiApiEndpoints {
  AiApiEndpoints._();

  static String get baseUrl => AppConfig.aiApiBaseUrl;

  static Uri get health => Uri.parse('$baseUrl/health');
  static Uri get model => Uri.parse('$baseUrl/v1/model');
  static Uri get predict => Uri.parse('$baseUrl/v1/predict');
}
