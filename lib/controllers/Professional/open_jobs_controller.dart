import 'dart:convert';
import 'package:get/get.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../models/Professional/open_job_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/kyc_helper.dart';
import '../../utils/app_logger.dart';

class OpenJobsController extends GetxController {
  var isLoading = false.obs;
  var openJobs = <OpenJob>[].obs;
  var applyingJobId = ''.obs; // Track which job is being applied

  @override
  void onInit() {
    super.onInit();
    fetchOpenJobs();
  }

  /// Fetch open jobs from API
  Future<void> fetchOpenJobs() async {
    try {
      isLoading.value = true;

      final authService = AuthService.to;
      final token = authService.currentToken;
      final userId = authService.currentUserId;

      AppLogger.d("💼 Fetching open jobs...");
      AppLogger.d("💼 User ID: $userId");

      // Build endpoint with userId query parameter
      final endpoint = userId.isNotEmpty
          ? '${API.getOpenJobs}?userId=$userId'
          : API.getOpenJobs;

      AppLogger.d("💼 API Endpoint: $endpoint");

      final response = await HttpHelper.getData(
        endpoint: endpoint,
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      AppLogger.d("💼 Open jobs response status: ${response.statusCode}");
      AppLogger.d(
        "💼 Open jobs response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}",
      );

      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        AppLogger.d(
          "❌ Server returned HTML instead of JSON - API endpoint may be incorrect",
        );
        SnackBarHelper.error("Server error: Please try again later");
        openJobs.value = []; // Clear jobs list
        return;
      }

      if (response.statusCode == 200) {
        try {
          final decoded = json.decode(response.body);

          if (decoded is List) {
            // 🔍 Debug: Print first job raw data to see all fields
            if (decoded.isNotEmpty) {
              AppLogger.d(
                "🔍 First job raw data keys: ${decoded[0].keys.toList()}",
              );
              AppLogger.d("🔍 First job raw data: ${decoded[0]}");
            }

            openJobs.value = decoded.map((e) => OpenJob.fromJson(e)).toList();
            AppLogger.d("✅ Fetched ${openJobs.length} open jobs");
          } else {
            // Case where server returns a message object instead of a list
            openJobs.value = [];
            if (decoded is Map && decoded.containsKey('message')) {
              AppLogger.d("ℹ️ API Message: ${decoded['message']}");
            }
          }

          // 🔍 Debug: Print first parsed job's companyName
          if (openJobs.isNotEmpty) {
            AppLogger.d("🔍 First job companyName: ${openJobs[0].companyName}");
          }
        } catch (parseError) {
          AppLogger.d("❌ Error parsing open jobs response: $parseError");
          SnackBarHelper.error("Failed to parse jobs data");
          openJobs.value = [];
        }
      } else {
        AppLogger.d("❌ Failed to fetch open jobs: ${response.statusCode}");
        // Try to parse error message if it's JSON
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              "Failed to load jobs";
          SnackBarHelper.error(errorMessage);
        } catch (e) {
          SnackBarHelper.error("Failed to load jobs (${response.statusCode})");
        }
        openJobs.value = [];
      }
    } catch (e) {
      AppLogger.d("❌ Error fetching open jobs: $e");
      SnackBarHelper.error("Failed to load jobs: ${e.toString()}");
      openJobs.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply for a job
  Future<bool> applyForJob(String jobId) async {
    try {
      applyingJobId.value = jobId;

      final authService = AuthService.to;
      final userId = authService.currentUserId;
      final token = authService.currentToken;

      if (userId.isEmpty) {
        SnackBarHelper.error("Please login to apply for jobs");
        return false;
      }

      // Check KYC status before applying
      if (!KYCHelper.checkAndShowKYCDialog()) {
        return false;
      }

      AppLogger.d("📝 Applying for job: $jobId");
      AppLogger.d("📝 User ID: $userId");

      final response = await HttpHelper.postData(
        endpoint: API.applyJob,
        data: {"jobId": jobId, "userId": userId},
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      AppLogger.d("📝 Apply job response status: ${response.statusCode}");
      AppLogger.d("📝 Apply job response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.d("✅ Successfully applied for job: $jobId");
        SnackBarHelper.success("Job application submitted successfully!");
        return true;
      } else {
        AppLogger.d("❌ Failed to apply for job: ${response.statusCode}");
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              "Failed to apply for job";
          SnackBarHelper.error(errorMessage);
        } catch (e) {
          SnackBarHelper.error("Failed to apply for job");
        }
        return false;
      }
    } catch (e) {
      AppLogger.d("❌ Error applying for job: $e");
      SnackBarHelper.error("Failed to apply for job: ${e.toString()}");
      return false;
    } finally {
      applyingJobId.value = '';
    }
  }

  /// Refresh open jobs
  Future<void> refreshOpenJobs() async {
    await fetchOpenJobs();
  }

  /// Check if a job is being applied
  bool isApplying(String jobId) {
    return applyingJobId.value == jobId;
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

      // Check KYC status before liking
      if (!KYCHelper.checkAndShowKYCDialog()) {
        return false;
      }

      AppLogger.d("👍 Toggling like for job: $jobId");
      AppLogger.d("👍 User ID: $userId");

      // Build endpoint with both jobId and userId query parameters
      final endpoint = '${API.toggleJobLike}?jobId=$jobId&userId=$userId';

      final response = await HttpHelper.postData(
        endpoint: endpoint,
        data: {}, // Empty body as per API
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      AppLogger.d("👍 Toggle like response status: ${response.statusCode}");
      AppLogger.d("👍 Toggle like response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Find the job in the list and update its like status
        final jobIndex = openJobs.indexWhere((job) => job.jobId == jobId);
        if (jobIndex != -1) {
          final job = openJobs[jobIndex];
          // Toggle the like status and update count
          final newIsLiked = !job.isLiked;
          final newLikeCount = newIsLiked
              ? job.likeCount + 1
              : job.likeCount - 1;

          // Create updated job
          final updatedJob = OpenJob(
            jobId: job.jobId,
            role: job.role,
            jobDuration: job.jobDuration,
            openings: job.openings,
            salary: job.salary,
            city: job.city,
            jobType: job.jobType,
            description: job.description,
            imagePaths: job.imagePaths,
            isApplied: job.isApplied,
            likeCount: newLikeCount >= 0 ? newLikeCount : 0,
            isLiked: newIsLiked,
            companyName: job.companyName, // Preserve company name
          );

          // Update the job in the list
          openJobs[jobIndex] = updatedJob;
          AppLogger.d("✅ Successfully toggled like for job: $jobId");
        }
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
}
