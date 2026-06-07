import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/job_model.dart';
import '../../models/job_application_model.dart';
import '../../models/job_stats_model.dart';
import '../../models/hired_professional_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

/// Employer (Company/Business) jobs controller. A 1:1 mirror of the FE
/// `jobsAPI` employer + hired-professionals endpoints
/// (`wheelboard-fe/src/lib/api.ts`).
///
/// All requests are JSON and derive the employer from the auth token — no
/// `userId`/`modifiedUserId` is ever sent (the backend rejects extra fields).
class JobController extends GetxController {
  var isLoading = false.obs;
  var jobs = <JobModel>[].obs;
  var stats = Rxn<JobStats>();

  // Applications
  var isApplicationsLoading = false.obs;
  var applications = <JobApplication>[].obs; // filtered view
  var allApplications = <JobApplication>[].obs; // unfiltered
  var applicationCounts = <String, int>{}.obs; // jobId -> count
  var applicationStatusFilter = 'All'.obs; // inbox status filter
  final Map<String, String> _applicationJobMap = {}; // applicationId -> jobId

  // Hired professionals
  var isHiredLoading = false.obs;
  var hiredProfessionals = <HiredProfessional>[].obs;
  var hiredStats = Rxn<HiredProfessionalsStats>();

  @override
  void onInit() {
    super.onInit();
    fetchJobs();
  }

