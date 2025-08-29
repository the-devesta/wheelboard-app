// import 'package:get/get.dart';

// class SignupController extends GetxController {
//   var obscurePassword = true.obs;
// }

import 'package:get/get.dart';
import '../models/company_signupmodel.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';

class SignupController extends GetxController {
  var isLoading = false.obs;
  var obscurePassword = true.obs;

  Future<void> registerCompany(CompanySignUpModel model) async {
    isLoading.value = true; // Start the loader
    try {
      final response = await HttpHelper.postData(
        endpoint: API.companySignUp,
        data: model.toJson(),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Company registered successfully');
        // You can parse response if needed
      } else {
        Get.snackbar('Failed', 'Registration failed: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false; // Stop the loader
    }
  }

  // Future<void> registerCompany(CompanySignUpModel model) async {
  //   isLoading.value = true;
  //   try {
  //     final response = await HttpHelper.postData(
  //       endpoint: API.companySignUp,
  //       data: model.toJson(),
  //     );

  //     if (response.statusCode == 200) {
  //       Get.snackbar('Success', 'Company registered successfully');
  //       // You can parse response if needed
  //     } else {
  //       Get.snackbar('Failed', 'Registration failed: ${response.body}');
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', e.toString());
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
}
