import 'package:get/get.dart';
import 'dart:convert';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;

  /// 👁️ Password visibility toggle
  var obscurePassword = true.obs;

  /// Login API
  Future<Map<String, dynamic>?> login(String phone, String password) async {
    isLoading.value = true;

    try {
      final requestData = {"mobileNo": phone, "password": password};

      print("🔐 Login attempt for phone: $phone");
      
      final response = await HttpHelper.postData(
        endpoint: API.login,
        data: requestData,
      );

      print("🔐 Login response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("🔐 Login successful, data received: ${data.toString()}");

        // ✅ Don't show success snackbar here - let login screen handle it
        // SnackBarHelper.success("Login Successful");

        return data['data']; // Return the data object
      } else {
        print("🔐 Login failed with status: ${response.statusCode}");
        print("🔐 Response body: ${response.body}");
        // ✅ Don't show error snackbar here - let login screen handle it
        // SnackBarHelper.error("Invalid credentials");
        return null;
      }
    } catch (e) {
      print("🔐 Login error: $e");
      // ✅ Don't show error snackbar here - let login screen handle it
      // SnackBarHelper.error("Login failed: ${e.toString()}");
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
