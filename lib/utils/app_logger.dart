import 'package:logger/logger.dart';

/// 🎨 Centralized Logger for the entire app
///
/// Usage:
/// ```dart
/// AppLogger.d('Debug message');
/// AppLogger.i('Info message');
/// AppLogger.w('Warning message');
/// AppLogger.e('Error message', error: exception, stackTrace: stackTrace);
/// ```
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Time format
    ),
  );

  /// 🐛 Debug - For detailed debugging information
  static void d(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// ℹ️ Info - For general informational messages
  static void i(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// ⚠️ Warning - For warning messages
  static void w(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// ❌ Error - For error messages
  static void e(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 💀 Fatal - For fatal error messages
  static void f(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// 📝 Trace - For very detailed tracing
  static void t(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// 📊 Log API Request
  static void apiRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🌐 API REQUEST');
    buffer.writeln('Method: $method');
    buffer.writeln('Endpoint: $endpoint');
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('Headers: $headers');
    }
    if (data != null && data.isNotEmpty) {
      buffer.writeln('Data: $data');
    }
    _logger.i(buffer.toString());
  }

  /// 📊 Log API Response
  static void apiResponse({
    required String endpoint,
    required int statusCode,
    dynamic body,
    bool isError = false,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🌐 API RESPONSE');
    buffer.writeln('Endpoint: $endpoint');
    buffer.writeln('Status Code: $statusCode');
    buffer.writeln('Body: $body');

    if (isError) {
      _logger.e(buffer.toString());
    } else {
      _logger.i(buffer.toString());
    }
  }

  /// 🔐 Log Authentication Events
  static void auth(String message, {bool isError = false}) {
    final logMessage = '🔐 AUTH: $message';
    if (isError) {
      _logger.e(logMessage);
    } else {
      _logger.i(logMessage);
    }
  }

  /// 🗺️ Log Navigation Events
  static void navigation(String message) {
    _logger.i('🗺️ NAVIGATION: $message');
  }

  /// 💾 Log Storage Events
  static void storage(String message, {bool isError = false}) {
    final logMessage = '💾 STORAGE: $message';
    if (isError) {
      _logger.e(logMessage);
    } else {
      _logger.i(logMessage);
    }
  }
}
