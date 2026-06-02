import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/company_profilemodel.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

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
      // ✅ Prepare fields - ensure all required fields are present
      final fields = model.toJsonFields();

      final formData = dio.FormData.fromMap(fields);

      if (model.companyLogo != null) {
        // Check if file exists before adding
        if (await model.companyLogo!.exists()) {
          formData.files.add(MapEntry(
            'CompanyLogo',
            await dio.MultipartFile.fromFile(model.companyLogo!.path),
          ));
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
      AppLogger.d("👉 Fields: $fields");
      AppLogger.d("==================================");

      // ✅ Call multipart API
      await ApiClient.instance.upload<dynamic>(
        ApiEndpoints.users.completeTransport,
        formData: formData,
      );

      AppLogger.d("✅ Profile completed successfully");
      return true;
    } on dio.DioException catch (e) {
      AppLogger.d("❌ Exception: $e");
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Validation failed';
      SnackBarHelper.error(msg);
      return false;
    } catch (e, stacktrace) {
      AppLogger.d("❌ Exception: $e");
      AppLogger.d("❌ StackTrace: $stacktrace");

      SnackBarHelper.error("Error submitting profile: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
