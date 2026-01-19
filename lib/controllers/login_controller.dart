import 'package:get/get.dart';
import 'dart:convert';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../utils/app_logger.dart';
import '../widgets/custom_snackbar.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  var isOTPSent = false.obs;

  /// 👁️ Password visibility toggle
  var obscurePassword = true.obs;

  String _formatPhone(String phone) {
    String p = phone.trim();
    if (p.length == 10 && !p.startsWith('+')) {
      return "+91$p";
    }
    return p;
  }

  void resetOTP() {
    isOTPSent.value = false;
  }

  /// Send OTP API
  Future<bool> sendOTP(String phone) async {
    final formattedPhone = _formatPhone(phone);
    if (formattedPhone.isEmpty) {
      SnackBarHelper.error('Please enter phone number');
      return false;
    }

    isLoading.value = true;
    try {
      final requestData = {"mobileNo": formattedPhone};

      AppLogger.apiRequest(
        endpoint: API.sendOtp,
        method: 'POST',
        data: requestData,
      );

      final response = await HttpHelper.postData(
        endpoint: API.sendOtp,
        data: requestData,
      );

      AppLogger.apiResponse(
        endpoint: API.sendOtp,
        statusCode: response.statusCode,
        body: response.body,
        isError: response.statusCode != 200,
      );

      if (response.statusCode == 200) {
        isOTPSent.value = true;
        SnackBarHelper.success("OTP sent successfully");
        return true;
      } else {
        final errorMessage = ErrorHandler.parseError(
          response.body,
          statusCode: response.statusCode,
        );
        SnackBarHelper.error(errorMessage);
        return false;
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleNetworkError(e);
      SnackBarHelper.error(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Login with OTP API
  Future<Map<String, dynamic>?> loginWithOTP(String phone, String otp) async {
    final formattedPhone = _formatPhone(phone);
    if (formattedPhone.isEmpty) {
      SnackBarHelper.error('Please enter phone number');
      return null;
    }
    if (otp.trim().isEmpty) {
      SnackBarHelper.error('Please enter OTP');
      return null;
    }

    isLoading.value = true;
    try {
      final requestData = {"mobileNo": formattedPhone, "otp": otp.trim()};

      AppLogger.apiRequest(
        endpoint: API.loginWithOtp,
        method: 'POST',
        data: requestData,
      );

      final response = await HttpHelper.postData(
        endpoint: API.loginWithOtp,
        data: requestData,
      );

      AppLogger.apiResponse(
        endpoint: API.loginWithOtp,
        statusCode: response.statusCode,
        body: response.body,
        isError: response.statusCode != 200,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isSuccess = data['success'] == true;

        if (isSuccess && data.containsKey('data') && data['data'] != null) {
          final responseData = data['data'] as Map<String, dynamic>;
          if (responseData.containsKey('token') &&
              responseData.containsKey('userId')) {
            return responseData;
          } else {
            SnackBarHelper.error('Missing token or userId in response');
            return null;
          }
        } else {
          SnackBarHelper.error(data['message'] ?? 'Login failed');
          return null;
        }
      } else {
        final errorMessage = ErrorHandler.parseError(
          response.body,
          statusCode: response.statusCode,
        );
        SnackBarHelper.error(errorMessage);
        return null;
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleNetworkError(e);
      SnackBarHelper.error(errorMessage);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Login API (Existing)
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
