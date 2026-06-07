import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../utils/app_logger.dart';

/// Professional earnings — fetches the SAME real endpoint the web uses
/// (`GET /trips/professional/stats` → `getProfessionalStats`, identified by the
/// JWT). Previously this hit `/trips/earnings-dashboard`, which doesn't exist on
/// the backend, so no real data ever loaded.
class EarningSummaryController extends GetxController {
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var totalIncome = 0.0.obs;
  var tripsCompleted = 0.obs;
  var avgEarningPerTrip = 0.0.obs;
  var pendingAmount = 0.0.obs;
  var thisMonthEarnings = 0.0.obs;
  var lastMonthEarnings = 0.0.obs;
  var percentageChange = 0.0.obs;

  /// Chart points: `{month, amount}` (web `monthlyData[].earnings`).
  var earningsChart = <Map<String, dynamic>>[].obs;

  /// Raw transactions (web shape: id, tripId, date, type, amount, description,
  /// status, from, to).
  var transactions = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEarningsData();
  }

  double _d(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString().replaceAll(',', '') ?? '') ?? 0;
  }

  int _i(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  Future<void> fetchEarningsData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // JWT identifies the professional — no userId param (web parity).
      final raw = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.trips.professionalStats,
      );

      // The backend wraps the payload as `{ message, data: {...stats} }`
      // (web reads `response.data.data`). Unwrap the envelope here — reading the
      // top level directly is why earnings always showed ₹0.
      final data = (raw['data'] is Map<String, dynamic>)
          ? raw['data'] as Map<String, dynamic>
          : raw;

      totalIncome.value = _d(data['earnings'] ?? data['totalEarnings']);
      tripsCompleted.value = _i(data['completed'] ?? data['completedTrips']);
      avgEarningPerTrip.value = _d(data['averagePerTrip']);
      pendingAmount.value =
          _d(data['pendingAmount'] ?? data['estimatedEarnings']);
      thisMonthEarnings.value = _d(data['thisMonthEarnings']);
      lastMonthEarnings.value = _d(data['lastMonthEarnings']);
      percentageChange.value =
          _d(data['percentageChange'] ?? data['earningsChange']);

      final monthly = data['monthlyData'] as List<dynamic>? ?? [];
      earningsChart.value = monthly.whereType<Map<String, dynamic>>().map((m) {
        return {'month': m['month']?.toString() ?? '', 'amount': _d(m['earnings'])};
      }).toList();

      final txns = data['transactions'] as List<dynamic>? ?? [];
      transactions.value =
          txns.whereType<Map<String, dynamic>>().toList();

      AppLogger.d(
          '✅ Earnings: ₹${totalIncome.value}, ${tripsCompleted.value} trips, '
          '${transactions.length} txns, ${earningsChart.length} chart pts');
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to fetch earnings data';
      AppLogger.e('Error fetching earnings data: $msg');
      hasError.value = true;
      errorMessage.value = msg;
    } catch (e) {
      AppLogger.e('Error fetching earnings data: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to load earnings data';
    } finally {
      isLoading.value = false;
    }
  }
}
