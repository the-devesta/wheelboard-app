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
  }) async {
    try {
      isSaving(true);
      final userId = _authService.currentUserId;

      final fields = <String, String>{
        'TripId': tripId,
        'ExpensePurposeId': expensePurposeId.toString(),
        'ExpenseDate': expenseDate.toIso8601String(),
        'Amount': amount.toString(),
        'Description': description,
        'CreatedBy': userId,
      };

      if (expenseId != null && expenseId.isNotEmpty) {
        fields['ExpenseId'] = expenseId;
      }

      final files = <File>[];
      if (receiptFile != null) {
        files.add(receiptFile);
      }

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarHelper.success('Expense saved successfully');
        return true;
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['title'] ?? 'Failed to save expense';
          SnackBarHelper.error(errorMessage);
        } catch (_) {
          SnackBarHelper.error('Failed to save expense');
        }
        return false;
      }
    } catch (e) {
      SnackBarHelper.error('Error saving expense: $e');
      return false;
    } finally {
      isSaving(false);
    }
  }
}

