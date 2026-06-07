import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../models/expense_model.dart';

/// Read client for the user's expenses (mirrors wheelboard-fe
/// `expensesApi.getExpenses()` → `GET /expenses`, wrapped as `{ success, data }`).
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
