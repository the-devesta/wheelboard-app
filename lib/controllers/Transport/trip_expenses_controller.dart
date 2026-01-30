import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:wheelboard/models/trip_expenses_model.dart';
import 'package:wheelboard/utils/session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:wheelboard/utils/constants.dart';

class TripExpensesController extends GetxController {
  final isLoading = false.obs;
  final tripExpenses = Rxn<TripExpensesModel>();
  final errorMessage = ''.obs;

  Future<void> fetchTripExpenses(String tripId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // Direct API call - no leading slash (baseUrl already has trailing /)
      final url = Uri.parse(
        '${ApiConstants.baseUrl}api/Trip/trip-expenses/$tripId',
      );

      debugPrint('📡 Fetching trip expenses from: $url');

      final response = await http.get(url, headers: {'accept': 'text/plain'});

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        debugPrint('📡 JSON parsed, status: ${jsonResponse['status']}');

        // API returns {"status": true, "data": {...}} - extract the data field
        final data = jsonResponse['data'] ?? jsonResponse;
        debugPrint('📡 Data to parse: $data');

        tripExpenses.value = TripExpensesModel.fromJson(data);

        // Log what was loaded
        debugPrint('✅ Trip expenses loaded successfully');
        debugPrint('   - Trip Code: ${tripExpenses.value?.tripInfo?.tripCode}');
        debugPrint('   - Vehicle: ${tripExpenses.value?.tripInfo?.vehicle}');
        debugPrint('   - Status: ${tripExpenses.value?.tripInfo?.status}');
        debugPrint(
          '   - Distance: ${tripExpenses.value?.tripInfo?.distanceKm} km',
        );
        debugPrint(
          '   - Efficiency: ${tripExpenses.value?.tripInfo?.efficiencyPerKm}',
        );
        debugPrint('   - Total Expenses: ${tripExpenses.value?.totalExpenses}');
        debugPrint(
          '   - Expense Count: ${tripExpenses.value?.expenses?.length ?? 0}',
        );
        debugPrint(
          '   - Breakdown Count: ${tripExpenses.value?.expenseBreakdown?.length ?? 0}',
        );
      } else {
        errorMessage.value = 'Failed to load expenses: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      debugPrint('❌ Error fetching trip expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteTrip(String tripId) async {
    try {
      final sessionManager = SessionManager();
      final userId = await sessionManager.getString("userId");

      if (userId == null) {
        Get.snackbar("Error", "User not found");
        return false;
      }

      // Direct API call - no leading slash (baseUrl already has trailing /)
      final url = Uri.parse(
        '${ApiConstants.baseUrl}api/Trip/delete-trip?tripId=$tripId&userId=$userId',
      );

      debugPrint('📡 Deleting trip at: $url');

      final response = await http.post(url, headers: {'accept': '*/*'});

      debugPrint('📡 Delete response status: ${response.statusCode}');
      debugPrint('📡 Delete response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Trip deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete trip: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error deleting trip: $e');
      Get.snackbar(
        'Error',
        'Error deleting trip: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
}
