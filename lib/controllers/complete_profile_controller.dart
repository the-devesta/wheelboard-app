// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:country_picker/country_picker.dart';

// class CompleteProfileController extends GetxController {
//   var selectedDialCode = '+91'.obs; // Initial value
//   var selectedCountryCode = 'IN'.obs; // Optional
//   var profileImage = Rx<File?>(null); // holds picked image
//   final ImagePicker _picker = ImagePicker();

//   Future<void> pickImage(ImageSource source) async {
//     final XFile? pickedFile = await _picker.pickImage(
//       source: source,
//       imageQuality: 80,
//     );
//     if (pickedFile != null) {
//       profileImage.value = File(pickedFile.path);
//     }
//   }

//   void updateCountry(Country country) {
//     selectedDialCode.value = '+${country.phoneCode}';
//     selectedCountryCode.value = country.countryCode;
//   }
// }

import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import '../models/company_profilemodel.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../utils/session_manager.dart';
import 'package:http/http.dart' as http;

class CompleteProfileController extends GetxController {
  var selectedDialCode = '+91'.obs;
  var selectedCountryCode = 'IN'.obs;
  var profileImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();
  var isLoading = false.obs;

  /// Pick image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
    }
  }

  /// Update selected country
  void updateCountry(Country country) {
    selectedDialCode.value = '+${country.phoneCode}';
    selectedCountryCode.value = country.countryCode;
  }

  Future<bool> submitProfile(CompleteProfileModel model, String userId) async {
    isLoading.value = true;
    try {
      // ✅ Get auth token from session
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");
      
      if (token == null || token.isEmpty) {
        Get.snackbar("Error", "Please login again");
        return false;
      }

      // ✅ Prepare fields - ensure all required fields are present
      final fields = model.toJsonFields();
      
      // ✅ Debug log
      print("==================================");
      print("📡 Complete Transport Profile Request");
      print("👉 Endpoint: ${API.completeTransport}");
      print("👉 Fields: $fields");
      print("👉 UserId: $userId");
      print("👉 Has Logo: ${model.companyLogo != null}");
      print("==================================");

      // ✅ Prepare files
      final files = <File>[];
      if (model.companyLogo != null) {
        files.add(model.companyLogo!);
      }

      // ✅ Call multipart API
      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.completeTransport,
        fields: fields,
        files: files,
        fieldKey: "CompanyLogo",
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "*/*",
        },
      );

      // 🔍 Convert to a normal Response so you can read the body
      final response = await http.Response.fromStream(streamedResponse);

      print("==================================");
      print("📥 Response Received");
      print("👉 Status Code: ${response.statusCode}");
      print("👉 Body: ${response.body}");
      print("==================================");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          if (responseData['message'] != null || responseData['success'] == true) {
            print("✅ Profile completed successfully");
            return true;
          }
        } catch (e) {
          // If response is not JSON but status is 200, consider it success
          print("✅ Profile completed successfully (non-JSON response)");
          return true;
        }
      } else {
        // 🔍 Parse error message
        String errorMessage = "Failed to complete profile";
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? response.body;
        } catch (e) {
          errorMessage = response.body.isNotEmpty ? response.body : "Failed: ${response.statusCode}";
        }
        
        Get.snackbar("Error", errorMessage);
        return false;
      }
    } catch (e, stacktrace) {
      print("❌ Exception: $e");
      print("❌ StackTrace: $stacktrace");
      Get.snackbar("Error", "An error occurred: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
    
    return false;
  }
}
