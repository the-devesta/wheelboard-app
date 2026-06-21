import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../models/expense_model.dart';
import '../widgets/custom_snackbar.dart';

/// Read/delete client for the user's expenses (mirrors wheelboard-fe
/// `expensesApi.getExpenses()` / `deleteExpense()` → `GET`/`DELETE /expenses`).
class ExpenseService {
  Future<List<Expense>> getExpenses() async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.expenses.list,
      );
      final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Expense.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to load expenses'));
    }
  }

  /// DELETE /expenses/:id  (mirrors web `expensesApi.deleteExpense`).
  Future<bool> deleteExpense(String id) async {
    if (id.isEmpty) return false;
    try {
      await ApiClient.instance.delete<dynamic>(
        ApiEndpoints.expenses.details(id),
      );
      SnackBarHelper.success('Expense deleted');
      return true;
    } on DioException catch (e) {
      SnackBarHelper.error(_msg(e, 'Failed to delete expense'));
      return false;
    }
  }

  String _msg(DioException e, String fallback) {
    if (e.error is ApiException) return (e.error as ApiException).message;
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      return m is List ? m.join(', ') : m.toString();
    }
    return '$fallback (${e.response?.statusCode ?? 'network error'})';
  }
}
