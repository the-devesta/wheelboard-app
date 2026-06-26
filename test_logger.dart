// ignore_for_file: avoid_print
//
// Standalone dev demo that prints colored banners to show the logger output;
// raw `print` is intentional here and this file is never shipped in the app.
import 'package:wheelboard/utils/app_logger.dart';

/// 🎨 Test file to demonstrate colored logging
///
/// Run this to see all the different colored logs in action!
void main() {
  print('\n🎨 ========== TESTING COLORED LOGGER ========== 🎨\n');

  // 🐛 Debug - Green
  AppLogger.d('This is a DEBUG message - should be GREEN');

  // ℹ️ Info - Blue
  AppLogger.i('This is an INFO message - should be BLUE');

  // ⚠️ Warning - Yellow
  AppLogger.w('This is a WARNING message - should be YELLOW');

  // ❌ Error - Red
  AppLogger.e('This is an ERROR message - should be RED');

  // ✅ Success - Green
  AppLogger.success('This is a SUCCESS message - should be GREEN');

  // 📝 Trace - Gray
  AppLogger.t('This is a TRACE message - should be GRAY');

  // 💀 Fatal - Red
  AppLogger.f('This is a FATAL message - should be RED');

  print('\n🎨 ========== TESTING SPECIAL LOGGERS ========== 🎨\n');

  // API Request - Blue
  AppLogger.apiRequest(
    endpoint: '/api/login',
    method: 'POST',
    data: {'username': 'test', 'password': '****'},
  );

  // API Response Success - Blue
  AppLogger.apiResponse(
    endpoint: '/api/login',
    statusCode: 200,
    body: {'success': true, 'token': 'abc123'},
  );

  // API Response Error - Red
  AppLogger.apiResponse(
    endpoint: '/api/login',
    statusCode: 401,
    body: {'error': 'Unauthorized'},
    isError: true,
  );

  // Auth Success - Blue
  AppLogger.auth('User logged in successfully');

  // Auth Error - Red
  AppLogger.auth('Login failed', isError: true);

  // Navigation - Blue
  AppLogger.navigation('Navigated to Home Screen');

  // Storage Success - Blue
  AppLogger.storage('Data saved to local storage');

  // Storage Error - Red
  AppLogger.storage('Failed to save data', isError: true);

  print('\n✅ ========== ALL TESTS COMPLETE ========== ✅\n');
}
