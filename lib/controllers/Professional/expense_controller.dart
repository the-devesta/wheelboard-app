import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:wheelboard/models/expense_purpose_model.dart';
import 'package:wheelboard/core/network/api_client.dart';
import 'package:wheelboard/core/network/api_endpoints.dart';
import 'package:wheelboard/core/network/api_exception.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import 'package:wheelboard/widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

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

      final data = await ApiClient.instance.get<List<dynamic>>(
        ApiEndpoints.expenses.list,
      );

      expensePurposes.value = data
          .map((json) => ExpensePurpose.fromJson(json as Map<String, dynamic>))
          .toList();
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load expense purposes';
      SnackBarHelper.error(msg);
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

      final fields = <String, dynamic>{
        'tripId': tripId,
        'expensePurposeId': expensePurposeId.toString(),
        'expenseDate': formattedDate,
        'amount': amount.toString(),
        'description': description,
        'createdBy': userId,
        if (expenseId != null && expenseId.isNotEmpty) 'expenseId': expenseId,
        if (receiptPath != null && receiptPath.isNotEmpty) 'receiptPath': receiptPath,
      };

      final formData = dio.FormData.fromMap(fields);

      if (receiptFile != null) {
        formData.files.add(MapEntry(
          'receiptFile',
          await dio.MultipartFile.fromFile(receiptFile.path),
        ));
      }

      AppLogger.d("💾 Saving expense for trip: $tripId, amount: $amount");

      final data = await ApiClient.instance.upload<Map<String, dynamic>>(
        ApiEndpoints.expenses.create,
        formData: formData,
      );

      final success = data['success'] ?? false;
      final message = data['message'] ?? 'Expense saved successfully';

      if (success) {
        SnackBarHelper.success(message);
        return true;
      } else {
        SnackBarHelper.error(message);
        return false;
      }
    } on dio.DioException catch (e) {
      AppLogger.d("❌ Error saving expense: $e");
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to save expense';
      SnackBarHelper.error(msg);
      return false;
    } catch (e) {
      AppLogger.d("❌ Error saving expense: $e");
      SnackBarHelper.error("Something went wrong");
      return false;
    } finally {
      isSaving(false);
    }
  }
}
