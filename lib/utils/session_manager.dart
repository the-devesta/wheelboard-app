import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _isLoggedInKey = "isLoggedIn";
  static const String _isProfileCompletedKey = "isProfileCompleted";

  /// Save a string (like token, userId, etc.)
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// Retrieve a string
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Save integer
  Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  /// Get integer
  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  /// Save boolean
  Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Get boolean
  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  /// Remove specific key
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Clear all stored data (like clearing UserDefaults)
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Save login state
  static Future<void> setLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Save profile completion state
  static Future<void> setProfileCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isProfileCompletedKey, value);
  }

  static Future<bool> isProfileCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isProfileCompletedKey) ?? false;
  }

  // Clear session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
