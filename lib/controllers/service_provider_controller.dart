import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/service_provider_signup.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../utils/navigation_helper.dart';
import '../widgets/custom_snackbar.dart';

class ServiceProviderController extends GetxController {
  var isLoading = false.obs;

  Future<void> completeServiceProvider(ServiceProviderModel model) async {
    // ✅ Prevent multiple submissions
    if (isLoading.value) {
      print("⚠️ Already processing, ignoring duplicate request");
      return;
    }
    
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

      // ✅ Validate file exists before sending
      final List<File> validFiles = [];
      for (var file in files) {
        if (await file.exists()) {
          validFiles.add(file);
          print("✅ File exists: ${file.path}");
        } else {
          print("❌ File not found: ${file.path}");
        }
      }
      
      if (validFiles.isEmpty && files.isNotEmpty) {
        SnackBarHelper.error("Image file not found. Please select image again.");
        return;
      }

      // ✅ Complete service provider doesn't require token - userId-based authentication
      // Add Accept header to avoid 403 errors
      final Map<String, String> headers = {
        'Accept': '*/*',
      };

      // ✅ Call your helper
      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.completeServiceProvider,
        fields: fields,
        files: validFiles,
        fieldKey: "BusinessLogo", // API key for file upload
        headers: headers,
      );

      // Convert streamed response to normal Response
      final response = await http.Response.fromStream(streamedResponse);

      // ✅ Debug log the response
      print("==================================");
      print("📥 Complete Service Provider Response Received");
      print("👉 Status Code: ${response.statusCode}");
      print("👉 Body: ${response.body}");
      print("==================================");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response to check if there's an error message in body
        try {
          final responseData = json.decode(response.body);
          
          // Check if response contains error even with 200 status
          if (responseData.containsKey('error') || 
              (responseData.containsKey('message') && 
               responseData['message'].toString().toLowerCase().contains('denied'))) {
            // Error in response body even though status is 200
            String errorMsg = responseData['error'] ?? 
                             responseData['message'] ?? 
                             "Profile completion failed";
            SnackBarHelper.error(errorMsg);
            return;
          }
          
          // Success - show message
          SnackBarHelper.success("Profile completed successfully!");
          
          print("✅ Service Provider profile completed successfully");
          print("🔄 Navigating to main wrapper...");
          
          // Wait a bit for snackbar to be visible, then navigate to main wrapper
          await Future.delayed(const Duration(milliseconds: 2000));
          
          // Navigate to main wrapper (service provider dashboard)
          NavigationHelper.navigateToMainWrapper();
        } catch (e) {
          // If JSON parsing fails, assume success if status is 200
          SnackBarHelper.success("Profile completed successfully!");
          
          print("✅ Service Provider profile completed successfully (non-JSON response)");
          print("🔄 Navigating to main wrapper...");
          
          await Future.delayed(const Duration(milliseconds: 2000));
          
          // Navigate to main wrapper (service provider dashboard)
          NavigationHelper.navigateToMainWrapper();
        }
      } else if (response.statusCode == 403) {
        // Handle 403 Forbidden - Server is blocking the request
        String errorMessage = "Access Denied";
        
        // Check if response is HTML (server error page)
        if (response.body.contains('<!DOCTYPE html>') || 
            response.body.contains('Forbidden') ||
            response.body.contains('403')) {
          errorMessage = "Server access denied. Please try again.";
        } else {
          // Try to parse JSON error
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['error'] ?? 
                          errorData['message'] ?? 
                          "Access denied. Please try again.";
          } catch (e) {
            errorMessage = "Access denied. Please try again.";
          }
        }
        
        SnackBarHelper.error(errorMessage);
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
