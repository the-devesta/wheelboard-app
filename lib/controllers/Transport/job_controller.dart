import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:wheelboard/utils/error_handler.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../models/job_model.dart';
import '../../models/job_application_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

class JobController extends GetxController {
  var isLoading = false.obs;
  var jobs = <JobModel>[].obs;

  // Job Applications
  var isApplicationsLoading = false.obs;
  var applications = <JobApplicationModel>[].obs;
  var allApplications =
      <JobApplicationModel>[].obs; // Store all applications for filtering
  var applicationCounts =
      <String, int>{}.obs; // Map of jobId -> application count

  @override
  void onInit() {
    super.onInit();
    fetchJobs();
  }

  /// Fetch jobs for current user
  Future<void> fetchJobs() async {
    try {
      isLoading.value = true;

      final authService = AuthService.to;
      final userId = authService.currentUserId;
      final token = authService.currentToken;

      if (userId.isEmpty) {
        AppLogger.d("⚠️ User not logged in, cannot fetch jobs");
        return;
      }

      AppLogger.d("💼 Fetching jobs for userId: $userId");

      final response = await HttpHelper.getData(
        endpoint: '${API.getJobList}$userId',
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      AppLogger.d("💼 Jobs response status: ${response.statusCode}");
      AppLogger.d("💼 Jobs response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        jobs.value = data.map((e) => JobModel.fromJson(e)).toList();
        AppLogger.d("✅ Fetched ${jobs.length} jobs");

        // Fetch application counts for each job
        _fetchApplicationCounts();
      } else {
        AppLogger.d("❌ Failed to fetch jobs: ${response.statusCode}");
        SnackBarHelper.error("Failed to load jobs");
      }
    } catch (e) {
      AppLogger.d("❌ Error fetching jobs: $e");
      SnackBarHelper.error("Failed to load jobs: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// Add a new job
  Future<bool> addJob({
    required String role,
    required String jobDuration,
    required int openings,
    required int salary,
    required String city,
    required String jobType,
    required String description,
    List<File>? images, // Images are now optional
  }) async {
    try {
      isLoading.value = true;

      final authService = AuthService.to;
      final userId = authService.currentUserId;

      if (userId.isEmpty) {
        SnackBarHelper.error("Please login to post jobs");
        return false;
      }

      AppLogger.d("💼 Adding new job...");
      AppLogger.d("💼 UserId: $userId");
      AppLogger.d("💼 Role: $role");
      AppLogger.d("💼 Images: ${images?.length ?? 0}");

      // Prepare fields for multipart
      final fields = <String, String?>{
        'UserId': userId,
        'Role': role,
        'JobDuration': jobDuration,
        'Openings': openings.toString(),
        'Salary': salary.toString(),
        'City': city,
        'JobType': jobType,
        'Description': description,
      };

      // Send multipart request (images are optional now)
      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.addJob,
        fields: fields,
        files: images ?? [], // Pass empty list if no images
        fieldKey: 'Images', // API expects 'Images' as field name
        headers: {'Accept': '*/*'},
      );

      AppLogger.d("💼 Add job response status: ${streamedResponse.statusCode}");

      final responseBody = await streamedResponse.stream.bytesToString();
      AppLogger.d("💼 Add job response body: $responseBody");

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        AppLogger.d("✅ Successfully added job");
        SnackBarHelper.success("Job posted successfully!");
        await fetchJobs(); // Refresh jobs list
        return true;
      } else {
        AppLogger.d("❌ Failed to add job: ${streamedResponse.statusCode}");
        // Use ErrorHandler for proper backend error message
        final errorMsg = ErrorHandler.parseError(
          responseBody,
          statusCode: streamedResponse.statusCode,
        );
        SnackBarHelper.error(errorMsg);
        return false;
      }
    } catch (e) {
      AppLogger.d("❌ Error adding job: $e");
      final errorMsg = ErrorHandler.handleNetworkError(e);
      SnackBarHelper.error(errorMsg);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an existing job
  Future<bool> updateJob({
    required String jobId,
    required String role,
    required String jobDuration,
    required int openings,
    required int salary,
    required String city,
    required String jobType,
    required String description,
    List<File>? newImages,
  }) async {
    try {
      isLoading.value = true;

      final authService = AuthService.to;
      final userId = authService.currentUserId;

      if (userId.isEmpty) {
        SnackBarHelper.error("Please login to update jobs");
        return false;
      }

      AppLogger.d("💼 Updating job: $jobId");
      AppLogger.d("💼 UserId: $userId");

      // Prepare fields for multipart
      final fields = <String, String?>{
        'JobId': jobId,
        'UserId': userId,
        'Role': role,
        'JobDuration': jobDuration,
        'Openings': openings.toString(),
        'Salary': salary.toString(),
        'City': city,
        'JobType': jobType,
        'Description': description,
      };

      // If new images are provided, add them
      final imagesToUpload = newImages ?? [];

      // Send multipart request with POST method (API expects POST, not PUT)
      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.updateJob,
        fields: fields,
        files: imagesToUpload,
        fieldKey: 'NewImages', // API expects 'NewImages' for update
        headers: {'Accept': '*/*'},
        method: 'POST',
      );

      AppLogger.d(
        "💼 Update job response status: ${streamedResponse.statusCode}",
      );

      final responseBody = await streamedResponse.stream.bytesToString();
      AppLogger.d("💼 Update job response body: $responseBody");

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        AppLogger.d("✅ Successfully updated job");
        SnackBarHelper.success("Job updated successfully!");
        await fetchJobs(); // Refresh jobs list
        return true;
      } else {
        AppLogger.d("❌ Failed to update job: ${streamedResponse.statusCode}");
        AppLogger.d("❌ Response body: $responseBody");

        // Better error message
        String errorMsg = "Failed to update job";
        if (streamedResponse.statusCode == 405) {
          errorMsg = "Update method not allowed. Please try again.";
        } else if (streamedResponse.statusCode == 400) {
          errorMsg = "Invalid job data. Please check all fields.";
        } else if (streamedResponse.statusCode == 404) {
          errorMsg = "Job not found. It may have been deleted.";
        }

        SnackBarHelper.error(errorMsg);
        return false;
      }
    } catch (e) {
      AppLogger.d("❌ Error updating job: $e");
      SnackBarHelper.error("Failed to update job: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh jobs list
  Future<void> refreshJobs() async {
    await fetchJobs();
  }

  /// Toggle like on a job
  Future<bool> toggleJobLike(String jobId) async {
    try {
      final authService = AuthService.to;
      final token = authService.currentToken;
      final userId = authService.currentUserId;

      if (token.isEmpty || userId.isEmpty) {
        SnackBarHelper.error("Please login to like jobs");
        return false;
      }

      AppLogger.d("👍 Toggling like for job: $jobId");
      AppLogger.d("👍 User ID: $userId");

      // 🔧 FIX: Send jobId and userId as query parameters (not body)
      final endpoint = '${API.toggleJobLike}?jobId=$jobId&userId=$userId';

      final response = await HttpHelper.postData(
        endpoint: endpoint,
        data: {}, // Empty body
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      AppLogger.d("👍 Toggle like response status: ${response.statusCode}");
      AppLogger.d("👍 Toggle like response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse new response format
        final responseData = json.decode(response.body);
        final isLiked = responseData['data']['isLiked'] ?? false;
        final likeCount = responseData['data']['likeCount'] ?? 0;

        final jobIndex = jobs.indexWhere((job) => job.jobId == jobId);
        if (jobIndex != -1) {
          // Update job with actual values from API
          final updatedJob = jobs[jobIndex].copyWith(
            likeCount: likeCount,
            isLiked: isLiked,
          );

          // Update the job in the list - create new list to trigger GetX reactivity
          final updatedJobs = List<JobModel>.from(jobs);
          updatedJobs[jobIndex] = updatedJob;
          jobs.value = updatedJobs;
          jobs.refresh(); // Force refresh to ensure UI updates

          final message =
              responseData['message'] ??
              (isLiked ? 'Job liked' : 'Job unliked');
          AppLogger.d("✅ $message");
        }

        // 🔧 FIX: Refresh jobs list to get updated isLiked from backend
        // This ensures like state persists even after screen refresh
        await fetchJobs();

        return true;
      } else {
        AppLogger.d("❌ Failed to toggle like: ${response.statusCode}");
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              "Failed to toggle like";
          SnackBarHelper.error(errorMessage);
        } catch (e) {
          SnackBarHelper.error("Failed to toggle like");
        }
        return false;
      }
    } catch (e) {
      AppLogger.d("❌ Error toggling like: $e");
      SnackBarHelper.error("Failed to toggle like: ${e.toString()}");
      return false;
    }
  }

  /// Fetch job applications for a specific job
  Future<void> fetchJobApplications(String jobId) async {
    try {
      isApplicationsLoading.value = true;

      final authService = AuthService.to;
      final token = authService.currentToken;

      AppLogger.d("📋 Fetching applications for jobId: $jobId");

      final response = await HttpHelper.getData(
        endpoint: '${API.getJobApplications}$jobId',
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      AppLogger.d("📋 Applications response status: ${response.statusCode}");
      AppLogger.d("📋 Applications response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final fetchedApplications = data
            .map((e) => JobApplicationModel.fromJson(e))
            .toList();

        allApplications.value = fetchedApplications;
        applications.value = fetchedApplications;
        AppLogger.d("✅ Fetched ${applications.length} applications");
      } else {
        AppLogger.d("❌ Failed to fetch applications: ${response.statusCode}");
        SnackBarHelper.error("Failed to load applications");
        allApplications.value = [];
        applications.value = [];
      }
    } catch (e) {
      AppLogger.d("❌ Error fetching applications: $e");
      SnackBarHelper.error("Failed to load applications: ${e.toString()}");
      allApplications.value = [];
      applications.value = [];
    } finally {
      isApplicationsLoading.value = false;
    }
  }

  /// Fetch applications for all jobs
  Future<void> fetchAllJobApplications() async {
    try {
      isApplicationsLoading.value = true;

      final authService = AuthService.to;
      final token = authService.currentToken;

      // First fetch all jobs
      await fetchJobs();

      if (jobs.isEmpty) {
        allApplications.value = [];
        applications.value = [];
        isApplicationsLoading.value = false;
        return;
      }

      AppLogger.d("📋 Fetching applications for all ${jobs.length} jobs");

      final List<JobApplicationModel> allApps = [];

      // Fetch applications for each job
      for (var job in jobs) {
        try {
          final response = await HttpHelper.getData(
            endpoint: '${API.getJobApplications}${job.jobId}',
            headers: {
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
              'Accept': '*/*',
            },
          );

          if (response.statusCode == 200) {
            final List data = json.decode(response.body);
            final fetchedApplications = data
                .map((e) => JobApplicationModel.fromJson(e))
                .toList();
            allApps.addAll(fetchedApplications);
            AppLogger.d(
              "✅ Fetched ${fetchedApplications.length} applications for job: ${job.role}",
            );
          } else {
            AppLogger.d(
              "⚠️ Failed to fetch applications for job ${job.jobId}: ${response.statusCode}",
            );
          }
        } catch (e) {
          AppLogger.d(
            "⚠️ Error fetching applications for job ${job.jobId}: $e",
          );
          // Continue with other jobs even if one fails
        }
      }

      allApplications.value = allApps;
      applications.value = allApps;
      AppLogger.d(
        "✅ Fetched total ${allApps.length} applications from all jobs",
      );
    } catch (e) {
      AppLogger.d("❌ Error fetching all applications: $e");
      SnackBarHelper.error("Failed to load applications: ${e.toString()}");
      allApplications.value = [];
      applications.value = [];
    } finally {
      isApplicationsLoading.value = false;
    }
  }

  /// Update job application status (Accept/Reject)
  Future<bool> updateApplicationStatus({
    required String applicationId,
    required String status, // "Accepted" or "Rejected"
  }) async {
    try {
      final authService = AuthService.to;
      final userId = authService.currentUserId;
      final token = authService.currentToken;

      if (userId.isEmpty) {
        SnackBarHelper.error("Please login to update application status");
        return false;
      }

      AppLogger.d("📋 Updating application status: $applicationId to $status");
      AppLogger.d("📋 User ID: $userId");

      final response = await HttpHelper.postData(
        endpoint: API.updateJobStatus,
        data: {
          'applicationId': applicationId,
          'status': status,
          'modifiedUserId': userId,
        },
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      AppLogger.d("📋 Update status response: ${response.statusCode}");
      AppLogger.d("📋 Update status body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update local state
        final index = applications.indexWhere(
          (app) => app.applicationId == applicationId,
        );
        if (index != -1) {
          final updatedApp = applications[index].copyWith(status: status);
          final updatedList = List<JobApplicationModel>.from(applications);
          updatedList[index] = updatedApp;
          applications.value = updatedList;

          // Also update in allApplications
          final allIndex = allApplications.indexWhere(
            (app) => app.applicationId == applicationId,
          );
          if (allIndex != -1) {
            final updatedAllList = List<JobApplicationModel>.from(
              allApplications,
            );
            updatedAllList[allIndex] = updatedApp;
            allApplications.value = updatedAllList;
          }
        }

        SnackBarHelper.success(
          status == 'Accepted'
              ? "Application accepted successfully!"
              : "Application rejected",
        );
        return true;
      } else {
        AppLogger.d("❌ Failed to update status: ${response.statusCode}");
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              "Failed to update application status";
          SnackBarHelper.error(errorMessage);
        } catch (e) {
          SnackBarHelper.error("Failed to update application status");
        }
        return false;
      }
    } catch (e) {
      AppLogger.d("❌ Error updating application status: $e");
      SnackBarHelper.error("Failed to update status: ${e.toString()}");
      return false;
    }
  }

  /// Filter applications by location and role
  void filterApplications({String? location, String? role}) {
    var filtered = List<JobApplicationModel>.from(allApplications);

    if (location != null && location.isNotEmpty && location != 'All') {
      final locationTrimmed = location.trim().toLowerCase();
      filtered = filtered
          .where((app) => app.location.trim().toLowerCase() == locationTrimmed)
          .toList();
    }

    if (role != null && role.isNotEmpty && role != 'All') {
      final roleTrimmed = role.trim().toLowerCase();
      filtered = filtered
          .where(
            (app) =>
                app.jobTitle != null &&
                app.jobTitle!.trim().toLowerCase() == roleTrimmed,
          )
          .toList();
    }

    applications.value = filtered;
  }

  /// Fetch application counts for all jobs
  Future<void> _fetchApplicationCounts() async {
    try {
      final authService = AuthService.to;
      final token = authService.currentToken;

      final Map<String, int> counts = {};

      for (var job in jobs) {
        try {
          final response = await HttpHelper.getData(
            endpoint: '${API.getJobApplications}${job.jobId}',
            headers: {
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
              'Accept': '*/*',
            },
          );

          if (response.statusCode == 200) {
            final List data = json.decode(response.body);
            counts[job.jobId] = data.length;
          } else {
            counts[job.jobId] = 0;
          }
        } catch (e) {
          AppLogger.d("⚠️ Error fetching count for job ${job.jobId}: $e");
          counts[job.jobId] = 0;
        }
      }

      applicationCounts.value = counts;
      AppLogger.d("✅ Fetched application counts: $counts");
    } catch (e) {
      AppLogger.d("❌ Error fetching application counts: $e");
    }
  }

  /// Get application count for a specific job
  int getApplicationCount(String jobId) {
    return applicationCounts[jobId] ?? 0;
  }
}
