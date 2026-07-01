import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/dashboard_model.dart';
import '../../services/expense_service.dart';
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

  /// Refreshes the company dashboard if it has already been initialised. Call
  /// after ANY trip or service mutation (create / schedule / edit / assign /
  /// complete / delete / booking) so the dashboard cards and the Upcoming Trips
  /// and Assigned Services lists stay in sync with the backend automatically —
  /// no manual pull-to-refresh needed. No-op when the dashboard was never
  /// opened, so it is safe to call from anywhere.
  static void refreshIfActive() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().fetchDashboardData();
    }
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

  /// Populates the dashboard sections that `/dashboard/stats` does not provide:
  /// "Jobs You Posted" (GET /jobs/my-jobs — the Jobs screen's source) and
  /// "Recent Transactions" / "Expense Overview" (GET /expenses — the Expenses
  /// screen's source; the stats payload only derives transactions from
  /// completed trips, so it was blank for owners who log expenses but have no
  /// trips this month). Best-effort: a failure keeps the existing data.
  Future<void> _mergeJobsAndExpenses() async {
    if (dashboardData.value == null) return;

    List<JobItem>? jobs;
    List<RecentTransaction>? txns;

    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.jobs.myJobs,
      );
      final body = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
      final list = (body['jobs'] as List<dynamic>?) ?? const [];
      jobs = list.whereType<Map<String, dynamic>>().map((j) {
        final apps = j['applications'];
        final saved = j['savedBy'];
        return JobItem(
          jobId: (j['id'] ?? j['jobId'])?.toString(),
          role: (j['title'] ?? j['role'])?.toString(),
          jobType: (j['type'] ?? j['jobType'])?.toString(),
          city: j['city']?.toString(),
          salary: _parseAmount(j['salaryMin'] ?? j['salary']),
          openings: (j['openings'] as num?)?.toInt(),
          description: j['description']?.toString(),
          applicants: apps is List
              ? apps.length
              : (j['applicants'] as num?)?.toInt() ?? 0,
          likeCount: saved is List
              ? saved.length
              : (j['likeCount'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (e) {
      AppLogger.e('⚠️ Dashboard jobs merge skipped: $e');
    }

    try {
      final expenses = await ExpenseService().getExpenses();
      txns = expenses
          .map((e) => RecentTransaction(
                expenseType: _capitalize(e.category),
                dateEntered: e.date?.toIso8601String(),
                amount: e.amount,
              ))
          .toList();
    } catch (e) {
      AppLogger.e('⚠️ Dashboard expenses merge skipped: $e');
    }

    if (jobs == null && txns == null) return;
    final current = dashboardData.value;
    if (current == null) return;
    dashboardData.value = current.copyWith(
      jobList: jobs,
      recentTransactions: txns,
    );
    AppLogger.d('✅ Dashboard jobs/expenses merged');
  }

  double? _parseAmount(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final digits = v.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(digits);
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

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
      await _mergeJobsAndExpenses();
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
