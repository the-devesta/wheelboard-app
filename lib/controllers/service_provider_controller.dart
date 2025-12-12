import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/service_provider_signup.dart';
import '../models/add_service_model.dart';
import '../models/update_service_model.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../utils/navigation_helper.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_snackbar.dart';

class ServiceProviderController extends GetxController {
  var isLoading = false.obs;

  Future<void> completeServiceProvider(ServiceProviderModel model) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final fields = model.toJsonFields();
      final files = <File>[];

      if (model.getBusinessLogo() != null) {
        files.add(model.getBusinessLogo()!);
      }

      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.completeServiceProvider,
        fields: fields,
        files: files,
        fieldKey: "BusinessLogo",
        headers: {'Accept': 'application/json'},
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarHelper.success("Profile completed successfully!");
        await Future.delayed(const Duration(milliseconds: 1500));
        NavigationHelper.navigateToMainWrapper();
        return;
      }

      final errorMessage = ErrorHandler.parseError(
        response.body,
        statusCode: response.statusCode,
      );

      SnackBarHelper.error(errorMessage);
    } catch (e) {
      final errorMessage = ErrorHandler.handleNetworkError(e);
      SnackBarHelper.error(errorMessage);
    } finally {
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

      print("🗑️ Deleting service: $serviceId for user: $userId");

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

      print("🗑️ Delete response status: ${response.statusCode}");
      print("🗑️ Delete response body: ${response.body}");

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
      print("❌ Error deleting service: $e");
      final errorMessage = ErrorHandler.handleNetworkError(e);
      SnackBarHelper.error(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
