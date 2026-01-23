import 'dart:convert';

/// 🔹 Centralized Error Handler
/// Converts technical API errors into user-friendly messages
class ErrorHandler {
  /// Parse error from HTTP response body and return user-friendly message
  static String parseError(dynamic responseBody, {int? statusCode}) {
    try {
      // If responseBody is already a string
      if (responseBody is String) {
        // Try to parse as JSON
        try {
          final Map<String, dynamic> errorData = json.decode(responseBody);
          return _extractMessageFromJson(errorData, statusCode: statusCode);
        } catch (_) {
          // Not JSON, treat as plain text error
          return _parseRawError(responseBody, statusCode: statusCode);
        }
      }

      // If responseBody is already a Map
      if (responseBody is Map<String, dynamic>) {
        return _extractMessageFromJson(responseBody, statusCode: statusCode);
      }

      // Fallback to default error message
      return _getDefaultErrorMessage(statusCode);
    } catch (e) {
      return _getDefaultErrorMessage(statusCode);
    }
  }

  /// Extract user-friendly message from JSON error response
  static String _extractMessageFromJson(
    Map<String, dynamic> errorData, {
    int? statusCode,
  }) {
    // Check common error fields
    if (errorData.containsKey('message') && errorData['message'] != null) {
      return _formatMessage(errorData['message'].toString());
    }

    if (errorData.containsKey('error') && errorData['error'] != null) {
      final error = errorData['error'];

      // Handle error as string
      if (error is String) {
        return _formatMessage(error);
      }

      // Handle error as object with nested message
      if (error is Map<String, dynamic>) {
        if (error.containsKey('message')) {
          return _formatMessage(error['message'].toString());
        }
      }

      return _formatMessage(error.toString());
    }

    // Check for validation errors
    if (errorData.containsKey('errors') && errorData['errors'] != null) {
      final errors = errorData['errors'];

      // Handle errors as a List
      if (errors is List && errors.isNotEmpty) {
        return _formatMessage(errors.first.toString());
      }

      // Handle errors as a Map (e.g., {"FieldName": ["Error message"]})
      if (errors is Map && errors.isNotEmpty) {
        final firstKey = errors.keys.first;
        final firstError = errors[firstKey];
        if (firstError is List && firstError.isNotEmpty) {
          return _formatMessage(firstError.first.toString());
        }
        return _formatMessage(firstError.toString());
      }
    }

    // Check for title field (often used in error responses)
    if (errorData.containsKey('title') && errorData['title'] != null) {
      return _formatMessage(errorData['title'].toString());
    }

    return _getDefaultErrorMessage(statusCode);
  }

  /// Parse raw error text and convert to user-friendly message
  static String _parseRawError(String rawError, {int? statusCode}) {
    // Remove common technical patterns
    String cleanedError = rawError
        .replaceAll(RegExp(r'\{[^}]*\}'), '') // Remove JSON-like patterns
        .replaceAll(RegExp(r'^\{|\}$'), '') // Remove surrounding braces
        .replaceAll(RegExp(r'"error"\s*:\s*'), '') // Remove "error": prefix
        .replaceAll(RegExp(r'"message"\s*:\s*'), '') // Remove "message": prefix
        .replaceAll(RegExp(r'"'), '') // Remove quotes
        .trim();

    // Check for common error patterns and make them user-friendly
    if (cleanedError.toLowerCase().contains('phone number already exists') ||
        cleanedError.toLowerCase().contains('mobile') &&
            cleanedError.toLowerCase().contains('exists')) {
      return 'This phone number is already registered. Please use a different number or try logging in.';
    }

    if (cleanedError.toLowerCase().contains('email') &&
        cleanedError.toLowerCase().contains('exists')) {
      return 'This email is already registered. Please use a different email or try logging in.';
    }

    if (cleanedError.toLowerCase().contains('validation') ||
        cleanedError.toLowerCase().contains('required')) {
      return 'Please fill all required fields correctly.';
    }

    if (cleanedError.toLowerCase().contains('password')) {
      return 'Password is invalid. Please check and try again.';
    }

    if (cleanedError.toLowerCase().contains('not found')) {
      return 'Account not found. Please check your credentials.';
    }

    if (cleanedError.toLowerCase().contains('unauthorized')) {
      return 'Invalid credentials. Please check and try again.';
    }

    if (cleanedError.toLowerCase().contains('parameter') &&
        cleanedError.toLowerCase().contains('expects')) {
      return 'Some required information is missing. Please complete all fields.';
    }

    // If error is short and readable, return it
    if (cleanedError.length < 100 &&
        !cleanedError.contains('http') &&
        !cleanedError.contains('://')) {
      return _formatMessage(cleanedError);
    }

    return _getDefaultErrorMessage(statusCode);
  }

  /// Format message to be user-friendly (capitalize first letter, add period)
  static String _formatMessage(String message) {
    if (message.isEmpty) return _getDefaultErrorMessage(null);

    // Remove technical prefixes
    message = message
        .replaceAll(RegExp(r'^error:\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^message:\s*', caseSensitive: false), '')
        .trim();

    // Capitalize first letter
    if (message.isNotEmpty) {
      message = message[0].toUpperCase() + message.substring(1);
    }

    // Add period if not present
    if (message.isNotEmpty &&
        !message.endsWith('.') &&
        !message.endsWith('!') &&
        !message.endsWith('?')) {
      message += '.';
    }

    return message;
  }

  /// Get default error message based on status code
  static String _getDefaultErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'This action conflicts with existing data. Please try again.';
      case 422:
        return 'The provided data is invalid. Please check and try again.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Handle network errors
  static String handleNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socket') || errorString.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (errorString.contains('connection refused')) {
      return 'Cannot connect to server. Please try again later.';
    }

    return 'Connection error. Please check your internet and try again.';
  }
}
