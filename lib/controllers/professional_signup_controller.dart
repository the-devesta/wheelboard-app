import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/professional_signupmodel.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';

class ProfessionalController extends GetxController {
  var isLoading = false.obs;

  Future<void> registerProfessional(ProfessionalSignupmodel model) async {
    try {
      isLoading.value = true;

      // ✅ Collect fields from model
      final fields = model.toJsonFields();

      // ✅ Collect files (optional)
      final List<File> files = [];
      if (model.driverImage != null) {
        files.add(model.driverImage!);
      }

      // ✅ Debug log what you are sending
      // print("==================================");
      // print("📡 Sending Multipart Request");
      // print("👉 Endpoint: ${API.professionalSignUp}");
      // print("👉 Headers: {Authorization: Bearer YOUR_TOKEN}");
      // print("👉 Fields: $fields");
      // print("👉 Files: ${files.map((f) => f.path).toList()}");
      // print("==================================");

      // ✅ Call your helper
      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.professionalSignUp, // adjust endpoint
        fields: fields,
        files: files,
        fieldKey: "ProfileImage", // API key for file upload
        headers: {},
      );

      // Convert streamed response to normal Response
      final response = await http.Response.fromStream(streamedResponse);

      // ✅ Debug log the response
      // print("==================================");
      // print("📥 Response Received");
      // print("👉 Status Code: ${response.statusCode}");
      // print("👉 Body: ${response.body}");
      // print("==================================");

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Registered successfully ✅");
      } else {
        Get.snackbar(
          "Error",
          "Failed with status: ${response.statusCode} \n${response.body}",
        );
      }
    } catch (e, s) {
      // ✅ Log the error with stacktrace
      print("❌ Exception occurred: $e");
      print(s);
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
