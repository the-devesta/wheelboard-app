import 'package:logger/logger.dart';

/// 🎨 ANSI Color Codes for Console Output
class _AnsiColors {
  static const String reset = '\x1B[0m';
  static const String white = '\x1B[37m';
  static const String gray = '\x1B[90m';

  // Bold variants
  static const String redBold = '\x1B[1;31m';
  static const String greenBold = '\x1B[1;32m';
  static const String yellowBold = '\x1B[1;33m';
  static const String blueBold = '\x1B[1;34m';
}

/// 🎨 Custom Color Printer for Logger
class _ColoredPrinter extends LogPrinter {
  final PrettyPrinter _prettyPrinter = PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  );

  @override
  List<String> log(LogEvent event) {
    final color = _getColorForLevel(event.level);
    final lines = _prettyPrinter.log(event);

    // Color the entire output
    return lines.map((line) => '$color$line${_AnsiColors.reset}').toList();
  }

  String _getColorForLevel(Level level) {
    switch (level) {
      case Level.trace:
        return _AnsiColors.gray;
      case Level.debug:
        return _AnsiColors.greenBold; // Green for debug - easy to track
      case Level.info:
        return _AnsiColors.blueBold; // Blue for info
      case Level.warning:
        return _AnsiColors.yellowBold; // Yellow for warning
      case Level.error:
        return _AnsiColors.redBold; // Red for error
      case Level.fatal:
        return _AnsiColors.redBold;
      default:
        return _AnsiColors.white;
    }
  }
}

/// 🎨 Centralized Logger for the entire app
///
/// Usage:
/// ```dart
/// AppLogger.d('Debug message');        // Green - Easy to track
/// AppLogger.i('Info message');         // Blue
/// AppLogger.w('Warning message');      // Yellow
/// AppLogger.e('Error message');        // Red
/// AppLogger.success('Success!');       // Green
/// ```
class AppLogger {
  static final Logger _logger = Logger(printer: _ColoredPrinter());

  /// 🐛 Debug - Green color - For detailed debugging information (easy to track)
  static void d(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// ℹ️ Info - Blue color - For general informational messages
  static void i(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// ⚠️ Warning - Yellow color - For warning messages
  static void w(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// ❌ Error - Red color - For error messages
  static void e(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// ✅ Success - Green color - For success messages
  static void success(dynamic message) {
    final greenMessage =
        '${_AnsiColors.greenBold}✅ SUCCESS: $message${_AnsiColors.reset}';
    _logger.i(greenMessage);
  }

  /// 💀 Fatal - Red color - For fatal error messages
  static void f(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// 📝 Trace - Gray color - For very detailed tracing
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
