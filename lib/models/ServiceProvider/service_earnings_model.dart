class ServiceEarningsModel {
  final double totalEarnings;
  final double cashEarnings;
  final List<ServiceBreakdown> serviceBreakdown;
  final List<EarningsChartData> earningsChart;
  final List<PaymentHistory> paymentHistory;

  ServiceEarningsModel({
    required this.totalEarnings,
    this.cashEarnings = 0.0,
    required this.serviceBreakdown,
    required this.earningsChart,
    required this.paymentHistory,
  });

  factory ServiceEarningsModel.fromJson(Map<String, dynamic> json) {
    final total = (json['totalEarnings'] ?? 0.0).toDouble();
    // Use cashEarnings from JSON if present, otherwise default to 0.0
    final cash = (json['cashEarnings'] ?? 0.0).toDouble();

    return ServiceEarningsModel(
      totalEarnings: total,
      cashEarnings: cash,
      serviceBreakdown: (json['serviceBreakdown'] as List? ?? [])
          .map((i) => ServiceBreakdown.fromJson(i))
          .toList(),
      earningsChart: (json['earningsChart'] as List? ?? [])
          .map((i) => EarningsChartData.fromJson(i))
          .toList(),
      paymentHistory: (json['paymentHistory'] as List? ?? [])
          .map((i) => PaymentHistory.fromJson(i))
          .toList(),
    );
  }
}

class ServiceBreakdown {
  final String serviceId;
  final String serviceTitle;
  final double totalAmount;
  final int bookingCount;
  final String? lastBookingDate;

  ServiceBreakdown({
    required this.serviceId,
    required this.serviceTitle,
    required this.totalAmount,
    required this.bookingCount,
    this.lastBookingDate,
  });

  factory ServiceBreakdown.fromJson(Map<String, dynamic> json) {
    return ServiceBreakdown(
      serviceId: json['serviceId'] ?? '',
      serviceTitle: json['serviceTitle'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      bookingCount: json['bookingCount'] ?? 0,
      lastBookingDate: json['lastBookingDate'],
    );
  }
}

class EarningsChartData {
  final int monthNumber;
  final String monthName;
  final double totalAmount;

  EarningsChartData({
    required this.monthNumber,
    required this.monthName,
    required this.totalAmount,
  });

  factory EarningsChartData.fromJson(Map<String, dynamic> json) {
    return EarningsChartData(
      monthNumber: json['monthNumber'] ?? 0,
      monthName: json['monthName'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
    );
  }
}

class PaymentHistory {
  final String paymentId;
  final String serviceTitle;
  final double paymentAmount;
  final String paymentDate;

  PaymentHistory({
    required this.paymentId,
    required this.serviceTitle,
    required this.paymentAmount,
    required this.paymentDate,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      paymentId: json['paymentId'] ?? '',
      serviceTitle: json['serviceTitle'] ?? '',
      paymentAmount: (json['paymentAmount'] ?? 0.0).toDouble(),
      paymentDate: json['paymentDate'] ?? '',
    );
  }
}
