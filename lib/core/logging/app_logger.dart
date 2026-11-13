import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

/// Lightweight centralized logger for app and error diagnostics.
class AppLogger {
  AppLogger._();

  static void info(String message, {String tag = 'APP', Object? data}) {
    _log('INFO', tag, message, data: data);
  }

  static void warning(String message, {String tag = 'APP', Object? data}) {
    _log('WARN', tag, message, data: data);
  }

  static void error(
    String message, {
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('ERROR', tag, message, data: error);
    if (kDebugMode && stackTrace != null) {
      dev.log(
        stackTrace.toString(),
        name: tag,
        level: 1000,
      );
    }
  }

  static void _log(String level, String tag, String message, {Object? data}) {
    final suffix = data == null ? '' : ' | $data';
    final line = '[$level][$tag] $message$suffix';
    if (kDebugMode) {
      dev.log(line, name: tag);
      // ignore: avoid_print
      debugPrint(line);
    }
  }
}
