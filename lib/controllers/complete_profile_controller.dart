import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/company_profilemodel.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_snackbar.dart';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';

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
          final String fileName =
              'company_logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final String permanentPath = '${appDocDir.path}/$fileName';

          // Copy the file to permanent location
          final File permanentFile = await File(
            pickedFile.path,
          ).copy(permanentPath);

          profileImage.value = permanentFile;
          SnackBarHelper.success("Image selected successfully");
        } catch (e) {
          AppLogger.d("Error copying image: $e");
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
      final Map<String, String> headers = {"Accept": "*/*"};

      // ✅ Prepare fields - ensure all required fields are present
      final fields = model.toJsonFields();

      // ✅ Prepare files - validate file exists before sending
      final files = <File>[];
      if (model.companyLogo != null) {
        // Check if file exists before adding
        if (await model.companyLogo!.exists()) {
          files.add(model.companyLogo!);
          AppLogger.d("✅ Company Logo file exists: ${model.companyLogo!.path}");
        } else {
          AppLogger.d(
            "❌ Company Logo file not found: ${model.companyLogo!.path}",
          );
          SnackBarHelper.error(
            "Image file not found. Please select image again.",
          );
          return false;
        }
      }

      // ✅ Debug log
      AppLogger.d("==================================");
      AppLogger.d("📡 Complete Transport Profile Request");
      AppLogger.d("👉 URL: ${API.completeTransport}");
      AppLogger.d("👉 Headers: $headers");
      AppLogger.d("👉 Fields: $fields");
      AppLogger.d("👉 Files attached: ${files.length}");
      AppLogger.d("==================================");

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

      AppLogger.d("==================================");
      AppLogger.d("📥 Response Received");
      AppLogger.d("👉 Status Code: ${response.statusCode}");
      AppLogger.d("👉 Body: ${response.body}");
      AppLogger.d("==================================");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          if (responseData['message'] != null ||
              responseData['success'] == true) {
            AppLogger.d("✅ Profile completed successfully");
            return true;
          }
        } catch (e) {
          // If response is not JSON but status is 200, consider it success
          AppLogger.d("✅ Profile completed successfully (non-JSON response)");
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
              errorMessage =
                  "Company Logo is required. Please select an image.";
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
        // ✅ Use ErrorHandler for user-friendly messages
        final errorMessage = ErrorHandler.parseError(
          response.body,
          statusCode: response.statusCode,
        );

        AppLogger.d("❌ Profile completion failed: $errorMessage");
        SnackBarHelper.error(errorMessage);
        return false;
      }
    } catch (e, stacktrace) {
      AppLogger.d("❌ Exception: $e");
      AppLogger.d("❌ StackTrace: $stacktrace");

      // ✅ Use ErrorHandler for network errors
      final errorMessage = ErrorHandler.handleNetworkError(e);
      SnackBarHelper.error(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }

    return false;
  }
}
