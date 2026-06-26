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

  /// Overlays the authoritative fleet figures (GET /fleet/summary — the same
  /// source the Fleet page uses) onto the loaded dashboard data, so the
  /// "Active Vehicles", "Vehicle Availability" and "Vehicles on Lease" cards
  /// always reflect the real fleet. Best-effort: any failure is swallowed and
  /// the existing /dashboard/stats figures are kept.
  Future<void> _mergeFleetSummary() async {
    final model = dashboardData.value;
    if (model == null) return;
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.fleet.summary,
      );
      final body = raw is Map<String, dynamic> ? (raw['data'] ?? raw) : raw;
      if (body is! Map<String, dynamic>) return;

      final stats = (body['stats'] as Map<String, dynamic>?) ?? const {};
      final vehicles = (body['vehicles'] as List<dynamic>?) ?? const [];

      final total = (stats['totalVehicles'] as num?)?.toInt() ?? vehicles.length;
      final available = (stats['availableVehicles'] as num?)?.toInt() ?? 0;
      final onTrip = (stats['vehiclesOnTrip'] as num?)?.toInt() ?? 0;
      final leased = vehicles
          .whereType<Map<String, dynamic>>()
          .where((v) => v['isLeased'] == true)
          .length;

      dashboardData.value = model.copyWith(
        activeVehicles: ActiveVehicles(
          activeVehicles: total,
          inMaintenance: model.activeVehicles.inMaintenance,
        ),
        vehicleAvailability: VehicleAvailability(
          available: available,
          onTrip: onTrip,
          onRent: leased,
        ),
        vehiclesOnLease: VehiclesOnLease(
          total: leased,
          leasedThisWeek: model.vehiclesOnLease?.leasedThisWeek ?? 0,
        ),
      );
      AppLogger.d('✅ Dashboard fleet summary merged (vehicles: $total)');
    } catch (e) {
      AppLogger.e('⚠️ Dashboard fleet-summary merge skipped: $e');
    }
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

      // Overlay the real fleet figures from the same endpoint the Fleet page
      // uses (GET /fleet/summary). /dashboard/stats can under-report vehicles
      // (older builds counted vehicles via trips, so a fleet with no active
      // trip showed 0). This keeps the vehicle cards consistent with the Fleet
      // page. Best-effort: never let a summary failure break the dashboard.
      await _mergeFleetSummary();
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
