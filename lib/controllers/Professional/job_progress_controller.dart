import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/job_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

/// Professional "job progress" controller — applied jobs and saved jobs.
///
/// Mirrors the FE `jobsAPI.getMyApplications` / `getMySavedJobs`
/// (`{jobs,total}`). Applied jobs carry the professional's own application as
/// `job.myApplication`. The user is derived from the auth token (no params).
class JobProgressController extends GetxController {
  var isLoading = false.obs;
  var isSavedLoading = false.obs;
  var appliedJobs = <JobModel>[].obs;
  var savedJobs = <JobModel>[].obs;
  var searchQuery = ''.obs;
  var selectedFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAppliedJobs();
    fetchSavedJobs();
  }

  /// GET /jobs/my-applications → `{jobs,total}` (each job has `myApplication`).
  Future<void> fetchAppliedJobs() async {
    try {
      isLoading.value = true;
      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.jobs.myApplications,
      );
      final jobsList = data['jobs'] as List<dynamic>? ?? [];
      appliedJobs.value = jobsList
          .whereType<Map<String, dynamic>>()
          .map(JobModel.fromJson)
          .toList();
      AppLogger.d("✅ Fetched ${appliedJobs.length} applied jobs");
    } on DioException catch (e) {
      AppLogger.e("❌ Failed to fetch applied jobs: ${_msg(e)}");
      SnackBarHelper.error(_msg(e, fallback: 'Failed to load applied jobs'));
      appliedJobs.clear();
    } catch (e) {
      AppLogger.e("❌ Error fetching applied jobs: $e");
      SnackBarHelper.error("Failed to load applied jobs: $e");
      appliedJobs.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// GET /jobs/my-saved → `{jobs,total}`.
  Future<void> fetchSavedJobs() async {
    try {
      isSavedLoading.value = true;
      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.jobs.mySavedJobs,
      );
      final jobsList = data['jobs'] as List<dynamic>? ?? [];
      savedJobs.value = jobsList
          .whereType<Map<String, dynamic>>()
          .map(JobModel.fromJson)
          .map((j) => j.copyWith(isSaved: true))
          .toList();
    } on DioException catch (e) {
      AppLogger.e("❌ Failed to fetch saved jobs: ${_msg(e)}");
      savedJobs.clear();
    } catch (e) {
      AppLogger.e("❌ Error fetching saved jobs: $e");
      savedJobs.clear();
    } finally {
      isSavedLoading.value = false;
    }
  }

  /// DELETE /jobs/:id/withdraw
  Future<bool> withdrawApplication(String jobId) async {
    try {
      await ApiClient.instance.delete<dynamic>(
        ApiEndpoints.jobs.withdraw(jobId),
      );
      appliedJobs.removeWhere((j) => j.id == jobId);
      SnackBarHelper.success("Application withdrawn");
      return true;
    } on DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to withdraw'));
      return false;
    } catch (e) {
      SnackBarHelper.error("Failed to withdraw: $e");
      return false;
    }
  }

  /// DELETE /jobs/:id/unsave
  Future<bool> unsaveJob(String jobId) async {
    try {
      await ApiClient.instance.delete<dynamic>(
        ApiEndpoints.jobs.unsaveJob(jobId),
      );
      savedJobs.removeWhere((j) => j.id == jobId);
      SnackBarHelper.success("Removed from saved");
      return true;
    } on DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to unsave job'));
      return false;
    } catch (e) {
      SnackBarHelper.error("Failed to unsave job: $e");
      return false;
    }
  }

  /// Applied jobs filtered by the search query and the selected application
  /// status (All / pending / reviewed / shortlisted / rejected / hired).
  List<JobModel> get filteredAppliedJobs {
    List<JobModel> filtered = List.from(appliedJobs);

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      filtered = filtered.where((job) {
        return job.title.toLowerCase().contains(q) ||
            job.city.toLowerCase().contains(q) ||
            job.type.toLowerCase().contains(q) ||
            job.description.toLowerCase().contains(q);
      }).toList();
    }

    if (selectedFilter.value != 'All') {
      final f = selectedFilter.value.toLowerCase();
      filtered = filtered
          .where((job) => (job.myApplication?.status ?? '') == f)
          .toList();
    }

    return filtered;
  }

  Future<void> refreshAppliedJobs() async {
    await fetchAppliedJobs();
    await fetchSavedJobs();
  }

  void updateSearchQuery(String query) => searchQuery.value = query;
  void updateFilter(String filter) => selectedFilter.value = filter;

  String _msg(DioException e, {String fallback = 'Something went wrong'}) {
    return e.error is ApiException
        ? (e.error as ApiException).message
        : fallback;
  }
}
