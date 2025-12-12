import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/professional_signupmodel.dart';
import '../apihelperclass/api_helper.dart';
import '../screens/auth/login.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
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
        SnackBarHelper.success(
          "Registered successfully! Please login to continue.",
        );
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.offAll(() => LoginScreen());
        return;
      }

      // Use ErrorHandler to parse and display user-friendly error message
      final errorMessage = ErrorHandler.parseError(
        response.body,
        statusCode: response.statusCode,
      );

      SnackBarHelper.error(errorMessage);
    } catch (e) {
      // Use ErrorHandler for network/connection errors
      final errorMessage = ErrorHandler.handleNetworkError(e);
      SnackBarHelper.error(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }
}
