import 'package:get/get.dart';
import 'dart:convert';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/models/Professional/trip_dashboard_model.dart';
import 'package:wheelboard/services/auth_service.dart';
import 'package:wheelboard/utils/constants.dart';
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
        isLoading(false);
        return;
      }

      AppLogger.d("📊 Fetching trip dashboard data for userId: $userId");

      final response = await HttpHelper.getData(
        endpoint: '${API.tripDashboard}?userId=$userId',
        headers: {
          'Authorization': 'Bearer ${_authService.currentToken}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        AppLogger.d("📊 Dashboard Data: ${response.body}"); // Log raw data
        final Map<String, dynamic> data = jsonDecode(response.body);
        dashboardData.value = TripDashboardModel.fromJson(data);
        AppLogger.d("✅ Trip dashboard data loaded successfully");
      } else {
        AppLogger.d(
          '❌ Failed to load trip dashboard data: ${response.statusCode}',
        );
      }
    } catch (e) {
      AppLogger.d('❌ Error fetching trip dashboard data: $e');
    } finally {
      isLoading(false);
    }
  }
}
