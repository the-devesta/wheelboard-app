import 'package:get/get.dart';
import 'dart:convert';
import '../models/company_signupmodel.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../utils/session_manager.dart';
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
      final response = await HttpHelper.postData(
        endpoint: API.companySignUp,
        data: model.toJson(),
      );

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
          print("✅ Token stored from registration: ${token.substring(0, 20)}...");
        } else {
          print("⚠️ No token in registration response - user will need to login");
        }

        // Don't show snackbar here - let the screen handle it
        // SnackBarHelper.success('Company registered successfully');
        return true; // ✅ Success
      } else {
        String errorMessage = "Registration failed";
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? 
                        errorData['message'] ?? 
                        response.body;
        } catch (e) {
          errorMessage = response.body.isNotEmpty 
                        ? response.body 
                        : "Registration failed";
        }
        SnackBarHelper.error(errorMessage);
        return false; // ❌ Failed
      }
    } catch (e) {
      SnackBarHelper.error("Registration failed: ${e.toString()}");
      return false; // ❌ Error
    } finally {
      isLoading.value = false; // Stop the loader
    }
  }
}
