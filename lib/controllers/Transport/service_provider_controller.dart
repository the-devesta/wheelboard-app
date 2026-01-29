import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../models/service_provider_signup.dart';
import '../../models/add_service_model.dart';
import '../../models/update_service_model.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../utils/error_handler.dart';
import '../../widgets/custom_snackbar.dart';
import '../../screens/auth/login.dart';
import '../../utils/app_logger.dart';

class ServiceProviderController extends GetxController {
  var isLoading = false.obs;

  Future<void> completeServiceProvider(ServiceProviderModel model) async {
    if (isLoading.value) {
      AppLogger.d("⚠️ API call already in progress, skipping...");
      return;
    }

    try {
      isLoading.value = true;
      AppLogger.d("🚀 Starting Service Provider Registration...");

      final fields = model.toJsonFields();
      final files = <File>[];

      if (model.getBusinessLogo() != null) {
        files.add(model.getBusinessLogo()!);
      }

      AppLogger.d("📤 Sending request to API...");

      // Add timeout of 30 seconds
      final streamedResponse =
          await HttpHelper.uploadMultipart(
            endpoint: API.completeServiceProvider,
            fields: fields,
            files: files,
            fieldKey: "BusinessLogo",
            headers: {'Accept': 'application/json'},
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              AppLogger.d("⏱️ Request timed out after 30 seconds");
              throw Exception(
                'Request timeout. Please check your internet connection and try again.',
              );
            },
          );

      AppLogger.d("✅ Request sent, waiting for response...");
      AppLogger.d("📊 Response Status Code: ${streamedResponse.statusCode}");

      final response = await http.Response.fromStream(streamedResponse).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          AppLogger.d("⏱️ Response reading timed out");
          throw Exception('Response timeout. Please try again.');
        },
      );

      AppLogger.d("📥 Response received!");
      AppLogger.d("📊 Status Code: ${response.statusCode}");
      AppLogger.d(
        "📄 Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.d("✅ Profile completed successfully!");
        SnackBarHelper.success(
          "Profile completed successfully! Please login to continue.",
        );
        await Future.delayed(const Duration(milliseconds: 2000));
        // Navigate to login page - clear all previous routes
        Get.offAll(() => ProfessionLogin());
        return;
      }

      AppLogger.d("❌ API Error - Status: ${response.statusCode}");
      final errorMessage = ErrorHandler.parseError(
        response.body,
        statusCode: response.statusCode,
      );

      AppLogger.d("❌ Error Message: $errorMessage");
      SnackBarHelper.error(errorMessage);
    } catch (e) {
      AppLogger.d("❌ Exception caught: $e");
      AppLogger.d("❌ Exception type: ${e.runtimeType}");

      final errorMessage = ErrorHandler.handleNetworkError(e);
      AppLogger.d("❌ Final Error Message: $errorMessage");
      SnackBarHelper.error(errorMessage);
    } finally {
      AppLogger.d("🏁 Request completed, resetting loading state");
      isLoading.value = false;
    }
  }

  /// Update Service Provider Profile
  Future<void> updateServiceProvider(ServiceProviderModel model) async {
    if (isLoading.value) {
      AppLogger.d("⚠️ API call already in progress, skipping...");
      return;
    }

    try {
      isLoading.value = true;
      AppLogger.d("🚀 Starting Service Provider Profile Update...");

      final fields = model.toJsonFields();
      final files = <File>[];

      if (model.getBusinessLogo() != null) {
        files.add(model.getBusinessLogo()!);
      }

      AppLogger.d("📤 Sending update request to API...");

      final streamedResponse =
          await HttpHelper.uploadMultipart(
            endpoint: API.updateServiceProvider,
            fields: fields,
            files: files,
            fieldKey: "BusinessLogo",
            headers: {'Accept': 'application/json'},
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              AppLogger.d("⏱️ Request timed out after 30 seconds");
              throw Exception(
                'Request timeout. Please check your internet connection and try again.',
              );
            },
          );

      AppLogger.d("✅ Request sent, waiting for response...");
      AppLogger.d("📊 Response Status Code: ${streamedResponse.statusCode}");

      final response = await http.Response.fromStream(streamedResponse).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          AppLogger.d("⏱️ Response reading timed out");
          throw Exception('Response timeout. Please try again.');
        },
      );

      AppLogger.d("📥 Response received!");
      AppLogger.d("📊 Status Code: ${response.statusCode}");
      AppLogger.d(
        "📄 Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.d("✅ Profile updated successfully!");
        SnackBarHelper.success("Profile updated successfully!");
        await Future.delayed(const Duration(milliseconds: 800));
        Get.back(result: true); // Go back with success result
        return;
      }

      AppLogger.d("❌ API Error - Status: ${response.statusCode}");
      final errorMessage = ErrorHandler.parseError(
        response.body,
        statusCode: response.statusCode,
      );

      AppLogger.d("❌ Error Message: $errorMessage");
      SnackBarHelper.error(errorMessage);
    } catch (e) {
      AppLogger.d("❌ Exception caught: $e");
      AppLogger.d("❌ Exception type: ${e.runtimeType}");

      final errorMessage = ErrorHandler.handleNetworkError(e);
      AppLogger.d("❌ Final Error Message: $errorMessage");
      SnackBarHelper.error(errorMessage);
    } finally {
      AppLogger.d("🏁 Request completed, resetting loading state");
      isLoading.value = false;
    }
  }

  /// Add a new service
  Future<Map<String, dynamic>?> addService(AddServiceModel model) async {
    if (isLoading.value) return null;

    try {
      isLoading.value = true;

      final fields = model.toJsonFields();
      final files = model.getImages();

      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.addService,
        fields: fields,
        files: files,
        fieldKey: "Images", // API expects "Images" field name
        headers: {'Accept': '*/*'},
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          SnackBarHelper.success("Service added successfully!");
          return {'success': true, 'data': responseData};
        } catch (e) {
          SnackBarHelper.success("Service added successfully!");
          return {'success': true, 'data': response.body};
        }
      }

      final errorMessage = ErrorHandler.parseError(
        response.body,
        statusCode: response.statusCode,
      );

      SnackBarHelper.error(errorMessage);
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      final errorMessage = ErrorHandler.handleNetworkError(e);
      SnackBarHelper.error(errorMessage);
      return {'success': false, 'error': e.toString()};
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an existing service
  Future<Map<String, dynamic>?> updateService(UpdateServiceModel model) async {
    if (isLoading.value) return null;

    try {
      isLoading.value = true;

      final fields = model.toJsonFields();
      final files = model.getNewImages();

      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.updateService,
        fields: fields,
        files: files,
        fieldKey: "NewImages", // API expects "NewImages" field name
        headers: {'Accept': '*/*'},
        method: "POST",
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          SnackBarHelper.success("Service updated successfully!");
          return {'success': true, 'data': responseData};
        } catch (e) {
          SnackBarHelper.success("Service updated successfully!");
          return {'success': true, 'data': response.body};
        }
      }

      final errorMessage = ErrorHandler.parseError(
        response.body,
        statusCode: response.statusCode,
      );

      SnackBarHelper.error(errorMessage);
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      final errorMessage = ErrorHandler.handleNetworkError(e);
      SnackBarHelper.error(errorMessage);
      return {'success': false, 'error': e.toString()};
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a service
  Future<bool> deleteService(String serviceId, String userId) async {
    if (isLoading.value) return false;

    try {
      isLoading.value = true;

      AppLogger.d("🗑️ Deleting service: $serviceId for user: $userId");

      // Construct the delete endpoint URL
      final endpoint = '${API.deleteService}/$serviceId/user/$userId/delete';

      final response = await HttpHelper.postData(
        endpoint: endpoint,
        data: {}, // Empty body for delete
        headers: {
          'UserId': userId,
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      AppLogger.d("🗑️ Delete response status: ${response.statusCode}");
      AppLogger.d("🗑️ Delete response body: ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        SnackBarHelper.success("Service deleted successfully!");
        return true;
      }

      final errorMessage = ErrorHandler.parseError(
        response.body,
        statusCode: response.statusCode,
      );

      SnackBarHelper.error(errorMessage);
      return false;
    } catch (e) {
      AppLogger.d("❌ Error deleting service: $e");
      final errorMessage = ErrorHandler.handleNetworkError(e);
      SnackBarHelper.error(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
