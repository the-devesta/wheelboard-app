import 'dart:convert';
import 'package:get/get.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../utils/app_logger.dart';
import '../../services/auth_service.dart';

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

      final response = await HttpHelper.getData(
        endpoint: API.earningsDashboard,
        queryParams: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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
      } else {
        AppLogger.e("Failed to fetch earnings data: ${response.statusCode}");
      }
    } catch (e) {
      AppLogger.e("Error fetching earnings data: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
