/// Typed API exceptions matching the backend error shape.
///
/// Backend returns: `{ message: string | string[], statusCode: number, error?: string }`
/// Same as `ApiError` interface in `wheelboard-fe/src/lib/api.ts`.
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? error;
  final dynamic response;

  const ApiException({
    required this.message,
    required this.statusCode,
    this.error,
    this.response,
  });

  /// Convert a raw backend error body to a user-friendly message.
  /// Mirrors `toFriendlyErrorMessage()` in wheelboard-fe's `ApiClient`.
  static String toFriendlyMessage(dynamic body, int statusCode) {
    if (body is Map<String, dynamic>) {
      final rawMessage = body['message'];
      List<String> messages = [];
      if (rawMessage is List) {
        messages = rawMessage.whereType<String>().toList();
      } else if (rawMessage is String && rawMessage.isNotEmpty) {
        messages = [rawMessage];
      }

      // Check for common validation errors
      final normalized = messages.map((m) => m.toLowerCase()).toList();
      if (normalized.any(
        (m) => m.contains('email') && m.contains('must be an email'),
      )) {
        return 'Please fill details properly. Enter a valid email address.';
      }

      if (statusCode == 400 && messages.isNotEmpty) {
        return 'Please fill details properly. ${messages.join(' ')}';
      }

      if (messages.isNotEmpty) return messages.join(' ');
    }

    // Fallback by status code
    switch (statusCode) {
      case 400:
        return 'Please fill details properly and try again.';
      case 401:
        return 'Invalid credentials. Please try again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'This action conflicts with existing data.';
      case 422:
        return 'The provided data is invalid.';
      case >= 500:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thrown specifically for 401 responses to trigger logout.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Session expired. Please log in again.',
    super.statusCode = 401,
    super.error,
    super.response,
  });
}

/// Thrown for network/connectivity issues.
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Network error. Please check your internet connection.',
    super.statusCode = 0,
    super.error,
    super.response,
  });
}
