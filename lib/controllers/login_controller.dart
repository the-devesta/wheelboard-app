import 'package:get/get.dart';
import 'dart:convert';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../utils/app_logger.dart';
import '../widgets/custom_snackbar.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;

  /// 👁️ Password visibility toggle
  var obscurePassword = true.obs;

  /// Login API
  Future<Map<String, dynamic>?> login(String phone, String password) async {
    // ✅ Validate inputs before making API call
    if (phone.trim().isEmpty) {
      AppLogger.e('Login failed: Phone number is empty');
      return null;
    }

    if (password.trim().isEmpty) {
      AppLogger.e('Login failed: Password is empty');
      return null;
    }

    isLoading.value = true;

    try {
      final requestData = {
        "mobileNo": phone.trim(),
        "password": password.trim(),
      };

      // Log API Request
      AppLogger.apiRequest(
        endpoint: API.login,
        method: 'POST',
        data: {
          "mobileNo": phone.trim(),
          "password": '*' * password.length, // Hide password in logs
        },
      );

      final response = await HttpHelper.postData(
        endpoint: API.login,
        data: requestData,
      );

      // Log API Response
      AppLogger.apiResponse(
        endpoint: API.login,
        statusCode: response.statusCode,
        body: response.body,
        isError: response.statusCode != 200,
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          AppLogger.i('Login successful, data received');

          // ✅ Check for success field and data object
          final isSuccess = data['success'] == true;

          if (isSuccess && data.containsKey('data') && data['data'] != null) {
            final responseData = data['data'] as Map<String, dynamic>;

            // ✅ Validate required fields
            if (responseData.containsKey('token') &&
                responseData.containsKey('userId') &&
                responseData['token'] != null &&
                responseData['userId'] != null) {
              AppLogger.auth('Login data extracted successfully');
              return responseData; // Return the data object
            } else {
              AppLogger.e('Login failed: Missing token or userId in response');
              return null;
            }
          } else if (!isSuccess) {
            AppLogger.e('Login failed: success field is false');
            return null;
          } else {
            AppLogger.e('Login failed: No data in response');
            return null;
          }
        } catch (e) {
          AppLogger.e('Login failed: Error parsing response', error: e);
          return null;
        }
      } else {
        AppLogger.e('Login failed with status: ${response.statusCode}');

        // Use ErrorHandler to parse and display user-friendly error
        final errorMessage = ErrorHandler.parseError(
          response.body,
          statusCode: response.statusCode,
        );
        SnackBarHelper.error(errorMessage);
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.e('LOGIN EXCEPTION', error: e, stackTrace: stackTrace);

      // Use ErrorHandler for network errors
      final errorMessage = ErrorHandler.handleNetworkError(e);
      SnackBarHelper.error(errorMessage);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 👁️ Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
}
