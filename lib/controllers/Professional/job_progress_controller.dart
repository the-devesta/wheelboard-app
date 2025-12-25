import 'dart:convert';
import 'package:get/get.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../models/Professional/applied_job_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

class JobProgressController extends GetxController {
  var isLoading = false.obs;
  var appliedJobs = <AppliedJob>[].obs;
  var savedJobs = <AppliedJob>[].obs; // Can be populated later if needed
  var searchQuery = ''.obs;
  var selectedFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAppliedJobs();
  }

  /// Fetch applied jobs from API
  Future<void> fetchAppliedJobs() async {
    try {
      isLoading.value = true;

      final authService = AuthService.to;
      final userId = authService.currentUserId;
      final token = authService.currentToken;

      if (userId.isEmpty) {
        AppLogger.d("⚠️ User not logged in, cannot fetch applied jobs");
        SnackBarHelper.error("Please login to view applied jobs");
        return;
      }

      AppLogger.d("📋 Fetching applied jobs for userId: $userId");

      final response = await HttpHelper.getData(
        endpoint: '${API.getAppliedJobs}$userId',
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      AppLogger.d("📋 Applied jobs response status: ${response.statusCode}");
      AppLogger.d("📋 Applied jobs response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        appliedJobs.value = data.map((e) => AppliedJob.fromJson(e)).toList();
        AppLogger.d("✅ Fetched ${appliedJobs.length} applied jobs");
      } else {
        AppLogger.d("❌ Failed to fetch applied jobs: ${response.statusCode}");
        SnackBarHelper.error("Failed to load applied jobs");
      }
    } catch (e) {
      AppLogger.d("❌ Error fetching applied jobs: $e");
      SnackBarHelper.error("Failed to load applied jobs: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// Get filtered applied jobs based on search and filter
  List<AppliedJob> get filteredAppliedJobs {
    List<AppliedJob> filtered = List.from(appliedJobs);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((job) {
        return job.jobRole.toLowerCase().contains(query) ||
            job.jobCity.toLowerCase().contains(query) ||
            job.jobType.toLowerCase().contains(query) ||
            job.jobDescription.toLowerCase().contains(query);
      }).toList();
    }

    // Apply status filter
    if (selectedFilter.value != 'All') {
      filtered = filtered.where((job) {
        return job.status.toLowerCase() == selectedFilter.value.toLowerCase();
      }).toList();
    }

    return filtered;
  }

  /// Refresh applied jobs
  Future<void> refreshAppliedJobs() async {
    await fetchAppliedJobs();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Update filter
  void updateFilter(String filter) {
    selectedFilter.value = filter;
  }
}

