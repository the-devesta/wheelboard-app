import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/models/trip_expense_detail_model.dart';
import 'package:wheelboard/services/auth_service.dart';
import 'package:wheelboard/utils/app_logger.dart';
import 'package:wheelboard/utils/constants.dart';

class TransactionSummaryController extends GetxController {
  RxBool isLoading = false.obs;
  final TextEditingController searchController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();

  /// API DATA
  RxDouble totalExpenses = 0.0.obs;
  RxList<ExpenseDistribution> pieData = <ExpenseDistribution>[].obs;
  RxList<RecentExpense> recentExpenses = <RecentExpense>[].obs;
  RxList<RecentExpense> filteredExpenses = <RecentExpense>[].obs;

  @override
  void onInit() {
    getTransactionData();

    // search listener
    searchController.addListener(filterExpenses);
    super.onInit();
  }

  Future<void> getTransactionData() async {
    try {
      isLoading.value = true;

      final userId = _authService.userId;

      final response = await HttpHelper.getData(
        endpoint: API.tripExpenseDetail,
        queryParams: {'userId': userId.toLowerCase()},
        headers: {"Content-Type": "application/json"},
      );
      debugPrint('here==>> ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        AppLogger.d("RAW API RESPONSE => $json");

        final result = TripExpenseResponse.fromJson(json);

        AppLogger.d("Total Expenses => ${result.totalExpenses}");
        AppLogger.d("Recent Expenses Count => ${result.recentExpenses.length}");

        totalExpenses.value = result.totalExpenses;
        pieData.assignAll(result.distribution);
        recentExpenses.assignAll(result.recentExpenses);
        filteredExpenses.assignAll(result.recentExpenses);

        AppLogger.d("Rx Recent Expenses Count => ${recentExpenses.length}");
      } else {
        debugPrint('here==>>');
      }
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
    if (amount == 0.0) return '${symbol}0';

    final formatter = NumberFormat('#,##0', 'en_IN');
    return '$symbol${formatter.format(amount)}';
  }
}
