import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import '../models/job_model.dart';
import '../widgets/custom_snackbar.dart';

class JobController extends GetxController {
  var isLoading = false.obs;
  var jobs = <JobModel>[].obs;

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
        print("⚠️ User not logged in, cannot fetch jobs");
        return;
      }

      print("💼 Fetching jobs for userId: $userId");

      final response = await HttpHelper.getData(
        endpoint: '${API.getJobList}$userId',
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      print("💼 Jobs response status: ${response.statusCode}");
      print("💼 Jobs response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        jobs.value = data.map((e) => JobModel.fromJson(e)).toList();
        print("✅ Fetched ${jobs.length} jobs");
      } else {
        print("❌ Failed to fetch jobs: ${response.statusCode}");
        SnackBarHelper.error("Failed to load jobs");
      }
    } catch (e) {
      print("❌ Error fetching jobs: $e");
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
    required List<File> images,
  }) async {
    try {
      isLoading.value = true;

      final authService = AuthService.to;
      final userId = authService.currentUserId;

      if (userId.isEmpty) {
        SnackBarHelper.error("Please login to post jobs");
        return false;
      }

      if (images.isEmpty) {
        SnackBarHelper.error("Please upload at least one image");
        return false;
      }

      print("💼 Adding new job...");
      print("💼 UserId: $userId");
      print("💼 Role: $role");
      print("💼 Images: ${images.length}");

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

      // Send multipart request (no token needed, works with userId only)
      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.addJob,
        fields: fields,
        files: images,
        fieldKey: 'Images', // API expects 'Images' as field name
        headers: {
          'Accept': '*/*',
        },
      );

      print("💼 Add job response status: ${streamedResponse.statusCode}");
      
      final responseBody = await streamedResponse.stream.bytesToString();
      print("💼 Add job response body: $responseBody");

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        print("✅ Successfully added job");
        SnackBarHelper.success("Job posted successfully!");
        await fetchJobs(); // Refresh jobs list
        return true;
      } else {
        print("❌ Failed to add job: ${streamedResponse.statusCode}");
        try {
          final errorData = json.decode(responseBody);
          final errorMessage = errorData['errors']?['Images']?[0] ?? 
                              errorData['title'] ?? 
                              "Failed to post job";
          SnackBarHelper.error(errorMessage);
        } catch (e) {
          SnackBarHelper.error("Failed to post job");
        }
        return false;
      }
    } catch (e) {
      print("❌ Error adding job: $e");
      SnackBarHelper.error("Failed to post job: ${e.toString()}");
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

      print("💼 Updating job: $jobId");
      print("💼 UserId: $userId");

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
        headers: {
          'Accept': '*/*',
        },
        method: 'PUT', // Changed from PUT to POST
      );

      print("💼 Update job response status: ${streamedResponse.statusCode}");
      
      final responseBody = await streamedResponse.stream.bytesToString();
      print("💼 Update job response body: $responseBody");

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        print("✅ Successfully updated job");
        SnackBarHelper.success("Job updated successfully!");
        await fetchJobs(); // Refresh jobs list
        return true;
      } else {
        print("❌ Failed to update job: ${streamedResponse.statusCode}");
        print("❌ Response body: $responseBody");
        
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
      print("❌ Error updating job: $e");
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
}

