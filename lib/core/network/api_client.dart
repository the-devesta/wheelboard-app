import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../auth/auth_models.dart';
import '../storage/secure_session_manager.dart';
import '../../utils/app_logger.dart';

/// A centralized singleton network client built on top of [Dio].
/// Handles authentication injection, token refresh, and logging.
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._internal(String baseUrl, SecureSessionManager sessionManager) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth + token-refresh interceptor (replaces both old interceptors)
    _dio.interceptors.add(_AuthInterceptor(sessionManager, _dio));

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => AppLogger.d(obj.toString()),
        ),
      );
    }
  }

  /// Initialize the ApiClient. Call this once during app startup.
  static void init({
    required String baseUrl,
    required SecureSessionManager sessionManager,
  }) {
    _instance ??= ApiClient._internal(baseUrl, sessionManager);
  }

  /// Get the singleton instance.
  static ApiClient get instance {
    assert(_instance != null, 'ApiClient.init() must be called first');
    return _instance!;
  }

  /// Register a callback invoked when a 401 cannot be recovered via refresh.
  /// Typically used by [AuthService] to navigate back to the login screen.
  static set onUnauthenticated(void Function()? callback) {
    _AuthInterceptor.onUnauthenticated = callback;
  }

  // ── HTTP Methods ────────────────────────────────────────────────────────

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
    return response.data as T;
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.post<T>(
      path,
      queryParameters: queryParameters,
      data: data,
      options: options,
    );
    return response.data as T;
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.put<T>(
      path,
      queryParameters: queryParameters,
      data: data,
      options: options,
    );
    return response.data as T;
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.patch<T>(
      path,
      queryParameters: queryParameters,
      data: data,
      options: options,
    );
    return response.data as T;
  }

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.delete<T>(
      path,
      queryParameters: queryParameters,
      data: data,
      options: options,
    );
    return response.data as T;
  }

  Future<T> upload<T>(
    String path, {
    required FormData formData,
    String method = 'POST',
    void Function(int, int)? onSendProgress,
  }) async {
    final response = await _dio.request<T>(
      path,
      data: formData,
      // Use the FormData's own boundary. Setting a bare 'multipart/form-data'
      // (no boundary) made the server unable to parse the parts, so uploads
      // arrived empty and `/media` rejected them ("No media provided") — the
      // root cause of "Could not upload the photo".
      options: Options(
        method: method,
        contentType: 'multipart/form-data; boundary=${formData.boundary}',
      ),
      onSendProgress: onSendProgress,
    );
    return response.data as T;
  }

  Dio get dio => _dio;
}

// ── Auth + Refresh Interceptor ──────────────────────────────────────────────

/// Injects `Authorization: Bearer <token>` on every request.
/// On a 401 response, attempts one token refresh then retries.
/// If refresh also fails, clears storage and calls [onUnauthenticated].
class _AuthInterceptor extends Interceptor {
  final SecureSessionManager _sessionManager;
  final Dio _dio;
  bool _isRefreshing = false;

  /// Set this once at startup (e.g., in main.dart) to redirect to login on
  /// unrecoverable 401 errors.
  static void Function()? onUnauthenticated;

  _AuthInterceptor(this._sessionManager, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _sessionManager.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    AppLogger.e('ApiClient Error [$statusCode]: ${err.message}');
    AppLogger.e('Path: $path');
    if (err.response?.data != null) {
      AppLogger.e('Response: ${err.response?.data}');
    }

    // A 401 from an auth entry-point (login / register / OTP / forgot-password)
    // means bad credentials or invalid input — NOT an expired session. It must
    // propagate to the caller so the screen can show the real message ("Invalid
    // credentials"). Never refresh or force-logout for these: doing so wipes
    // state and fires `Get.offAllNamed('/login')`, which races the error
    // snackbar and crashes with "No Overlay widget found".
    final isAuthEntryPoint = path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/request-otp') ||
        path.contains('/auth/refresh-token') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/reset-password');

    // Attempt refresh once on 401 for authenticated endpoints only.
    if (statusCode == 401 && !isAuthEntryPoint && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _sessionManager.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await _forceLogout();
          return handler.reject(err);
        }

        final refreshResp = await _dio.post<Map<String, dynamic>>(
          '/auth/refresh-token',
          data: {'refreshToken': refreshToken},
          // Skip auth header for this request to avoid a loop
          options: Options(headers: {'Authorization': ''}),
        );

        final newAccess = refreshResp.data?['accessToken'] as String?;
        final newRefresh = refreshResp.data?['refreshToken'] as String?;

        if (newAccess == null || newAccess.isEmpty) {
          await _forceLogout();
          return handler.reject(err);
        }

        await _sessionManager.setTokens(
          AuthTokens(
            accessToken: newAccess,
            refreshToken: newRefresh ?? refreshToken,
          ),
        );

        // Retry the original request with the fresh token
        final retry = err.requestOptions;
        retry.headers['Authorization'] = 'Bearer $newAccess';
        final retryResp = await _dio.fetch(retry);
        return handler.resolve(retryResp);
      } catch (_) {
        await _forceLogout();
        return handler.reject(err);
      } finally {
        _isRefreshing = false;
      }
    }

    return handler.next(err);
  }

  Future<void> _forceLogout() async {
    await _sessionManager.clearAll();
    onUnauthenticated?.call();
  }
}
