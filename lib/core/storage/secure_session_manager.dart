import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_models.dart';
import '../../utils/app_logger.dart';

/// Secure token and session storage.
///
/// Mirrors `tokenStorage` from `wheelboard-fe/src/lib/api.ts` but uses
/// [FlutterSecureStorage] for sensitive data (tokens) and
/// [SharedPreferences] only for non-sensitive flags.
///
/// On first launch after migration it reads legacy keys from
/// SharedPreferences and migrates them to secure storage.
class SecureSessionManager {
  static const _accessTokenKey = 'wb_access_token';
  static const _refreshTokenKey = 'wb_refresh_token';
  static const _userKey = 'wb_user';
  static const _fallbackPrefix = 'wb_storage_fallback_';

  // Legacy keys from old SessionManager (for migration)
  static const _legacyTokenKey = 'authToken';
  static const _legacyUserIdKey = 'userId';
  static const _legacyUserTypeKey = 'userType';
  static const _legacyMigratedKey = 'wb_session_migrated';

  final FlutterSecureStorage _secure;

  SecureSessionManager({FlutterSecureStorage? secure})
      : _secure = secure ??
            const FlutterSecureStorage(
              mOptions: MacOsOptions(
                usesDataProtectionKeychain: false,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  // ── Token Storage (mirrors tokenStorage in wheelboard-fe) ──────────────

  /// Store both tokens after login/register — same as `tokenStorage.setTokens()`.
  Future<void> setTokens(AuthTokens tokens) async {
    await _writeString(_accessTokenKey, tokens.accessToken);
    await _writeString(_refreshTokenKey, tokens.refreshToken);
  }

  /// Get the current access token — same as `tokenStorage.getAccessToken()`.
  Future<String?> getAccessToken() async {
    return _readString(_accessTokenKey);
  }

  /// Get the current refresh token — same as `tokenStorage.getRefreshToken()`.
  Future<String?> getRefreshToken() async {
    return _readString(_refreshTokenKey);
  }

  /// Get both tokens — same as `tokenStorage.getTokens()`.
  Future<AuthTokens?> getTokens() async {
    final access = await getAccessToken();
    final refresh = await getRefreshToken();
    if (access == null || access.isEmpty) return null;
    return AuthTokens(
      accessToken: access,
      refreshToken: refresh ?? '',
    );
  }

  // ── User Storage (mirrors tokenStorage.setUser/getUser) ────────────────

  /// Store the user object — same as `tokenStorage.setUser()`.
  Future<void> setUser(AppUser user) async {
    final jsonStr = jsonEncode(user.toJson());
    await _writeString(_userKey, jsonStr);
  }

  /// Get stored user — same as `tokenStorage.getUser()`.
  Future<AppUser?> getUser() async {
    final jsonStr = await _readString(_userKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AppUser.fromJson(map);
    } catch (e) {
      AppLogger.e('Failed to parse stored user', error: e);
      return null;
    }
  }

  // ── Clear (mirrors tokenStorage.clearAll) ──────────────────────────────

  /// Clear all auth data — same as `tokenStorage.clearAll()`.
  Future<void> clearAll() async {
    await _deleteString(_accessTokenKey);
    await _deleteString(_refreshTokenKey);
    await _deleteString(_userKey);
  }

  // ── Legacy Migration ───────────────────────────────────────────────────

  /// One-time migration from the old SharedPreferences-based SessionManager.
  /// After migrating, sets a flag so it doesn't run again.
  Future<void> migrateFromLegacy() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_legacyMigratedKey) == true) return;

    AppLogger.i('🔄 Migrating legacy session to secure storage…');

    final legacyToken = prefs.getString(_legacyTokenKey);
    if (legacyToken != null && legacyToken.isNotEmpty) {
      // Old app only had a single token; store it as accessToken.
      // There is no legacy refresh token.
      await _writeString(_accessTokenKey, legacyToken);
      AppLogger.i('✅ Legacy token migrated to secure storage');
    }

    // Remove old insecure keys
    await prefs.remove(_legacyTokenKey);
    await prefs.remove(_legacyUserIdKey);
    await prefs.remove(_legacyUserTypeKey);
    await prefs.remove('isKYCCompleted');
    await prefs.remove('isHired');
    await prefs.remove('isLoggedIn');
    await prefs.remove('isProfileCompleted');

    await prefs.setBool(_legacyMigratedKey, true);
    AppLogger.i('✅ Legacy session migration complete');
  }

  String _fallbackKey(String key) => '$_fallbackPrefix$key';

  Future<void> _writeString(String key, String value) async {
    try {
      await _secure.write(key: key, value: value);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_fallbackKey(key));
    } catch (e, stackTrace) {
      AppLogger.w(
        'Secure storage write failed; using SharedPreferences fallback for $key',
        error: e,
        stackTrace: stackTrace,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fallbackKey(key), value);
    }
  }

  Future<String?> _readString(String key) async {
    try {
      final value = await _secure.read(key: key);
      if (value != null && value.isNotEmpty) return value;
    } catch (e, stackTrace) {
      AppLogger.w(
        'Secure storage read failed; using SharedPreferences fallback for $key',
        error: e,
        stackTrace: stackTrace,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fallbackKey(key));
  }

  Future<void> _deleteString(String key) async {
    try {
      await _secure.delete(key: key);
    } catch (e, stackTrace) {
      AppLogger.w(
        'Secure storage delete failed for $key',
        error: e,
        stackTrace: stackTrace,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fallbackKey(key));
  }
}
