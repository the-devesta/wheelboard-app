import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;

  Future<bool> login(String phone, String password) async {
    isLoading.value = true;

    try {
      final requestData = {"mobileNo": phone, "password": password};

      // 🔍 Print request params

      final response = await HttpHelper.postData(
        endpoint: API.login,
        data: requestData,
      );

      // 🔍 Print response status + body

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Get.snackbar("Success", "Login Successful");

        return true;
      } else {
        Get.snackbar("Error", "Invalid credentials");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
