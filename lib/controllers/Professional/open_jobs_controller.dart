import 'dart:convert';
import 'package:get/get.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../models/Professional/open_job_model.dart';
import '../../widgets/custom_snackbar.dart';

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

      print("💼 Fetching open jobs...");

      final response = await HttpHelper.getData(
        endpoint: API.getOpenJobs,
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      print("💼 Open jobs response status: ${response.statusCode}");
      print("💼 Open jobs response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        openJobs.value = data.map((e) => OpenJob.fromJson(e)).toList();
        print("✅ Fetched ${openJobs.length} open jobs");
      } else {
        print("❌ Failed to fetch open jobs: ${response.statusCode}");
        SnackBarHelper.error("Failed to load jobs");
      }
    } catch (e) {
      print("❌ Error fetching open jobs: $e");
      SnackBarHelper.error("Failed to load jobs: ${e.toString()}");
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

      print("📝 Applying for job: $jobId");
      print("📝 User ID: $userId");

      final response = await HttpHelper.postData(
        endpoint: API.applyJob,
        data: {
          "jobId": jobId,
          "userId": userId,
        },
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      print("📝 Apply job response status: ${response.statusCode}");
      print("📝 Apply job response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Successfully applied for job: $jobId");
        SnackBarHelper.success("Job application submitted successfully!");
        return true;
      } else {
        print("❌ Failed to apply for job: ${response.statusCode}");
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['message'] ?? 
                              errorData['error'] ?? 
                              "Failed to apply for job";
          SnackBarHelper.error(errorMessage);
        } catch (e) {
          SnackBarHelper.error("Failed to apply for job");
        }
        return false;
      }
    } catch (e) {
      print("❌ Error applying for job: $e");
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
}

