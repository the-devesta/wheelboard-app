import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;

  Future<Map<String, dynamic>?> login(String phone, String password) async {
    isLoading.value = true;

    try {
      final requestData = {"mobileNo": phone, "password": password};

      final response = await HttpHelper.postData(
        endpoint: API.login,
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Get.snackbar("Success", "Login Successful");

        return data['data']; // Return the data object
      } else {
        Get.snackbar("Error", "Invalid credentials");
        return null;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
