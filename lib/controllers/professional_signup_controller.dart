import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/professional_signupmodel.dart';
import '../apihelperclass/api_helper.dart';
import '../screens/auth/login.dart';
import '../utils/constants.dart';
import '../widgets/custom_snackbar.dart';

class ProfessionalController extends GetxController {
  var isLoading = false.obs;

  Future<void> registerProfessional(ProfessionalSignupmodel model) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final fields = model.toJsonFields();
      final files = <File>[];

      if (model.driverImage != null) {
        files.add(model.driverImage!);
      }

      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.professionalSignUp,
        fields: fields,
        files: files,
        fieldKey: "ProfileImage",
        headers: {'Accept': 'application/json'},
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarHelper.success("Registered successfully! Please login to continue.");
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.offAll(() => LoginScreen());
        return;
      }

      String errorMessage = "Registration failed";
      try {
        final body = json.decode(response.body);
        errorMessage = body['message'] ?? body['error'] ?? errorMessage;
      } catch (_) {
        if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      }

      SnackBarHelper.error(errorMessage);
    } catch (e) {
      SnackBarHelper.error("Something went wrong: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}
