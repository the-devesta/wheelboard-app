import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:wheelboard/core/network/api_client.dart';
import 'package:wheelboard/core/network/api_endpoints.dart';
import 'package:wheelboard/core/network/api_exception.dart';
import 'package:wheelboard/models/Professional/trip_dashboard_model.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import '../../utils/app_logger.dart';

class TripDashboardController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var isLoading = true.obs;
  var dashboardData = Rxn<TripDashboardModel>();

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading(true);
      final userId = _authService.currentUserId;
      if (userId.isEmpty) {
        AppLogger.d('⚠️ User not logged in or userId is missing');
        return;
      }

      AppLogger.d("📊 Fetching trip dashboard data for userId: $userId");

      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.trips.tripDashboard,
        queryParameters: {'userId': userId},
      );

      dashboardData.value = TripDashboardModel.fromJson(data);
      AppLogger.d("✅ Trip dashboard data loaded successfully");
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load trip dashboard data';
      AppLogger.d('❌ Error fetching trip dashboard data: $msg');
    } catch (e) {
      AppLogger.d('❌ Error fetching trip dashboard data: $e');
    } finally {
      isLoading(false);
    }
  }
}
