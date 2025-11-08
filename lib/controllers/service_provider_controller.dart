import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/service_provider_signup.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../widgets/custom_snackbar.dart';

class ServiceProviderController extends GetxController {
  var isLoading = false.obs;

  Future<void> completeServiceProvider(ServiceProviderModel model) async {
    try {
      isLoading.value = true;

      // ✅ Collect fields from model
      final fields = model.toJsonFields();

      // ✅ Collect files (optional)
      final List<File> files = [];
      if (model.getBusinessLogo() != null) {
        files.add(model.getBusinessLogo()!);
      }

      // ✅ Debug log what you are sending
      print("==================================");
      print("📡 Sending Multipart Request");
      print("👉 Endpoint: ${API.completeServiceProvider}");
      print("👉 Headers: {Authorization: Bearer YOUR_TOKEN}");
      print("👉 Fields: $fields");
      print("👉 Files: ${files.map((f) => f.path).toList()}");
      print("==================================");

      // ✅ Call your helper
      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.completeServiceProvider, // Adjust endpoint
        fields: fields,
        files: files,
        fieldKey: "BusinessLogo", // API key for file upload
        headers: {}, // Add headers if required
      );

      // Convert streamed response to normal Response
      final response = await http.Response.fromStream(streamedResponse);

      // ✅ Debug log the response
      // print("==================================");
      // print("📥 Response Received");
      // print("👉 Status Code: ${response.statusCode}");
      // print("👉 Body: ${response.body}");
      // print("==================================");

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarHelper.success("Service provider completed successfully!");
        // Navigate back or to next screen if needed
        Get.back();
      } else if (response.statusCode == 400) {
        // Handle validation errors
        String errorMessage = "Registration failed";
        try {
          final errorData = json.decode(response.body);
          
          if (errorData.containsKey('errors') && errorData['errors'] is Map) {
            final errors = errorData['errors'] as Map<String, dynamic>;
            final errorMessages = <String>[];
            
            errors.forEach((field, messages) {
              if (messages is List) {
                for (var msg in messages) {
                  errorMessages.add("$field: $msg");
                }
              } else {
                errorMessages.add("$field: $messages");
              }
            });
            
            errorMessage = errorMessages.join('\n');
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'].toString();
          } else if (errorData.containsKey('message')) {
            errorMessage = errorData['message'].toString();
          }
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body.length > 100 
                          ? "${response.body.substring(0, 100)}..." 
                          : response.body;
          }
        }
        
        SnackBarHelper.error(errorMessage);
      } else {
        String errorMessage = "Registration failed";
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['error'] ?? 
                        errorData['message'] ?? 
                        "Failed with status: ${response.statusCode}";
        } catch (e) {
          errorMessage = "Failed with status: ${response.statusCode}";
        }
        SnackBarHelper.error(errorMessage);
      }
    } catch (e, s) {
      // ✅ Log the error with stacktrace
      print("❌ Exception occurred: $e");
      print(s);
      SnackBarHelper.error("Something went wrong: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}
