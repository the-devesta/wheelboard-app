import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/driver_details_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';
import 'package:wheelboard/core/auth/auth_service.dart';

class DriverDetailsController extends GetxController {
  var isLoading = false.obs;
  Rx<DriverDetailsModel?> driverDetails = Rx<DriverDetailsModel?>(null);

  Future<void> fetchDriverDetails(String driverId) async {
    try {
      isLoading.value = true;

      AppLogger.d("👤 Fetching driver details for ID: $driverId");

      final data = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.fleet.driverDetails(driverId),
      );

      if (data != null && data != "") {
        // Check if response has nested structure
        if (data is Map<String, dynamic>) {
          // If data is directly the driver object
          if (data.containsKey('driverId')) {
            driverDetails.value = DriverDetailsModel.fromJson(data);
            // Update AuthService KYC status based on driver details
            if (driverDetails.value != null) {
              final isVerified =
                  driverDetails.value!.isVerified ||
                  driverDetails.value!.isKYCCompleted;
              AuthService.to.updateKYCStatus(isVerified);
              AppLogger.d(
                "✅ Updated AuthService KYC Status from Driver Details: $isVerified",
              );
            }
            AppLogger.d(
              "✅ Driver details loaded successfully: ${driverDetails.value?.fullName}",
            );
          }
          // If data is wrapped in a result/response object
          else if (data.containsKey('result')) {
            final result = data['result'];
            if (result is Map<String, dynamic>) {
              driverDetails.value = DriverDetailsModel.fromJson(result);
              // Update AuthService KYC status based on driver details
              if (driverDetails.value != null) {
                final isVerified =
                    driverDetails.value!.isVerified ||
                    driverDetails.value!.isKYCCompleted;
                AuthService.to.updateKYCStatus(isVerified);
                AppLogger.d(
                  "✅ Updated AuthService KYC Status from Driver Details: $isVerified",
                );
              }
              AppLogger.d(
                "✅ Driver details loaded successfully: ${driverDetails.value?.fullName}",
              );
            } else {
              SnackBarHelper.error("Invalid driver data format");
            }
          } else {
            SnackBarHelper.error("Driver details not found in response");
          }
        } else {
          SnackBarHelper.error("Invalid response format");
        }
      } else {
        AppLogger.d("ℹ️ No driver details found (204 - No Content)");
        driverDetails.value = null; // Valid state, just no data yet
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        AppLogger.d("❌ Driver not found (404)");
      } else {
        final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load driver details';
        AppLogger.d("❌ Failed to load driver details: $msg");
        SnackBarHelper.error("Failed to load driver details");
      }
    } catch (e) {
      AppLogger.d("❌ Error fetching driver details: $e");
      SnackBarHelper.error("Error fetching driver details: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch a professional bidder's public profile.
  ///
  /// Bidders are *users*, so we hit `GET /users/:id/public-profile`
  /// (same endpoint the web uses) — NOT `/fleet/drivers/:id`, which only
  /// exists for a company's own fleet drivers and 404s for professionals.
  Future<void> fetchPublicProfile(String userId) async {
    try {
      isLoading.value = true;
      driverDetails.value = null;

      AppLogger.d("👤 Fetching public profile for user: $userId");

      final data = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.users.publicProfile(userId),
      );

      if (data is Map<String, dynamic> && data.isNotEmpty) {
        driverDetails.value = DriverDetailsModel.fromUserProfile(data);
        AppLogger.d(
            "✅ Public profile loaded: ${driverDetails.value?.fullName}");
      } else {
        AppLogger.d("ℹ️ Empty public profile response");
      }
    } on DioException catch (e) {
      // Fall back to the fleet-driver endpoint in case this id is a fleet driver.
      if (e.response?.statusCode == 404) {
        AppLogger.d("↪️ Public profile 404 — trying fleet driver endpoint");
        await fetchDriverDetails(userId);
        return;
      }
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to load profile';
      AppLogger.d("❌ Failed to load public profile: $msg");
    } catch (e) {
      AppLogger.d("❌ Error fetching public profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteDriver(
    String driverId,
    String userId,
    String token,
  ) async {
    try {
      AppLogger.d("==================================");
      AppLogger.d("📡 Deleting Driver");
      AppLogger.d("==================================");

      await ApiClient.instance.post(
        ApiEndpoints.fleet.deleteDriver(driverId),
        queryParameters: {'modifiedBy': userId},
      );

      return true;
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to delete driver';
      AppLogger.d("❌ Exception in deleteDriver: $msg");
      SnackBarHelper.error("Failed to delete driver");
      return false;
    } catch (e) {
      AppLogger.d("❌ Exception in deleteDriver: $e");
      SnackBarHelper.error("Exception: $e");
      return false;
    }
  }
}
