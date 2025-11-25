

import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/company_profilemodel.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../widgets/custom_snackbar.dart';
import 'package:http/http.dart' as http;

class CompleteProfileController extends GetxController {
  var selectedDialCode = '+91'.obs;
  var selectedCountryCode = 'IN'.obs;
  var profileImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();
  var isLoading = false.obs;

  /// Pick image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (pickedFile != null) {
        // Copy image to permanent location to avoid cache deletion issues
        try {
          final Directory appDocDir = await getApplicationDocumentsDirectory();
          final String fileName = 'company_logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final String permanentPath = '${appDocDir.path}/$fileName';
          
          // Copy the file to permanent location
          final File permanentFile = await File(pickedFile.path).copy(permanentPath);
          
          profileImage.value = permanentFile;
          SnackBarHelper.success("Image selected successfully");
        } catch (e) {
          print("Error copying image: $e");
          // Fallback to original path if copy fails
          profileImage.value = File(pickedFile.path);
          SnackBarHelper.success("Image selected successfully");
        }
      }
    } catch (e) {
      SnackBarHelper.error("Failed to pick image: ${e.toString()}");
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
      // ✅ Complete profile API works based on userId only - token not required
      final Map<String, String> headers = {
        "Accept": "*/*",
      };

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

      // ✅ Prepare files - validate file exists before sending
      final files = <File>[];
      if (model.companyLogo != null) {
        // Check if file exists before adding
        if (await model.companyLogo!.exists()) {
          files.add(model.companyLogo!);
          print("✅ Company Logo file exists: ${model.companyLogo!.path}");
        } else {
          print("❌ Company Logo file not found: ${model.companyLogo!.path}");
          SnackBarHelper.error("Image file not found. Please select image again.");
          return false;
        }
      }

      // ✅ Call multipart API
      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.completeTransport,
        fields: fields,
        files: files,
        fieldKey: "CompanyLogo",
        headers: headers,
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
      } else if (response.statusCode == 400) {
        // Handle validation errors (like CompanyLogo required)
        String errorMessage = "Validation Error";
        try {
          final errorData = json.decode(response.body);
          
          // Check for validation errors object
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
            
            // Special handling for CompanyLogo
            if (errors.containsKey('CompanyLogo')) {
              errorMessage = "Company Logo is required. Please select an image.";
            }
          } else if (errorData.containsKey('message')) {
            errorMessage = errorData['message'].toString();
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'].toString();
          }
        } catch (e) {
          if (response.body.contains('CompanyLogo')) {
            errorMessage = "Company Logo is required. Please select an image.";
          } else {
            errorMessage = response.body.isNotEmpty 
                          ? response.body.length > 100 
                            ? "${response.body.substring(0, 100)}..." 
                            : response.body
                          : "Validation failed";
          }
        }
        
        SnackBarHelper.error(errorMessage);
        return false;
      } else {
        // 🔍 Parse error message for other errors
        String errorMessage = "Failed to complete profile";
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? 
                        errorData['error'] ?? 
                        "Failed with status: ${response.statusCode}";
        } catch (e) {
          errorMessage = response.body.isNotEmpty 
                        ? response.body.length > 100 
                          ? "${response.body.substring(0, 100)}..." 
                          : response.body
                        : "Failed: ${response.statusCode}";
        }
        
        SnackBarHelper.error(errorMessage);
        return false;
      }
    } catch (e, stacktrace) {
      print("❌ Exception: $e");
      print("❌ StackTrace: $stacktrace");
      SnackBarHelper.error("An error occurred: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
    
    return false;
  }
}
