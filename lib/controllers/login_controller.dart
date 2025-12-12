import 'package:get/get.dart';
import 'dart:convert';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_snackbar.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;

  /// 👁️ Password visibility toggle
  var obscurePassword = true.obs;

  /// Login API
  Future<Map<String, dynamic>?> login(String phone, String password) async {
    // ✅ Validate inputs before making API call
    if (phone.trim().isEmpty) {
      print("❌ Login failed: Phone number is empty");
      return null;
    }

    if (password.trim().isEmpty) {
      print("❌ Login failed: Password is empty");
      return null;
    }

    isLoading.value = true;

    try {
      final requestData = {
        "mobileNo": phone.trim(),
        "password": password.trim(),
      };

      print("==================================");
      print("🔐 Login Request");
      print("👉 Phone: $phone");
      print("👉 Password: ${'*' * password.length}");
      print("👉 Endpoint: ${API.login}");
      print("==================================");

      final response = await HttpHelper.postData(
        endpoint: API.login,
        data: requestData,
      );

      print("==================================");
      print("🔐 Login Response");
      print("👉 Status Code: ${response.statusCode}");
      print("👉 Body: ${response.body}");
      print("==================================");

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print("🔐 Login successful, data received: ${data.toString()}");

          // ✅ Check for success field and data object
          final isSuccess = data['success'] == true;

          if (isSuccess && data.containsKey('data') && data['data'] != null) {
            final responseData = data['data'] as Map<String, dynamic>;

            // ✅ Validate required fields
            if (responseData.containsKey('token') &&
                responseData.containsKey('userId') &&
                responseData['token'] != null &&
                responseData['userId'] != null) {
              print("✅ Login data extracted successfully");
              return responseData; // Return the data object
            } else {
              print("❌ Login failed: Missing token or userId in response");
              return null;
            }
          } else if (!isSuccess) {
            print("❌ Login failed: success field is false");
            return null;
          } else {
            print("❌ Login failed: No data in response");
            return null;
          }
        } catch (e) {
          print("❌ Login failed: Error parsing response - $e");
          return null;
        }
      } else {
        print("❌ Login failed with status: ${response.statusCode}");
        print("❌ Response body: ${response.body}");

        // Use ErrorHandler to parse and display user-friendly error
        final errorMessage = ErrorHandler.parseError(
          response.body,
          statusCode: response.statusCode,
        );
        SnackBarHelper.error(errorMessage);
        return null;
      }
    } catch (e, stackTrace) {
      print("==================================");
      print("❌ LOGIN EXCEPTION");
      print("📋 Error: $e");
      print("📋 Stack Trace:");
      print(stackTrace);
      print("==================================");

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
