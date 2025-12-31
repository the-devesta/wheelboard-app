import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../apihelperclass/api_helper.dart';
import '../../services/auth_service.dart';
import '../../models/transport/lease_models.dart';
import '../../utils/constants.dart';
import '../../utils/app_logger.dart';

class LeaseController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Observables
  var isLoading = false.obs;
  var leaseList = <LeaseListItem>[].obs;
  var myBookedLeases = <LeaseListItem>[].obs;
  var leaseDetails = Rxn<LeaseDetails>();
  var applications = <LeaseApplication>[].obs;

  /// Fetch all leases
  Future<void> fetchLeaseList() async {
    isLoading.value = true;
    try {
      final response = await HttpHelper.getData(
        endpoint: API.leaseList,
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        leaseList.value = data.map((e) => LeaseListItem.fromJson(e)).toList();
      } else {
        AppLogger.e("Error fetching lease list: ${response.body}");
      }
    } catch (e) {
      AppLogger.e("Error fetching lease list: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch leases by user ID (My Leases)
  Future<void> fetchMyLeases() async {
    final userId = _authService.currentUserId;
    if (userId.isEmpty) return;

    isLoading.value = true;
    try {
      final response = await HttpHelper.getData(
        endpoint: '${API.leaseListByUserId}?userId=$userId',
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        leaseList.value = data.map((e) => LeaseListItem.fromJson(e)).toList();
      } else {
        AppLogger.e("Error fetching my leases: ${response.body}");
      }
    } catch (e) {
      AppLogger.e("Error fetching my leases: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch booked leases by user ID
  Future<void> fetchMyBookedLeases() async {
    final userId = _authService.currentUserId;
    if (userId.isEmpty) return;

    isLoading.value = true;
    try {
      final response = await HttpHelper.getData(
        endpoint: '${API.myBookedLeaseListByUserId}?userId=$userId',
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        myBookedLeases.value = data
            .map((e) => LeaseListItem.fromJson(e))
            .toList();
      } else {
        AppLogger.e("Error fetching booked leases: ${response.body}");
      }
    } catch (e) {
      AppLogger.e("Error fetching booked leases: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch lease details
  Future<void> fetchLeaseDetails(String leaseId) async {
    isLoading.value = true;
    try {
      final response = await HttpHelper.getData(
        endpoint: '${API.leaseDetails}$leaseId',
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        leaseDetails.value = LeaseDetails.fromJson(data);
      } else {
        AppLogger.e("Error fetching lease details: ${response.body}");
      }
    } catch (e) {
      AppLogger.e("Error fetching lease details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply for a lease
  Future<bool> applyForLease(String leaseId, String notes) async {
    final userId = _authService.currentUserId;
    if (userId.isEmpty) return false;

    isLoading.value = true;
    try {
      final request = ApplyLeaseRequest(
        leaseId: leaseId,
        userId: userId,
        notes: notes,
      );

      final response = await HttpHelper.postData(
        endpoint: API.applyForLease,
        data: request.toJson(),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Lease application submitted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          "Error",
          "Failed to apply for lease: ${response.body}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch lease applications
  Future<void> fetchLeaseApplications(
    String leaseId, {
    String status = 'Approved',
  }) async {
    isLoading.value = true;
    try {
      final response = await HttpHelper.getData(
        endpoint:
            '${API.getLeaseApplicationList}?leaseId=$leaseId&status=$status',
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == true && json['data'] != null) {
          final List<dynamic> data = json['data'];
          applications.value = data
              .map((e) => LeaseApplication.fromJson(e))
              .toList();
        } else {
          applications.clear();
        }
      } else {
        AppLogger.e("Error fetching lease applications: ${response.body}");
        applications.clear();
      }
    } catch (e) {
      AppLogger.e("Error fetching lease applications: $e");
      applications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle pause/resume lease
  Future<bool> togglePauseResume(String leaseId) async {
    final userId = _authService.currentUserId;
    if (userId.isEmpty) return false;

    isLoading.value = true;
    try {
      final response = await HttpHelper.postData(
        endpoint:
            '${API.leaseTogglePauseResume}?leaseId=$leaseId&userId=$userId',
        data: {}, // Empty body as per curl
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        Get.snackbar(
          "Success",
          json['message'] ?? "Status updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh list
        fetchMyLeases();
        return true;
      } else {
        Get.snackbar(
          "Error",
          "Failed to update status",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Off lease
  Future<bool> offLease(String leaseId) async {
    final userId = _authService.currentUserId;
    if (userId.isEmpty) return false;

    isLoading.value = true;
    try {
      final response = await HttpHelper.postData(
        endpoint: '${API.offLeases}?leaseId=$leaseId&userId=$userId',
        data: {}, // Empty body as per curl
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        Get.snackbar(
          "Success",
          json['message'] ?? "Lease ended successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchMyLeases();
        return true;
      } else {
        Get.snackbar(
          "Error",
          "Failed to end lease",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update lease application status (Approve/Reject)
  Future<bool> updateLeaseApplicationStatus(
    String applicationId,
    String status,
  ) async {
    isLoading.value = true;
    try {
      final request = UpdateLeaseApplicationStatusRequest(
        applicationId: applicationId,
        status: status,
      );

      final response = await HttpHelper.postData(
        endpoint: API.updateLeaseApplicationStatus,
        data: request.toJson(),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        Get.snackbar(
          "Success",
          json['message'] ?? "Status updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        AppLogger.e("Error updating application status: ${response.body}");
        Get.snackbar(
          "Error",
          "Failed to update status",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      AppLogger.e("Error updating application status: $e");
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, String> _getHeaders() {
    return {
      'Authorization': 'Bearer ${_authService.currentToken}',
      'Content-Type': 'application/json',
    };
  }

  @override
  void onInit() {
    super.onInit();
    // fetchLeaseList(); // Optional: fetch on init if needed
  }
}
