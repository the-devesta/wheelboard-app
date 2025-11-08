import 'package:get/get.dart';
import 'dart:convert';
import '../models/company_signupmodel.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../widgets/custom_snackbar.dart';

class SignupController extends GetxController {
  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var userId = RxnString();

  Future<bool> registerCompany(CompanySignUpModel model) async {
    isLoading.value = true; // Start the loader

    try {
      final response = await HttpHelper.postData(
        endpoint: API.companySignUp,
        data: model.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        userId.value = data['userId'];

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
