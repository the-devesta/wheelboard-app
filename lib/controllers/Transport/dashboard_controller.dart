import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/auth/auth_service.dart';
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

      final userId = AuthService.to.userId;

      if (userId.isEmpty) {
        errorMessage.value = 'User not logged in';
        SnackBarHelper.error('User not logged in');
        isLoading.value = false;
        return;
      }

      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.dashboard.get,
        queryParameters: {'userId': userId},
      );

      dashboardData.value = DashboardModel.fromJson(data);
      AppLogger.d('✅ Dashboard data loaded');
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
