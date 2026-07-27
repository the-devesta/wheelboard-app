import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../models/expense_model.dart';
import '../widgets/custom_snackbar.dart';

/// Read/delete client for the user's expenses (mirrors wheelboard-fe
/// `expensesApi.getExpenses()` / `deleteExpense()` → `GET`/`DELETE /expenses`).
class ExpenseService {
  /// GET /expenses with optional server-side filters.
  ///
  /// Every parameter is omitted when null/empty on purpose: the backend runs a
  /// global ValidationPipe with `forbidNonWhitelisted`, so sending
  /// `category=''` for an "All" selection fails its enum check with a 400
  /// rather than being ignored.
  Future<List<Expense>> getExpenses({
    String? category,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? vehicle,
    List<String>? tripIds,
    String? tripLink,
  }) async {
    try {
      String? isoDate(DateTime? d) => d?.toIso8601String().split('T').first;

      // "No trip" is a client-side concept; on the wire it is expressed as
      // tripLink=unassigned, not as a trip identifier.
      final realTripIds =
          (tripIds ?? const <String>[]).where((t) => t != kUnassignedTripKey).toList();

      final query = <String, dynamic>{
        if (category != null && category.isNotEmpty && category != 'all')
          'category': category,
        if (status != null && status.isNotEmpty && status != 'all')
          'status': status,
        if (startDate != null) 'startDate': isoDate(startDate),
        if (endDate != null) 'endDate': isoDate(endDate),
        if (vehicle != null && vehicle.isNotEmpty) 'vehicle': vehicle,
        if (realTripIds.isNotEmpty) 'tripIds': realTripIds.join(','),
        if (tripLink != null && tripLink.isNotEmpty && tripLink != 'all')
          'tripLink': tripLink,
      };

      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.expenses.list,
        queryParameters: query.isEmpty ? null : query,
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

  /// PATCH /expenses/:id  — update an expense's status (mirrors web
  /// `expensesApi.updateExpense`). Used to mark an expense as Paid.
  Future<bool> updateStatus(String id, String status) async {
    if (id.isEmpty) return false;
    try {
      await ApiClient.instance.patch<dynamic>(
        ApiEndpoints.expenses.update(id),
        data: {'status': status},
      );
      final label = status.isEmpty
          ? status
          : '${status[0].toUpperCase()}${status.substring(1)}';
      SnackBarHelper.success('Status updated to $label');
      return true;
    } on DioException catch (e) {
      SnackBarHelper.error(_msg(e, 'Failed to update status'));
      return false;
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
