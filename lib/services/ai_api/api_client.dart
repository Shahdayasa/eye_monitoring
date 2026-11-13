import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/logging/app_logger.dart';
import '../../models/prediction.dart';
import 'api_endpoints.dart';

class AiApiClient {
  AiApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  static const Duration _timeout = AppConfig.apiTimeout;

  Future<Map<String, dynamic>> getHealth() async {
    final res = await _get(AiApiEndpoints.health, authToken: null);
    return res;
  }

  Future<PredictionResult> predictFromWindow({
    required List<double> samples,
    required int sampleRateHz,
    required DateTime windowStart,
    required double windowDurationSeconds,
    String channel = 'vertical_eog',
    String unit = 'adc_normalized',
    String? deviceId,
    double? ambientLightLux,
    String? authToken,
  }) async {
    final body = <String, dynamic>{
      'sample_rate_hz': sampleRateHz,
      'samples': samples,
      'channel': channel,
      'unit': unit,
      'window_start': windowStart.toUtc().toIso8601String(),
      'window_duration_seconds': windowDurationSeconds,
      if (deviceId != null) 'device_id': deviceId,
      if (ambientLightLux != null) 'ambient_light_lux': ambientLightLux,
    };

    final json = await _post(
      AiApiEndpoints.predict,
      body,
      authToken: authToken,
    );
    return PredictionResult.fromApiJson(
      json,
      windowStart: windowStart,
      windowDurationSeconds: windowDurationSeconds,
    );
  }

  Future<Map<String, dynamic>> _get(Uri uri, {String? authToken}) async {
    return _withRetry(() async {
      try {
        final res = await _http
            .get(uri, headers: _headers(authToken))
            .timeout(_timeout);
        return _decodeResponse(res);
      } on TimeoutException {
        throw const PredictionApiException('Request timed out. Check your connection and try again.', code: 'timeout');
      } on SocketException catch (e) {
        throw PredictionApiException('Network unavailable: ${e.message}', code: 'network');
      } on http.ClientException catch (e) {
        throw PredictionApiException('Network error: ${e.message}', code: 'network');
      }
    }, tag: 'API_GET');
  }

  Future<Map<String, dynamic>> _post(
    Uri uri,
    Map<String, dynamic> body, {
    String? authToken,
  }) async {
    return _withRetry(() async {
      try {
        final res = await _http
            .post(uri, headers: _headers(authToken), body: jsonEncode(body))
            .timeout(_timeout);
        return _decodeResponse(res);
      } on TimeoutException {
        throw const PredictionApiException('Request timed out. Check your connection and try again.', code: 'timeout');
      } on SocketException catch (e) {
        throw PredictionApiException('Network unavailable: ${e.message}', code: 'network');
      } on http.ClientException catch (e) {
        throw PredictionApiException('Network error: ${e.message}', code: 'network');
      }
    }, tag: 'API_POST');
  }

  Future<T> _withRetry<T>(Future<T> Function() op, {required String tag}) async {
    Object? lastError;
    var delay = AppConfig.networkRetryInitialDelay;
    for (var i = 0; i < AppConfig.networkRetryMaxAttempts; i++) {
      try {
        return await op();
      } catch (e) {
        lastError = e;
        final retryable = e is PredictionApiException && (e.isTimeout || e.isNetwork);
        AppLogger.error('API attempt ${i + 1} failed', tag: tag, error: e);
        if (!retryable || i == AppConfig.networkRetryMaxAttempts - 1) rethrow;
        await Future<void>.delayed(delay);
        delay *= 2;
      }
    }
    // ignore: only_throw_errors
    throw lastError!;
  }

  Map<String, String> _headers(String? authToken) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  Map<String, dynamic> _decodeResponse(http.Response res) {
    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      } else if (decoded is Map) {
        data = decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {
      data = null;
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data ?? <String, dynamic>{};
    }

    final detail = data?['detail']?.toString() ?? res.body;
    final code = data?['code']?.toString();
    final msg = detail.isNotEmpty ? detail : 'API error (${res.statusCode})';
    AppLogger.warning('API error response', tag: 'API', data: {'status': res.statusCode, 'code': code, 'detail': msg});
    throw PredictionApiException(msg, statusCode: res.statusCode, code: code);
  }

  void dispose() {
    _http.close();
  }
}
