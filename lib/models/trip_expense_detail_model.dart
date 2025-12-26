import 'dart:ffi';

class TripExpenseResponse {
  final double totalExpenses;
  final List<ExpenseDistribution> distribution;
  final List<RecentExpense> recentExpenses;

  TripExpenseResponse({
    required this.totalExpenses,
    required this.distribution,
    required this.recentExpenses,
  });

  factory TripExpenseResponse.fromJson(Map<String, dynamic> json) {
    return TripExpenseResponse(
      totalExpenses: json['totalExpenses'] ?? 0.0,
      distribution: (json['distribution'] as List? ?? [])
          .map((e) => ExpenseDistribution.fromJson(e))
          .toList(),
      recentExpenses: (json['recentExpenses'] as List? ?? [])
          .map((e) => RecentExpense.fromJson(e))
          .toList(),
    );
  }
}

class ExpenseDistribution {
  final String expenseType;
  final double amount;
  final double percentage;

  ExpenseDistribution({
    required this.expenseType,
    required this.amount,
    required this.percentage,
  });

  factory ExpenseDistribution.fromJson(Map<String, dynamic> json) {
    return ExpenseDistribution(
      expenseType: json['expenseType'],
      amount: json['amount'],
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class RecentExpense {
  final String expenseType;
  final DateTime dateEntered;
  final double amount;

  RecentExpense({
    required this.expenseType,
    required this.dateEntered,
    required this.amount,
  });

  factory RecentExpense.fromJson(Map<String, dynamic> json) {
    return RecentExpense(
      expenseType: json['expenseType'],
      dateEntered: DateTime.parse(json['dateEntered']),
      amount: json['amount'],
    );
  }
}
