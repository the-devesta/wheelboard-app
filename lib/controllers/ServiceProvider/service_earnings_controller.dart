import 'dart:convert';
import 'package:get/get.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/models/ServiceProvider/service_earnings_model.dart';
import 'package:wheelboard/services/auth_service.dart';
import 'package:wheelboard/utils/constants.dart';
import '../../utils/app_logger.dart';
import '../../widgets/custom_snackbar.dart';

class ServiceEarningsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var isLoading = true.obs;
  var isRecordingPayment = false.obs;
  var dashboardData = Rxn<ServiceEarningsModel>();

  // Separate service list for payment dropdown
  var userServices = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEarningsDashboard();
    fetchUserServices(); // Also fetch services
  }

  Future<void> fetchEarningsDashboard() async {
    try {
      isLoading(true);
      final userId = _authService.currentUserId;
      if (userId.isEmpty) {
        AppLogger.d('⚠️ User not logged in or userId is missing');
        isLoading(false);
        return;
      }

      AppLogger.d("💰 Fetching service provider earnings for userId: $userId");

      final response = await HttpHelper.getData(
        endpoint: '${API.serviceEarningsDashboard}?userId=$userId',
        headers: {
          'Authorization': 'Bearer ${_authService.currentToken}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        dashboardData.value = ServiceEarningsModel.fromJson(data);
        AppLogger.d("✅ Earnings dashboard data loaded successfully");
      } else {
        AppLogger.d('❌ Failed to load earnings data: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.d('❌ Error fetching earnings dashboard data: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Fetch user's services for payment dropdown
  Future<void> fetchUserServices() async {
    try {
      final userId = _authService.currentUserId;
      if (userId.isEmpty) return;

      AppLogger.d("📋 Fetching user services for userId: $userId");

      final response = await HttpHelper.getData(
        endpoint: '${API.serviceListByUser}$userId',
        headers: {
          'Authorization': 'Bearer ${_authService.currentToken}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List services = [];

        // Handle different response formats
        if (decoded is List) {
          // API returns List directly
          services = decoded;
        } else if (decoded is Map) {
          // API returns Map with success/data structure
          if (decoded['success'] == true && decoded['data'] != null) {
            services = decoded['data'] as List;
          } else if (decoded['data'] != null) {
            services = decoded['data'] as List;
          }
        }

        if (services.isNotEmpty) {
          userServices.value = services.map<Map<String, String>>((s) {
            return {
              'serviceId': (s['serviceId'] ?? '').toString(),
              'serviceTitle': (s['serviceTitle'] ?? s['title'] ?? 'Service')
                  .toString(),
            };
          }).toList();
          AppLogger.d("✅ Loaded ${userServices.length} services for dropdown");
        } else {
          AppLogger.d('⚠️ No services found for user');
        }
      } else {
        AppLogger.d('❌ Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.d('❌ Error fetching user services: $e');
    }
  }

  Future<bool> recordPayment({
    required String serviceId,
    required double amount,
    required String purpose,
    required String notes,
  }) async {
    try {
      isRecordingPayment(true);
      final userId = _authService.currentUserId;

      final Map<String, dynamic> paymentData = {
        "purposeOfPayment": purpose,
        "paymentAmount": amount,
        "serviceId": serviceId,
        "paymentDate": DateTime.now().toIso8601String(),
        "paymentNotes": notes,
        "userId": userId,
      };

      AppLogger.d("💸 Recording payment: ${jsonEncode(paymentData)}");

      final response = await HttpHelper.postData(
        endpoint: API.createPayment,
        data: paymentData,
        headers: {
          'Authorization': 'Bearer ${_authService.currentToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response to get message
        String successMessage = 'Payment recorded successfully!';
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == true &&
              responseData['message'] != null) {
            successMessage = responseData['message'];
          }
        } catch (_) {}

        SnackBarHelper.success(successMessage);

        // Refresh data in background
        fetchEarningsDashboard();

        return true;
      } else {
        AppLogger.d('❌ Failed to record payment: ${response.statusCode}');

        // Try to parse error message from response
        String errorMessage = 'Failed to record payment';
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['message'] != null) {
            errorMessage = responseData['message'];
          }
        } catch (_) {}

        SnackBarHelper.error(errorMessage);
        return false;
      }
    } catch (e) {
      AppLogger.d('❌ Error recording payment: $e');
      SnackBarHelper.error('Something went wrong');
      return false;
    } finally {
      isRecordingPayment(false);
    }
  }
}
