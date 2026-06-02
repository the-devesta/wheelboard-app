import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../../models/service_provider_signup.dart';
import '../../models/add_service_model.dart';
import '../../models/update_service_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
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
      final formData = dio.FormData.fromMap(fields);

      if (model.getBusinessLogo() != null) {
        formData.files.add(MapEntry(
          "BusinessLogo",
          await dio.MultipartFile.fromFile(model.getBusinessLogo()!.path),
        ));
      }

      AppLogger.d("📤 Sending request to API...");

      await ApiClient.instance.upload<dynamic>(
        ApiEndpoints.users.completeServiceProvider,
        formData: formData,
      );

      AppLogger.d("✅ Profile completed successfully!");
      SnackBarHelper.success(
        "Profile completed successfully! Please login to continue.",
      );
      await Future.delayed(const Duration(milliseconds: 2000));
      // Navigate to login page - clear all previous routes
      Get.offAll(() => const LoginScreen());
    } on dio.DioException catch (e) {
      AppLogger.d("❌ API Error: $e");
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to complete profile';
      SnackBarHelper.error(msg);
    } catch (e) {
      AppLogger.d("❌ Exception caught: $e");
      SnackBarHelper.error("Failed to complete profile: $e");
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
      final formData = dio.FormData.fromMap(fields);

      if (model.getBusinessLogo() != null) {
        formData.files.add(MapEntry(
          "BusinessLogo",
          await dio.MultipartFile.fromFile(model.getBusinessLogo()!.path),
        ));
      }

      AppLogger.d("📤 Sending update request to API...");

      await ApiClient.instance.upload<dynamic>(
        ApiEndpoints.users.updateServiceProvider,
        formData: formData,
      );

      AppLogger.d("✅ Profile updated successfully!");
      SnackBarHelper.success("Profile updated successfully!");
      await Future.delayed(const Duration(milliseconds: 800));
      Get.back(result: true); // Go back with success result
    } on dio.DioException catch (e) {
      AppLogger.d("❌ API Error: $e");
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to update profile';
      SnackBarHelper.error(msg);
    } catch (e) {
      AppLogger.d("❌ Exception caught: $e");
      SnackBarHelper.error("Failed to update profile: $e");
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
      final formData = dio.FormData.fromMap(fields);

      final files = model.getImages();
      for (var file in files) {
        formData.files.add(MapEntry(
          "Images",
          await dio.MultipartFile.fromFile(file.path),
        ));
      }

      final data = await ApiClient.instance.upload<dynamic>(
        ApiEndpoints.services.create,
        formData: formData,
      );

      SnackBarHelper.success("Service added successfully!");
      return {'success': true, 'data': data};
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to add service';
      SnackBarHelper.error(msg);
      return {'success': false, 'error': msg};
    } catch (e) {
      SnackBarHelper.error(e.toString());
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
      final formData = dio.FormData.fromMap(fields);

      final files = model.getNewImages();
      for (var file in files) {
        formData.files.add(MapEntry(
          "NewImages",
          await dio.MultipartFile.fromFile(file.path),
        ));
      }

      final data = await ApiClient.instance.upload<dynamic>(
        ApiEndpoints.services.update(model.serviceId),
        formData: formData,
        method: 'PATCH',
      );

      SnackBarHelper.success("Service updated successfully!");
      return {'success': true, 'data': data};
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to update service';
      SnackBarHelper.error(msg);
      return {'success': false, 'error': msg};
    } catch (e) {
      SnackBarHelper.error(e.toString());
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

      await ApiClient.instance.delete(
        ApiEndpoints.services.delete(serviceId),
      );

      SnackBarHelper.success("Service deleted successfully!");
      return true;
    } on dio.DioException catch (e) {
      AppLogger.d("❌ Error deleting service: $e");
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to delete service';
      SnackBarHelper.error(msg);
      return false;
    } catch (e) {
      AppLogger.d("❌ Error deleting service: $e");
      SnackBarHelper.error("Failed to delete service: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
