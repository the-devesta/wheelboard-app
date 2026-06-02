import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../utils/app_logger.dart';
import 'package:wheelboard/core/auth/auth_service.dart';

class EarningSummaryController extends GetxController {
  var isLoading = true.obs;
  var totalIncome = 0.0.obs;
  var tripsCompleted = 0.obs;
  var avgEarningPerTrip = 0.0.obs;
  var earningsChart = <Map<String, dynamic>>[].obs;
  var transactions = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEarningsData();
  }

  Future<void> fetchEarningsData() async {
    try {
      isLoading.value = true;
      final userId = AuthService.to.currentUserId;

      if (userId.isEmpty) {
        AppLogger.e("User ID is empty in EarningSummaryController");
        return;
      }

      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.trips.earningsDashboard,
        queryParameters: {'userId': userId},
      );

      totalIncome.value = (data['totalIncome'] ?? 0).toDouble();
      tripsCompleted.value = data['tripsCompleted'] ?? 0;
      avgEarningPerTrip.value = (data['avgEarningPerTrip'] ?? 0).toDouble();

      if (data['earningsChart'] != null) {
        earningsChart.value = List<Map<String, dynamic>>.from(
          data['earningsChart'],
        );
      }

      if (data['transactions'] != null) {
        transactions.value = List<Map<String, dynamic>>.from(
          data['transactions'],
        );
      }
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to fetch earnings data';
      AppLogger.e("Error fetching earnings data: $msg");
    } catch (e) {
      AppLogger.e("Error fetching earnings data: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
