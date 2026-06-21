import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import '../../models/job_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/kyc_helper.dart';
import '../../utils/app_logger.dart';

/// Professional jobs controller — a 1:1 mirror of the FE `jobsAPI` professional
/// endpoints (`browse`, `getJobById`, `apply`, `withdraw`, `save`, `unsave`).
///
/// Jobs have no "like": the heart is a bookmark backed by save/unsave, and
/// saved state is derived from the job's `savedBy[]`.
class OpenJobsController extends GetxController {
  var isLoading = false.obs;
  var openJobs = <JobModel>[].obs;
  var applyingJobId = ''.obs;
  var savingJobId = ''.obs;

  /// Map of `jobId → application status`
  /// (`pending | reviewed | shortlisted | hired | rejected`). Mirrors the web
  /// search page's `applicationStatus`, built from GET /jobs/my-applications, so
  /// job cards can show a granular badge (Applied / Viewed / Shortlisted / …)
  /// instead of a plain "Applied".
  var applicationStatus = <String, String>{}.obs;

  var page = 1.obs;
  var totalPages = 1.obs;
  var total = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOpenJobs();
  }

  /// GET /jobs/browse — paginated `{jobs,total,page,totalPages}`.
  Future<void> fetchOpenJobs({Map<String, dynamic>? filters}) async {
    try {
      isLoading.value = true;

      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.jobs.browse,
        queryParameters: filters,
      );

      final jobsList = data['jobs'] as List<dynamic>? ?? [];
      final userId = AuthService.to.currentUserId;
      openJobs.value = jobsList
          .whereType<Map<String, dynamic>>()
          .map(JobModel.fromJson)
          .map((j) => j.copyWith(
                isSaved: j.isSavedBy(userId),
                isApplied: j.isAppliedBy(userId),
              ))
          .toList();
      page.value = (data['page'] as num?)?.toInt() ?? 1;
      totalPages.value = (data['totalPages'] as num?)?.toInt() ?? 1;
      total.value = (data['total'] as num?)?.toInt() ?? openJobs.length;
      AppLogger.d("✅ Fetched ${openJobs.length} open jobs");
    } on DioException catch (e) {
      AppLogger.e("❌ Failed to fetch open jobs: ${_msg(e)}");
      SnackBarHelper.error(_msg(e, fallback: 'Failed to load jobs'));
      openJobs.clear();
    } catch (e) {
      AppLogger.e("❌ Error fetching open jobs: $e");
      SnackBarHelper.error("Failed to load jobs: $e");
      openJobs.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// GET /jobs/my-applications — build a `jobId → status` map for status badges.
  /// 1:1 with the web search page's `fetchMyApplications` (`getMyApplications`).
  Future<void> fetchMyApplicationStatuses() async {
    try {
      if (AuthService.to.currentUserId.isEmpty) return;
      final data = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.jobs.myApplications,
      );
      final list = data is Map
          ? (data['jobs'] ?? data['applications'] ?? data['data'] ?? const [])
          : data;
      final map = <String, String>{};
      if (list is List) {
        for (final item in list.whereType<Map<String, dynamic>>()) {
          final job = JobModel.fromJson(item);
          final status = job.myApplication?.status;
          if (job.id.isNotEmpty && status != null && status.isNotEmpty) {
            map[job.id] = status;
          }
        }
      }
      applicationStatus.value = map;
      AppLogger.d("✅ Loaded ${map.length} application statuses");
    } catch (e) {
      AppLogger.d("⚠️ Could not load application statuses: $e");
    }
  }

  /// GET /jobs/:id (optionally increments the view counter).
  Future<JobModel?> getJobById(String jobId, {bool incrementView = false}) async {
    try {
      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.jobs.jobDetails(jobId),
        queryParameters: incrementView ? {'incrementView': true} : null,
      );
      final userId = AuthService.to.currentUserId;
      final job = JobModel.fromJson(data);
      return job.copyWith(isSaved: job.isSavedBy(userId));
    } on DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to load job'));
      return null;
    } catch (e) {
      SnackBarHelper.error("Failed to load job: $e");
      return null;
    }
  }

  /// POST /jobs/:id/apply — ApplyJobDto (no userId).
  Future<bool> applyForJob(
    String jobId, {
    String? coverLetter,
    String? experience,
    String? expectedSalary,
    String? resume,
    String? availability,
  }) async {
    try {
      applyingJobId.value = jobId;

      if (AuthService.to.currentUserId.isEmpty) {
        SnackBarHelper.error("Please login to apply for jobs");
        return false;
      }

      // KYC gate (existing app UX).
      if (!KYCHelper.checkAndShowKYCDialog()) return false;

      await ApiClient.instance.post<dynamic>(
        ApiEndpoints.jobs.apply(jobId),
        data: {
          if (coverLetter != null && coverLetter.isNotEmpty)
            'coverLetter': coverLetter,
          if (experience != null && experience.isNotEmpty)
            'experience': experience,
          if (expectedSalary != null && expectedSalary.isNotEmpty)
            'expectedSalary': expectedSalary,
          if (resume != null && resume.isNotEmpty) 'resume': resume,
          if (availability != null && availability.isNotEmpty)
            'availability': availability,
        },
      );

      SnackBarHelper.success("Job application submitted successfully!");
      // Optimistically mark applied (web sets status → 'pending') so the search
      // page badge flips immediately, then refresh the authoritative state.
      applicationStatus[jobId] = 'pending';
      applicationStatus.refresh();
      // Refresh so the job reflects the applied state.
      await fetchOpenJobs();
      return true;
    } on DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to apply for job'));
      return false;
    } catch (e) {
      SnackBarHelper.error("Failed to apply for job: $e");
      return false;
    } finally {
      applyingJobId.value = '';
    }
  }

  /// DELETE /jobs/:id/withdraw
  Future<bool> withdrawApplication(String jobId) async {
    try {
      await ApiClient.instance.delete<dynamic>(
        ApiEndpoints.jobs.withdraw(jobId),
      );
      SnackBarHelper.success("Application withdrawn");
      await fetchOpenJobs();
      return true;
    } on DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to withdraw'));
      return false;
    } catch (e) {
      SnackBarHelper.error("Failed to withdraw: $e");
      return false;
    }
  }

  /// Toggle bookmark: POST /jobs/:id/save or DELETE /jobs/:id/unsave.
  Future<bool> toggleSave(String jobId) async {
    final index = openJobs.indexWhere((j) => j.id == jobId);
    final currentlySaved = index != -1 && openJobs[index].isSaved;
    return currentlySaved ? unsaveJob(jobId) : saveJob(jobId);
  }

  /// POST /jobs/:id/save
  Future<bool> saveJob(String jobId) async {
    try {
      savingJobId.value = jobId;
      await ApiClient.instance.post<dynamic>(ApiEndpoints.jobs.saveJob(jobId));
      _setSaved(jobId, true);
      SnackBarHelper.success("Job saved");
      return true;
    } on DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to save job'));
      return false;
    } catch (e) {
      SnackBarHelper.error("Failed to save job: $e");
      return false;
    } finally {
      savingJobId.value = '';
    }
  }

  /// DELETE /jobs/:id/unsave
  Future<bool> unsaveJob(String jobId) async {
    try {
      savingJobId.value = jobId;
      await ApiClient.instance.delete<dynamic>(
        ApiEndpoints.jobs.unsaveJob(jobId),
      );
      _setSaved(jobId, false);
      SnackBarHelper.success("Removed from saved");
      return true;
    } on DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to unsave job'));
      return false;
    } catch (e) {
      SnackBarHelper.error("Failed to unsave job: $e");
      return false;
    } finally {
      savingJobId.value = '';
    }
  }

  void _setSaved(String jobId, bool saved) {
    final index = openJobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      openJobs[index] = openJobs[index].copyWith(isSaved: saved);
      openJobs.refresh();
    }
  }

  Future<void> refreshOpenJobs() => fetchOpenJobs();

  bool isApplying(String jobId) => applyingJobId.value == jobId;
  bool isSaving(String jobId) => savingJobId.value == jobId;

  bool isSaved(String jobId) {
    final i = openJobs.indexWhere((j) => j.id == jobId);
    return i != -1 && openJobs[i].isSaved;
  }

  String _msg(DioException e, {String fallback = 'Something went wrong'}) {
    return e.error is ApiException
        ? (e.error as ApiException).message
        : fallback;
  }
}
