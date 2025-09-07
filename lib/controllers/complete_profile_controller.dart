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
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import '../models/company_profilemodel.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
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

  /// Submit profile to backend
  ///
  ///
  ///
  //   Future<bool> submitProfile(CompleteProfileModel model) async {
  //     isLoading.value = true;
  //     try {
  //       // ✅ Prepare fields
  //       final fields = model.toJsonFields();

  //       // ✅ Prepare files
  //       final files = <File>[];
  //       if (model.companyLogo != null) {
  //         files.add(model.companyLogo!);
  //       }

  //       // ✅ Call multipart API
  //       final streamedResponse = await HttpHelper.uploadMultipart(
  //         endpoint: API.completeTransport, // e.g. "/profile/complete"
  //         fields: fields,
  //         files: files,
  //         fieldKey: "CompanyLogo", // backend expects "CompanyLogo"
  //         headers: {
  //           "Authorization": "Bearer YOUR_TOKEN", // optional
  //         },
  //       );

  //       // final response = await http.Response.fromStream(streamedResponse);

  //       if (streamedResponse.statusCode == 200) {
  //         Get.snackbar("Success", "Profile updated successfully");
  //         return true;
  //       } else {
  //         Get.snackbar("Error", "Failed: ${streamedResponse}");
  //         return false;
  //       }
  //     } catch (e) {
  //       Get.snackbar("Error", e.toString());
  //       return false;
  //     } finally {
  //       isLoading.value = false;
  //     }
  //   }
  // }

  Future<bool> submitProfile(CompleteProfileModel model) async {
    isLoading.value = true;
    try {
      // ✅ Prepare fields
      final fields = model.toJsonFields();

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
          "Authorization": "Bearer YOUR_TOKEN", // optional
        },
      );

      // 🔍 Convert to a normal Response so you can read the body
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Profile updated successfully");
        print("✅ Response Body: ${response.body}");
        return true;
      } else {
        // 🔍 Print details for debugging
        print("❌ Error Status: ${response.statusCode}");
        print("❌ Error Body: ${response.body}");
        print("❌ Error Headers: ${response.headers}");

        Get.snackbar("Error", "Failed: ${response.body}");
        return false;
      }
    } catch (e, stacktrace) {
      // 🔍 Capture exception + stacktrace for debugging
      print("⚠️ Exception: $e");
      print("⚠️ Stacktrace: $stacktrace");

      Get.snackbar("Error", e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
