import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:wheelboard/core/network/api_client.dart';
import 'package:wheelboard/core/network/api_endpoints.dart';
import 'package:wheelboard/core/network/api_exception.dart';
import 'package:wheelboard/models/ServiceProvider/service_earnings_model.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import '../../utils/app_logger.dart';
import '../../widgets/custom_snackbar.dart';

class ServiceEarningsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var isLoading = true.obs;
  var isRecordingPayment = false.obs;
  var dashboardData = Rxn<ServiceEarningsModel>();

  // Analytics window: 'monthly' | 'quarterly' | 'yearly' (matches web).
  var selectedPeriod = 'monthly'.obs;

  // Recorded payments (manual + online) for the Payment History list.
  var myPayments = <PaymentHistory>[].obs;

  // Separate service list for payment dropdown
  var userServices = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEarningsDashboard();
    fetchUserServices(); // Also fetch services
    fetchMyPayments(); // Payment history
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

      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.services.earningsAnalytics,
        queryParameters: {'userId': userId, 'period': selectedPeriod.value},
      );

      dashboardData.value = ServiceEarningsModel.fromJson(data);
      AppLogger.d("✅ Earnings dashboard data loaded successfully");
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load earnings data';
      AppLogger.d('❌ Error fetching earnings dashboard data: $msg');
    } catch (e) {
      AppLogger.d('❌ Error fetching earnings dashboard data: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Switch the analytics window (monthly | quarterly | yearly) and refetch.
  void setPeriod(String period) {
    if (selectedPeriod.value == period) return;
    selectedPeriod.value = period;
    fetchEarningsDashboard();
  }

  /// Payment history from `/services/payments/my` (the analytics endpoint does
  /// not return per-payment rows, so the Payment History list comes from here).
  Future<void> fetchMyPayments() async {
    try {
      final userId = _authService.currentUserId;
      if (userId.isEmpty) return;
      final data = await ApiClient.instance.get<List<dynamic>>(
        ApiEndpoints.services.myPayments,
        queryParameters: {'userId': userId},
      );
      myPayments.value = data
          .whereType<Map<String, dynamic>>()
          .map(PaymentHistory.fromJson)
          .toList();
    } catch (e) {
      AppLogger.d('❌ Error fetching my payments: $e');
    }
  }

  /// Fetch user's services for payment dropdown
  Future<void> fetchUserServices() async {
    try {
      final userId = _authService.currentUserId;
      if (userId.isEmpty) return;

      AppLogger.d("📋 Fetching user services for userId: $userId");

      // Backend filters the service list on `businessId` (mapped to the owner).
      final decoded = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.services.list,
        queryParameters: {'businessId': userId},
      );

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
            // Backend returns `id` / `title`; keep legacy keys as fallbacks.
            'serviceId': (s['id'] ?? s['serviceId'] ?? '').toString(),
            'serviceTitle': (s['title'] ?? s['serviceTitle'] ?? 'Service').toString(),
          };
        }).toList();
        AppLogger.d("✅ Loaded ${userServices.length} services for dropdown");
      } else {
        AppLogger.d('⚠️ No services found for user');
      }
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load services';
      AppLogger.d('❌ Error fetching user services: $msg');
    } catch (e) {
      AppLogger.d('❌ Error fetching user services: $e');
    }
  }

  Future<bool> recordPayment({
    required String serviceId,
    required double amount,
    required String purpose,
    required String notes,
    DateTime? date,
  }) async {
    try {
      isRecordingPayment(true);
      final userId = _authService.currentUserId;

      final Map<String, dynamic> paymentData = {
        "purposeOfPayment": purpose,
        "paymentAmount": amount,
        "serviceId": serviceId,
        "paymentDate": (date ?? DateTime.now()).toIso8601String(),
        "paymentNotes": notes,
        "userId": userId,
      };

      AppLogger.d("💸 Recording payment: $paymentData");

      final data = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiEndpoints.services.recordPayment,
        data: paymentData,
      );

      String successMessage = data['message'] ?? 'Payment recorded successfully!';
      SnackBarHelper.success(successMessage);

      // Refresh data in background
      fetchEarningsDashboard();
      fetchMyPayments();

      return true;
    } on DioException catch (e) {
      AppLogger.d('❌ Error recording payment: $e');
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to record payment';
      SnackBarHelper.error(msg);
      return false;
    } catch (e) {
      AppLogger.d('❌ Error recording payment: $e');
      SnackBarHelper.error('Something went wrong');
      return false;
    } finally {
      isRecordingPayment(false);
    }
  }
}
