import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/dashboard_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;
  final dashboardData = Rxn<DashboardModel>();
  final errorMessage = ''.obs;
  final selectedProfessionalFilter = 'All'.obs;
  final showAllAssignedServices = false.obs;
  final showAllProfessionals = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  void setProfessionalFilter(String filter) {
    selectedProfessionalFilter.value = filter;
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fleet-owner stats are JWT-scoped on the backend (req.user.id). Mirrors
      // wheelboard-fe getDashboardStats() → GET /dashboard/stats. The previous
      // GET /dashboard?userId=... hit the *admin* dashboard and ignored userId.
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.dashboard.stats,
      );

      // /dashboard/stats wraps the payload as { success, data: {...} }.
      final body = raw is Map<String, dynamic> ? (raw['data'] ?? raw) : raw;

      dashboardData.value =
          DashboardModel.fromStats(body as Map<String, dynamic>);
      AppLogger.d('✅ Dashboard stats loaded');
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Failed to load dashboard';
      errorMessage.value = msg;
      SnackBarHelper.error(msg);
      AppLogger.e('❌ Dashboard fetch error: $e');
    } catch (e) {
      errorMessage.value = 'Failed to load dashboard: ${e.toString()}';
      SnackBarHelper.error(errorMessage.value);
      AppLogger.e('❌ Dashboard unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
