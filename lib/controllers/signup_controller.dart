import 'package:get/get.dart';
import 'dart:convert';
import '../models/company_signupmodel.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../screens/auth/login.dart';

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userId.value = data['userId'];

        Get.snackbar('Success', 'Company registered successfully');
        return true; // ✅ Success
      } else {
        Get.snackbar('Failed', 'Registration failed: ${response.body}');
        return false; // ❌ Failed
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false; // ❌ Error
    } finally {
      isLoading.value = false; // Stop the loader
    }
  }
}