  /// GET /jobs/my-jobs — paginated `{jobs,total,page,totalPages}`.
  /// The response embeds each job's `applications[]`, so counts/aggregates are
  /// derived locally without extra requests.
  Future<void> fetchJobs({Map<String, dynamic>? filters}) async {
    try {
      isLoading.value = true;

      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.jobs.myJobs,
        queryParameters: filters,
      );

      final jobsList = data['jobs'] as List<dynamic>? ?? [];
      jobs.value = jobsList
          .whereType<Map<String, dynamic>>()
          .map(JobModel.fromJson)
          .toList();
      AppLogger.d("✅ Fetched ${jobs.length} jobs");

      _rebuildApplicationsFromJobs();
      fetchStats();
    } on dio.DioException catch (e) {
      AppLogger.e("❌ Error fetching jobs: $e");
      SnackBarHelper.error(_msg(e, fallback: 'Failed to load jobs'));
    } catch (e) {
      AppLogger.e("❌ Error fetching jobs: $e");
      SnackBarHelper.error("Failed to load jobs: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// GET /jobs/my-jobs/stats
  Future<void> fetchStats() async {
    try {
      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.jobs.myJobStats,
      );
      stats.value = JobStats.fromJson(data);
    } catch (e) {
      AppLogger.d("ℹ️ Failed to fetch job stats: $e");
    }
  }

  /// POST /jobs — create a job posting (CreateJobDto).
  Future<bool> createJob({
    required String title,
    required String city,
    required String type, // Driver | Technician | Helper
    required String salary,
    required String description,
    required int openings,
    String? location,
    String? state,
    int? salaryMin,
    int? salaryMax,
    List<String>? requirements,
    List<String>? benefits,
    List<String>? skills,
    String? image,
    File? imageFile,
    String? duration,
    bool? urgent,
    String? expiresAt,
  }) async {
    try {
      isLoading.value = true;

      String? imageUrl = image;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile) ?? image;
      }

      final payload = <String, dynamic>{
        'title': title,
        'location': location ?? city,
        'city': city,
        'type': type,
        'salary': salary,
        'description': description,
        'openings': openings,
        if (state != null && state.isNotEmpty) 'state': state,
        if (salaryMin != null) 'salaryMin': salaryMin,
        if (salaryMax != null) 'salaryMax': salaryMax,
        if (requirements != null) 'requirements': requirements,
        if (benefits != null) 'benefits': benefits,
        if (skills != null) 'skills': skills,
        if (imageUrl != null && imageUrl.isNotEmpty) 'image': imageUrl,
        if (duration != null && duration.isNotEmpty) 'duration': duration,
        if (urgent != null) 'urgent': urgent,
        if (expiresAt != null && expiresAt.isNotEmpty) 'expiresAt': expiresAt,
      };

      await ApiClient.instance.post<dynamic>(
        ApiEndpoints.jobs.create,
        data: payload,
      );

      SnackBarHelper.success("Job posted successfully!");
      await fetchJobs();
      return true;
    } on dio.DioException catch (e) {
      AppLogger.e("❌ Error creating job: $e");
      SnackBarHelper.error(_msg(e, fallback: 'Failed to post job'));
      return false;
    } catch (e) {
      AppLogger.e("❌ Error creating job: $e");
      SnackBarHelper.error("Failed to post job: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// PUT /jobs/my-jobs/:id — update a job (UpdateJobDto, includes `status`).
  Future<bool> updateJob({
    required String jobId,
    String? title,
    String? city,
    String? type,
    String? salary,
    String? description,
    int? openings,
    String? location,
    String? state,
    int? salaryMin,
    int? salaryMax,
    List<String>? requirements,
    List<String>? benefits,
    List<String>? skills,
    String? image,
    File? imageFile,
    String? duration,
    bool? urgent,
    String? expiresAt,
    String? status, // Active | Paused | Closed
  }) async {
    try {
      isLoading.value = true;

      String? imageUrl = image;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile) ?? image;
      }

      final payload = <String, dynamic>{
        if (title != null) 'title': title,
        if (location != null) 'location': location,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (type != null) 'type': type,
        if (salary != null) 'salary': salary,
        if (salaryMin != null) 'salaryMin': salaryMin,
        if (salaryMax != null) 'salaryMax': salaryMax,
        if (description != null) 'description': description,
        if (requirements != null) 'requirements': requirements,
        if (benefits != null) 'benefits': benefits,
        if (skills != null) 'skills': skills,
        if (imageUrl != null) 'image': imageUrl,
        if (openings != null) 'openings': openings,
        if (duration != null) 'duration': duration,
        if (urgent != null) 'urgent': urgent,
        if (expiresAt != null) 'expiresAt': expiresAt,
        if (status != null) 'status': status,
      };

      await ApiClient.instance.put<dynamic>(
        ApiEndpoints.jobs.updateJob(jobId),
        data: payload,
      );

      SnackBarHelper.success("Job updated successfully!");
      await fetchJobs();
      return true;
    } on dio.DioException catch (e) {
      AppLogger.e("❌ Error updating job: $e");
      SnackBarHelper.error(_msg(e, fallback: 'Failed to update job'));
      return false;
    } catch (e) {
      AppLogger.e("❌ Error updating job: $e");
      SnackBarHelper.error("Failed to update job: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// PUT /jobs/my-jobs/:id — quick status change (Active/Paused/Closed).
  Future<bool> updateJobStatus(String jobId, String status) =>
      updateJob(jobId: jobId, status: status);

  /// DELETE /jobs/my-jobs/:id
  Future<bool> deleteJob(String jobId) async {
    try {
      await ApiClient.instance.delete<dynamic>(
        ApiEndpoints.jobs.deleteJob(jobId),
      );
      jobs.removeWhere((j) => j.id == jobId);
      SnackBarHelper.success("Job deleted");
      fetchStats();
      return true;
    } on dio.DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to delete job'));
      return false;
    } catch (e) {
      SnackBarHelper.error("Failed to delete job: $e");
      return false;
    }
  }

  /// GET /jobs/my-jobs/:id/applications
  Future<void> fetchJobApplications(String jobId) async {
    try {
      isApplicationsLoading.value = true;
      final data = await ApiClient.instance.get<List<dynamic>>(
        ApiEndpoints.jobs.applications(jobId),
      );
      final fetched = data
          .whereType<Map<String, dynamic>>()
          .map(JobApplication.fromJson)
          .toList();
      for (final a in fetched) {
        _applicationJobMap[a.id] = jobId;
      }
      allApplications.value = fetched;
      applications.value = fetched;
    } on dio.DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to load applications'));
      allApplications.clear();
      applications.clear();
    } catch (e) {
      SnackBarHelper.error("Failed to load applications: $e");
      allApplications.clear();
      applications.clear();
    } finally {
      isApplicationsLoading.value = false;
    }
  }

  /// Aggregate every application across all of the employer's jobs. Uses the
  /// applications embedded in the `my-jobs` response (no extra requests).
  Future<void> fetchAllJobApplications() async {
    isApplicationsLoading.value = true;
    try {
      if (jobs.isEmpty) await fetchJobs();
      _rebuildApplicationsFromJobs();
    } finally {
      isApplicationsLoading.value = false;
    }
  }

  void _rebuildApplicationsFromJobs() {
    final all = <JobApplication>[];
    final counts = <String, int>{};
    _applicationJobMap.clear();
    for (final job in jobs) {
      counts[job.id] = job.applications.length;
      for (final a in job.applications) {
        _applicationJobMap[a.id] = job.id;
        all.add(a);
      }
    }
    allApplications.value = all;
    applications.value = all;
    applicationCounts.value = counts;
  }

  /// PATCH /jobs/my-jobs/:jobId/applications/:applicationId
  /// `status` ∈ pending | reviewed | shortlisted | rejected | hired.
  Future<bool> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? jobId,
    String? notes,
  }) async {
    final resolvedJobId = jobId ?? _applicationJobMap[applicationId];
    if (resolvedJobId == null || resolvedJobId.isEmpty) {
      SnackBarHelper.error("Could not determine job for this application");
      return false;
    }

    try {
      await ApiClient.instance.patch<dynamic>(
        ApiEndpoints.jobs.updateApplication(resolvedJobId, applicationId),
        data: {
          'status': status,
          if (notes != null) 'notes': notes,
        },
      );

      // Update local state.
      _patchApplicationStatus(applicationId, status);
      SnackBarHelper.success("Application marked as $status");
      return true;
    } on dio.DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to update application'));
      return false;
    } catch (e) {
      SnackBarHelper.error("Failed to update application: $e");
      return false;
    }
  }

  void _patchApplicationStatus(String applicationId, String status) {
    void patch(RxList<JobApplication> list) {
      final i = list.indexWhere((a) => a.id == applicationId);
      if (i != -1) {
        list[i] = list[i].copyWith(status: status);
        list.refresh();
      }
    }

    patch(applications);
    patch(allApplications);
  }

  /// GET /jobs/my-jobs/:jobId/applications/:applicationId/profile
  Future<Map<String, dynamic>?> getApplicantProfile(
    String jobId,
    String applicationId,
  ) async {
    try {
      return await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.jobs.applicantProfile(jobId, applicationId),
      );
    } on dio.DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to load profile'));
      return null;
    } catch (e) {
      SnackBarHelper.error("Failed to load profile: $e");
      return null;
    }
  }

  /// Filter the applications view by status (pending/reviewed/.../hired).
  void filterApplications({String? status}) {
    if (status == null || status.isEmpty || status == 'All') {
      applications.value = List<JobApplication>.from(allApplications);
      return;
    }
    final s = status.trim().toLowerCase();
    applications.value =
        allApplications.where((a) => a.status == s).toList();
  }

  int getApplicationCount(String jobId) => applicationCounts[jobId] ?? 0;

  /// The job an application belongs to (resolved during fetch). Used by the
  /// applications inbox when viewing the aggregated list.
  String? jobIdForApplication(String applicationId) =>
      _applicationJobMap[applicationId];

  // ── Hired professionals ───────────────────────────────────────────────────

  /// GET /jobs/hired-professionals
  Future<void> fetchHiredProfessionals({
    String? jobId,
    String? status,
    String? search,
  }) async {
    try {
      isHiredLoading.value = true;
      final params = <String, dynamic>{
        if (jobId != null && jobId.isNotEmpty) 'jobId': jobId,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      };
      final data = await ApiClient.instance.get<List<dynamic>>(
        ApiEndpoints.jobs.hiredProfessionals,
        queryParameters: params.isEmpty ? null : params,
      );
      hiredProfessionals.value = data
          .whereType<Map<String, dynamic>>()
          .map(HiredProfessional.fromJson)
          .toList();
      fetchHiredStats();
    } on dio.DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to load hired professionals'));
      hiredProfessionals.clear();
    } catch (e) {
      SnackBarHelper.error("Failed to load hired professionals: $e");
      hiredProfessionals.clear();
    } finally {
      isHiredLoading.value = false;
    }
  }

  /// GET /jobs/hired-professionals/stats
  Future<void> fetchHiredStats() async {
    try {
      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.jobs.hiredProfessionalsStats,
      );
      hiredStats.value = HiredProfessionalsStats.fromJson(data);
    } catch (e) {
      AppLogger.d("ℹ️ Failed to fetch hired stats: $e");
    }
  }

  /// PATCH /jobs/hired-professionals/:professionalId/:jobId
  Future<bool> updateHiredStatus({
    required String professionalId,
    required String jobId,
    required String status, // onboarding | active | completed
  }) async {
    try {
      await ApiClient.instance.patch<dynamic>(
        ApiEndpoints.jobs.hiredProfessionalStatus(professionalId, jobId),
        data: {'status': status},
      );
      SnackBarHelper.success("Status updated to $status");
      await fetchHiredProfessionals();
      return true;
    } on dio.DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to update status'));
      return false;
    } catch (e) {
      SnackBarHelper.error("Failed to update status: $e");
      return false;
    }
  }

  /// DELETE /jobs/hired-professionals/:professionalId/:jobId
  Future<bool> removeHiredProfessional({
    required String professionalId,
    required String jobId,
  }) async {
    try {
      await ApiClient.instance.delete<dynamic>(
        ApiEndpoints.jobs.hiredProfessionalStatus(professionalId, jobId),
      );
      hiredProfessionals.removeWhere(
        (h) => h.id == professionalId && h.hiredJobInfo?.jobId == jobId,
      );
      SnackBarHelper.success("Professional removed from hired list");
      fetchHiredStats();
      return true;
    } on dio.DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to remove professional'));
      return false;
    } catch (e) {
      SnackBarHelper.error("Failed to remove professional: $e");
      return false;
    }
  }

  Future<void> refreshJobs() => fetchJobs();

  /// Upload a picked image and return its hosted URL (reuses the shared
  /// `/feeds/upload-image` host; jobs store the resulting URL in `image`).
  Future<String?> _uploadImage(File file) async {
    final bytes = await file.readAsBytes();
    final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    final data = await ApiClient.instance.post<Map<String, dynamic>>(
      ApiEndpoints.feeds.uploadImage,
      data: {'image': dataUrl},
    );
    return data['url']?.toString();
  }

  String _msg(dio.DioException e, {String fallback = 'Something went wrong'}) {
    if (e.error is ApiException) {
      return (e.error as ApiException).message;
    }
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List) {
        final parts = msg.whereType<String>().toList();
        if (parts.isNotEmpty) return parts.join(' ');
      }
    }
    return fallback;
  }
}
