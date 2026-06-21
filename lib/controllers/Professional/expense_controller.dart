import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:wheelboard/models/expense_purpose_model.dart';
import 'package:wheelboard/core/network/api_client.dart';
import 'package:wheelboard/core/network/api_endpoints.dart';
import 'package:wheelboard/core/network/api_exception.dart';
import 'package:wheelboard/widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

/// Expense create/delete controller.
///
/// Mirrors the wheelboard-fe `expensesApi` contract, which is the same contract
/// the NestJS backend enforces (`src/dto/expense.dto.ts`):
///   POST /expenses  { category (enum), description, amount:number, date:ISO,
///                     paymentMethod, status?, vehicle?, tripId?, receipt? }  (JSON)
///
/// There is NO `/expenses/purposes` endpoint and no `expensePurposeId` — the FE
/// uses a fixed `ExpenseCategory` enum, so the "purpose" dropdown is populated
/// from a static list (kept as [ExpensePurpose] so the shared Add-Expense screen
/// UI stays unchanged).
class ExpenseController extends GetxController {
  var expensePurposes = <ExpensePurpose>[].obs;
  var isLoadingPurposes = false.obs;
  var isSaving = false.obs;
  var isDeleting = false.obs;

  /// Backend `ExpenseCategory` enum values, in display order. The code sent to
  /// the API is the lowercase label (e.g. "Fuel" → "fuel"), which matches the
  /// enum exactly.
  static const List<String> categoryLabels = [
    'Advance',
    'Fuel',
    'Challan',
    'Food',
    'Salary',
    'Enroute',
    'Maintenance',
    'Toll',
    'Parking',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  /// Populate the (static) category list. No network call — the backend has no
  /// purposes endpoint; categories are a fixed enum (parity with FE).
  void loadCategories() {
    isLoadingPurposes(true);
    expensePurposes.value = [
      for (var i = 0; i < categoryLabels.length; i++)
        ExpensePurpose(expensePurposeId: i + 1, purposeName: categoryLabels[i]),
    ];
    isLoadingPurposes(false);
  }

  /// Back-compat alias — older callers invoke `fetchExpensePurposes()`.
  Future<void> fetchExpensePurposes() async => loadCategories();

  /// Map a display label ("Fuel") to the backend category code ("fuel").
  String categoryCodeFor(String purposeName) => purposeName.trim().toLowerCase();

  /// POST /expenses (JSON). Returns true on success.
  Future<bool> saveExpense({
    required String category,
    required DateTime expenseDate,
    required double amount,
    required String description,
    String paymentMethod = 'cash',
    String? tripId,
    String? receipt,
    String? vehicle,
    String? status,
  }) async {
    try {
      isSaving(true);

      final body = <String, dynamic>{
        'category': category,
        'description': description,
        'amount': amount,
        'date': expenseDate.toUtc().toIso8601String(),
        'paymentMethod': paymentMethod,
        if (status != null && status.isNotEmpty) 'status': status,
        if (vehicle != null && vehicle.isNotEmpty) 'vehicle': vehicle,
        if (tripId != null && tripId.isNotEmpty) 'tripId': tripId,
        if (receipt != null && receipt.isNotEmpty) 'receipt': receipt,
      };

      AppLogger.d('💾 Creating expense: category=$category amount=$amount');

      final data = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiEndpoints.expenses.create,
        data: body,
      );

      final success = data['success'] == true || data['data'] != null;
      final message = (data['message'] as String?) ?? 'Expense saved';
      if (success) {
        SnackBarHelper.success(message);
        return true;
      }
      SnackBarHelper.error(message);
      return false;
    } on dio.DioException catch (e) {
      AppLogger.e('❌ Error saving expense: ${_msg(e)}');
      SnackBarHelper.error(_msg(e, fallback: 'Failed to save expense'));
      return false;
    } catch (e) {
      AppLogger.e('❌ Error saving expense: $e');
      SnackBarHelper.error('Something went wrong');
      return false;
    } finally {
      isSaving(false);
    }
  }

  /// DELETE /expenses/:id
  Future<bool> deleteExpense(String expenseId) async {
    if (expenseId.isEmpty) return false;
    try {
      isDeleting(true);
      await ApiClient.instance.delete<dynamic>(
        ApiEndpoints.expenses.details(expenseId),
      );
      SnackBarHelper.success('Expense deleted');
      return true;
    } on dio.DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to delete expense'));
      return false;
    } catch (e) {
      SnackBarHelper.error('Failed to delete expense: $e');
      return false;
    } finally {
      isDeleting(false);
    }
  }

  String _msg(dio.DioException e, {String fallback = 'Something went wrong'}) {
    if (e.error is ApiException) return (e.error as ApiException).message;
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      return m is List ? m.join(', ') : m.toString();
    }
    return fallback;
  }
}
