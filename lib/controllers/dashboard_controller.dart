import 'dart:convert';
import 'package:get/get.dart';
import '../apihelperclass/api_helper.dart';
import '../models/dashboard_model.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import '../widgets/custom_snackbar.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;
  final dashboardData = Rxn<DashboardModel>();
  final errorMessage = ''.obs;
  final selectedProfessionalFilter = 'All'.obs;

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

      final authService = AuthService.to;
      final userId = authService.currentUserId;

      if (userId.isEmpty) {
        errorMessage.value = 'User not logged in';
        SnackBarHelper.error('User not logged in');
        isLoading.value = false;
        return;
      }

      final response = await HttpHelper.getData(
        endpoint: API.getDashboard,
        queryParams: {'userId': userId},
        headers: {'accept': '*/*'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        dashboardData.value = DashboardModel.fromJson(jsonData);
      } else {
        errorMessage.value =
            'Failed to load dashboard data (${response.statusCode})';
        SnackBarHelper.error(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load dashboard: ${e.toString()}';
      SnackBarHelper.error(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}
