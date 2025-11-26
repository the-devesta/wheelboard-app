import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:wheelboard/models/expense_purpose_model.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/services/auth_service.dart';
import 'package:wheelboard/utils/constants.dart';
import 'package:wheelboard/widgets/custom_snackbar.dart';

class ExpenseController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var expensePurposes = <ExpensePurpose>[].obs;
  var isLoadingPurposes = false.obs;
  var isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExpensePurposes();
  }

  Future<void> fetchExpensePurposes() async {
    try {
      isLoadingPurposes(true);
      final response = await HttpHelper.getData(
        endpoint: API.getExpensePurposes,
        headers: {'accept': '*/*'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        expensePurposes.value =
            data.map((json) => ExpensePurpose.fromJson(json)).toList();
      } else {
        SnackBarHelper.error('Failed to load expense purposes');
      }
    } catch (e) {
      SnackBarHelper.error('Error loading expense purposes: $e');
    } finally {
      isLoadingPurposes(false);
    }
  }

  Future<bool> saveExpense({
    required String tripId,
    required int expensePurposeId,
    required DateTime expenseDate,
    required double amount,
    required String description,
    File? receiptFile,
    String? expenseId,
    String? receiptPath,
  }) async {
    try {
      isSaving(true);
      final userId = _authService.currentUserId;

      // Format date as ISO8601 string
      final formattedDate = expenseDate.toIso8601String();

      final fields = <String, String>{
        'TripId': tripId,
        'ExpensePurposeId': expensePurposeId.toString(),
        'ExpenseDate': formattedDate,
        'Amount': amount.toString(),
        'Description': description,
        'CreatedBy': userId,
        'ExpenseId': expenseId ?? '', // Always send, empty if creating new
        'ReceiptPath': receiptPath ?? 'string', // Always send, default to 'string' if not provided
      };

      final files = <File>[];
      if (receiptFile != null) {
        files.add(receiptFile);
      }

      print("💾 Saving expense:");
      print("💾 TripId: $tripId");
      print("💾 ExpensePurposeId: $expensePurposeId");
      print("💾 ExpenseDate: $formattedDate");
      print("💾 Amount: $amount");
      print("💾 Description: $description");
      print("💾 ExpenseId: ${fields['ExpenseId']}");
      print("💾 ReceiptPath: ${fields['ReceiptPath']}");
      print("💾 Has Receipt File: ${receiptFile != null}");

      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.saveTripExpense,
        fields: fields,
        files: files,
        fieldKey: 'ReceiptFile',
        headers: {
          'accept': '*/*',
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      print("💾 Expense save response status: ${response.statusCode}");
      print("💾 Expense save response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseBody = jsonDecode(response.body);
          final success = responseBody['success'] ?? false;
          final message = responseBody['message'] ?? 'Expense saved successfully';
          
          if (success) {
            SnackBarHelper.success(message);
            return true;
          } else {
            SnackBarHelper.error(message);
            return false;
          }
        } catch (_) {
          // If response is not JSON or doesn't have success field, assume success
          SnackBarHelper.success('Expense saved successfully');
          return true;
        }
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['message'] ?? 
                              errorBody['title'] ?? 
                              errorBody['error'] ?? 
                              'Failed to save expense';
          SnackBarHelper.error(errorMessage);
        } catch (_) {
          SnackBarHelper.error('Failed to save expense (${response.statusCode})');
        }
        return false;
      }
    } catch (e) {
      print("❌ Error saving expense: $e");
      SnackBarHelper.error('Error saving expense: ${e.toString()}');
      return false;
    } finally {
      isSaving(false);
    }
  }
}

