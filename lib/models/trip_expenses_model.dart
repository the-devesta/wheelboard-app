class TripExpensesModel {
  final TripInfo? tripInfo;
  final List<Expense>? expenses;
  final List<ExpenseBreakdown>? expenseBreakdown;
  final double? totalExpenses;

  TripExpensesModel({
    this.tripInfo,
    this.expenses,
    this.expenseBreakdown,
    this.totalExpenses,
  });

  factory TripExpensesModel.fromJson(Map<String, dynamic> json) {
    return TripExpensesModel(
      tripInfo: json['tripInfo'] != null
          ? TripInfo.fromJson(json['tripInfo'])
          : null,
      expenses: (json['expenses'] as List<dynamic>?)
          ?.map((e) => Expense.fromJson(e))
          .toList(),
      expenseBreakdown: (json['expenseBreakdown'] as List<dynamic>?)
          ?.map((e) => ExpenseBreakdown.fromJson(e))
          .toList(),
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble(),
    );
  }
}

class TripInfo {
  final String? tripCode;
  final String? status;
  final String? vehicle;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? distanceKm;
  final double? efficiencyPerKm;

  TripInfo({
    this.tripCode,
    this.status,
    this.vehicle,
    this.startDate,
    this.endDate,
    this.distanceKm,
    this.efficiencyPerKm,
  });

  factory TripInfo.fromJson(Map<String, dynamic> json) {
    return TripInfo(
      tripCode: json['tripCode'],
      status: json['status'],
      vehicle: json['vehicle'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      efficiencyPerKm: (json['efficiencyPerKm'] as num?)?.toDouble(),
    );
  }
}

class Expense {
  final String? expenseId;
  final String? purpose;
  final double? amount;
  final String? description;
  final DateTime? expenseDate;
  final bool? hasReceipt;

  Expense({
    this.expenseId,
    this.purpose,
    this.amount,
    this.description,
    this.expenseDate,
    this.hasReceipt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseId: json['expenseId'],
      purpose: json['purpose'],
      amount: (json['amount'] as num?)?.toDouble(),
      description: json['description'],
      expenseDate: json['expenseDate'] != null
          ? DateTime.parse(json['expenseDate'])
          : null,
      hasReceipt: json['hasReceipt'],
    );
  }
}

class ExpenseBreakdown {
  final String? purpose;
  final double? total;

  ExpenseBreakdown({this.purpose, this.total});

  factory ExpenseBreakdown.fromJson(Map<String, dynamic> json) {
    return ExpenseBreakdown(
      purpose: json['purpose'],
      total: (json['total'] as num?)?.toDouble(),
    );
  }
}
