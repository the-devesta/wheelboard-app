import 'package:get/get.dart';
import 'dart:convert';
import '../models/company_signupmodel.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../utils/session_manager.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_snackbar.dart';

class SignupController extends GetxController {
  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var userId = RxnString();

  Future<bool> registerCompany(CompanySignUpModel model) async {
    if (isLoading.value) {
      print("⚠️ registerCompany called while a request is already in progress");
      SnackBarHelper.error("Registration already in progress. Please wait.");
      return false;
    }

    isLoading.value = true; // Start the loader

    try {
      // 🔍 DEBUG: Log what we're sending
      final requestData = model.toJson();
      print("=================================");
      print("📤 Signup Request Data:");
      print("📱 Mobile: ${requestData['mobileNo']}");
      print("🏢 Company: ${requestData['companyName']}");
      print("📧 Email: ${requestData['email']}");
      print("📂 Category: ${requestData['businessCategory']}");
      print("=================================");

      final response = await HttpHelper.postData(
        endpoint: API.companySignUp,
        data: requestData,
      );

      // 🔍 DEBUG: Log response
      print("=================================");
      print("📥 Signup Response:");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      print("=================================");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        userId.value = data['userId'];

        // ✅ Check if registration response includes token
        // Some APIs return token directly, others return it in 'data' object
        String? token;
        if (data['token'] != null) {
          token = data['token'].toString();
        } else if (data['data'] != null && data['data']['token'] != null) {
          token = data['data']['token'].toString();
        }

        // ✅ Store token if available
        if (token != null && token.isNotEmpty) {
          final sessionManager = SessionManager();
          await sessionManager.saveString("authToken", token);
          print(
            "✅ Token stored from registration: ${token.substring(0, 20)}...",
          );
        } else {
          print(
            "⚠️ No token in registration response - user will need to login",
          );
        }

        // Don't show snackbar here - let the screen handle it
        // SnackBarHelper.success('Company registered successfully');
        return true; // ✅ Success
      } else {
        // 🔍 Show exact backend error
        print("❌ Registration failed!");
        print("❌ Status Code: ${response.statusCode}");
        print("❌ Error Body: ${response.body}");

        final errorMessage = ErrorHandler.parseError(
          response.body,
          statusCode: response.statusCode,
        );

        // Also show the phone number that failed
        print("❌ Failed for mobile: ${requestData['mobileNo']}");

        SnackBarHelper.error(errorMessage);
        return false; // ❌ Failed
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleNetworkError(e);
      SnackBarHelper.error(errorMessage);
      return false; // ❌ Error
    } finally {
      isLoading.value = false; // Stop the loader
    }
  }
}
