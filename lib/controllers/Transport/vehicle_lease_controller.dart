import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/vehicle_lease_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

/// Controller for Vehicle Lease operations
class VehicleLeaseController extends GetxController {
  var isLoading = false.obs;
  var leaseList = <VehicleLeaseModel>[].obs;

  /// Add a new vehicle lease
  Future<bool> addVehicleLease(
    VehicleLeaseModel leaseModel,
    String token,
  ) async {
    try {
      isLoading.value = true;

      AppLogger.d("🚛 ==================================");
      AppLogger.d("🚛 STARTING VEHICLE LEASE ADDITION");
      AppLogger.d("🚛 ==================================");

      final requestData = leaseModel.toJson();

      AppLogger.d("🚛 Request JSON: $requestData");
      AppLogger.d("🚛 ==================================");

      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiEndpoints.lease.createListing,
        data: requestData,
      );

      AppLogger.d("🚛 ==================================");
      AppLogger.d("🚛 RESPONSE FROM API");
      AppLogger.d("🚛 ==================================");
      AppLogger.d("🚛 Response Body: $response");
      AppLogger.d("🚛 ==================================");

      if (response['success'] == true) {
        AppLogger.d("🚛 ✅ VEHICLE LEASE ADDED SUCCESSFULLY!");
        SnackBarHelper.success(
          response['message'] ?? "Lease posted successfully",
        );
        return true;
      } else {
        AppLogger.d("🚛 ❌ API returned success: false");
        SnackBarHelper.error(
          response['message'] ?? "Failed to add lease",
        );
        return false;
      }
    } on DioException catch (e) {
      AppLogger.d("🚛 ==================================");
      AppLogger.d("🚛 ❌ VEHICLE LEASE ADDITION FAILED!");
      AppLogger.d("🚛 Exception: $e");
      
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to add lease';
      AppLogger.d("🚛 Error Message: $msg");
      SnackBarHelper.error(msg);
      return false;
    } catch (e, stack) {
      AppLogger.d("🚛 ==================================");
      AppLogger.d("🚛 EXCEPTION OCCURRED");
      AppLogger.d("🚛 ==================================");
      AppLogger.d("🚛 Exception: $e");
      AppLogger.d("🚛 Stacktrace: $stack");
      AppLogger.d("🚛 ==================================");
      SnackBarHelper.error("Something went wrong: $e");
      return false;
    } finally {
      isLoading.value = false;
      AppLogger.d("🚛 Loading state set to false");
    }
  }

  /// Get vehicle lease list (if API available)
  Future<void> getVehicleLeases(String userId, String token) async {
    try {
      isLoading.value = true;

      // TODO: Implement when GET lease list API is available
      AppLogger.d("🚛 Get Vehicle Leases - Not yet implemented");
    } catch (e) {
      AppLogger.d("🚛 Error fetching leases: $e");
      SnackBarHelper.error("Failed to fetch leases");
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear lease data
  void clearData() {
    leaseList.clear();
  }
}
