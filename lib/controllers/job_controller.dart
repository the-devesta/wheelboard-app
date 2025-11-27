import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import '../models/job_model.dart';
import '../models/job_application_model.dart';
import '../widgets/custom_snackbar.dart';

class JobController extends GetxController {
  var isLoading = false.obs;
  var jobs = <JobModel>[].obs;
  
  // Job Applications
  var isApplicationsLoading = false.obs;
  var applications = <JobApplicationModel>[].obs;
  var allApplications = <JobApplicationModel>[].obs; // Store all applications for filtering

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
        method: 'POST', 
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

      print("👍 Toggling like for job: $jobId");
      print("👍 User ID: $userId");

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

      print("👍 Toggle like response status: ${response.statusCode}");
      print("👍 Toggle like response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jobIndex = jobs.indexWhere((job) => job.jobId == jobId);
        if (jobIndex != -1) {
          final job = jobs[jobIndex];
          // Toggle the like status and update count
          final newIsLiked = !job.isLiked;
          final newLikeCount = newIsLiked ? job.likeCount + 1 : (job.likeCount > 0 ? job.likeCount - 1 : 0);
          
          // Create updated job using copyWith
          final updatedJob = job.copyWith(
            likeCount: newLikeCount,
            isLiked: newIsLiked,
          );
          
          // Update the job in the list - create new list to trigger GetX reactivity
          final updatedJobs = List<JobModel>.from(jobs);
          updatedJobs[jobIndex] = updatedJob;
          jobs.value = updatedJobs;
          jobs.refresh(); // Force refresh to ensure UI updates
          print("✅ Successfully toggled like for job: $jobId");
        }
        return true;
      } else {
        print("❌ Failed to toggle like: ${response.statusCode}");
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['message'] ?? 
                              errorData['error'] ?? 
                              "Failed to toggle like";
          SnackBarHelper.error(errorMessage);
        } catch (e) {
          SnackBarHelper.error("Failed to toggle like");
        }
        return false;
      }
    } catch (e) {
      print("❌ Error toggling like: $e");
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

      print("📋 Fetching applications for jobId: $jobId");

      final response = await HttpHelper.getData(
        endpoint: '${API.getJobApplications}$jobId',
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      print("📋 Applications response status: ${response.statusCode}");
      print("📋 Applications response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final fetchedApplications = data
            .map((e) => JobApplicationModel.fromJson(e))
            .toList();
        
        allApplications.value = fetchedApplications;
        applications.value = fetchedApplications;
        print("✅ Fetched ${applications.length} applications");
      } else {
        print("❌ Failed to fetch applications: ${response.statusCode}");
        SnackBarHelper.error("Failed to load applications");
        allApplications.value = [];
        applications.value = [];
      }
    } catch (e) {
      print("❌ Error fetching applications: $e");
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

      print("📋 Fetching applications for all ${jobs.length} jobs");

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
            print("✅ Fetched ${fetchedApplications.length} applications for job: ${job.role}");
          } else {
            print("⚠️ Failed to fetch applications for job ${job.jobId}: ${response.statusCode}");
          }
        } catch (e) {
          print("⚠️ Error fetching applications for job ${job.jobId}: $e");
          // Continue with other jobs even if one fails
        }
      }

      allApplications.value = allApps;
      applications.value = allApps;
      print("✅ Fetched total ${allApps.length} applications from all jobs");
    } catch (e) {
      print("❌ Error fetching all applications: $e");
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

      print("📋 Updating application status: $applicationId to $status");
      print("📋 User ID: $userId");

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

      print("📋 Update status response: ${response.statusCode}");
      print("📋 Update status body: ${response.body}");

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
            final updatedAllList = List<JobApplicationModel>.from(allApplications);
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
        print("❌ Failed to update status: ${response.statusCode}");
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['message'] ?? 
                              errorData['error'] ?? 
                              "Failed to update application status";
          SnackBarHelper.error(errorMessage);
        } catch (e) {
          SnackBarHelper.error("Failed to update application status");
        }
        return false;
      }
    } catch (e) {
      print("❌ Error updating application status: $e");
      SnackBarHelper.error("Failed to update status: ${e.toString()}");
      return false;
    }
  }

  /// Filter applications by location and role
  void filterApplications({
    String? location,
    String? role,
  }) {
    var filtered = List<JobApplicationModel>.from(allApplications);

    if (location != null && location.isNotEmpty && location != 'All') {
      final locationTrimmed = location.trim().toLowerCase();
      filtered = filtered.where((app) => 
        app.location.trim().toLowerCase() == locationTrimmed
      ).toList();
    }

    if (role != null && role.isNotEmpty && role != 'All') {
      final roleTrimmed = role.trim().toLowerCase();
      filtered = filtered.where((app) => 
        app.jobTitle != null && 
        app.jobTitle!.trim().toLowerCase() == roleTrimmed
      ).toList();
    }

    applications.value = filtered;
  }
}

