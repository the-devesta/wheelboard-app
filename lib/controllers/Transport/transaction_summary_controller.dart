import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wheelboard/core/network/api_client.dart';
import 'package:wheelboard/core/network/api_endpoints.dart';
import 'package:wheelboard/core/network/api_exception.dart';
import 'package:wheelboard/models/expense_purpose_model.dart';
import 'package:wheelboard/models/trip_expense_detail_model.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import 'package:wheelboard/utils/app_logger.dart';
import 'package:wheelboard/widgets/custom_snackbar.dart';

class TransactionSummaryController extends GetxController {
  RxBool isLoading = false.obs;
  final TextEditingController searchController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();
  var expensePurposes = <ExpensePurpose>[].obs;
  RxnInt selectedPurposeId = RxnInt();

  /// API DATA
  RxDouble totalExpenses = 0.0.obs;
  RxList<ExpenseDistribution> pieData = <ExpenseDistribution>[].obs;
  RxList<RecentExpense> recentExpenses = <RecentExpense>[].obs;
  RxList<RecentExpense> filteredExpenses = <RecentExpense>[].obs;

  @override
  void onInit() {
    getTransactionData();
    fetchExpensePurposes();
    // search listener
    searchController.addListener(filterExpenses);
    super.onInit();
  }

  Future<void> getTransactionData({int? purposeId}) async {
    try {
      isLoading.value = true;
      selectedPurposeId.value = purposeId;
      final userId = _authService.userId;

      final queryParams = <String, dynamic>{
        'userId': userId.toLowerCase(),
      };
      if (purposeId != null) {
        queryParams['expensePurposeId'] = purposeId.toString();
      }

      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.expenses.expenseDetails,
        queryParameters: queryParams,
      );

      AppLogger.d("RAW API RESPONSE => $data");

      final result = TripExpenseResponse.fromJson(data);

      AppLogger.d("Total Expenses => ${result.totalExpenses}");
      AppLogger.d("Recent Expenses Count => ${result.recentExpenses.length}");

      totalExpenses.value = result.totalExpenses;
      pieData.assignAll(result.distribution);
      recentExpenses.assignAll(result.recentExpenses);
      filteredExpenses.assignAll(result.recentExpenses);

      AppLogger.d("Rx Recent Expenses Count => ${recentExpenses.length}");
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to fetch transaction data';
      AppLogger.d('Error==>> $msg');
    } catch (e) {
      AppLogger.d('Error==>> ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void filterExpenses() {
    final query = searchController.text.toLowerCase();

    if (query.isEmpty) {
      filteredExpenses.assignAll(recentExpenses);
    } else {
      filteredExpenses.assignAll(
        recentExpenses.where(
          (e) => e.expenseType.toLowerCase().contains(query),
        ),
      );
    }
  }

  String formatPrice(RxDouble? amount, {String symbol = '₹'}) {
    if (amount == null || amount.value == 0.0) return '${symbol}0';

    final formatter = NumberFormat('#,##0', 'en_IN');
    return '$symbol${formatter.format(amount.value)}';
  }

  Future<void> fetchExpensePurposes() async {
    try {
      isLoading.value = true;
      
      final data = await ApiClient.instance.get<List<dynamic>>(
        ApiEndpoints.expenses.purposes,
      );

      expensePurposes.value = data
          .map((json) => ExpensePurpose.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load expense purposes';
      SnackBarHelper.error(msg);
    } catch (e) {
      SnackBarHelper.error('Error loading expense purposes: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
