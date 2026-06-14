class ServiceEarningsModel {
  final double totalEarnings;
  final double cashEarnings;
  final int completedBookings;
  final List<ServiceBreakdown> serviceBreakdown;
  final List<EarningsChartData> earningsChart;
  final List<PaymentHistory> paymentHistory;

  ServiceEarningsModel({
    required this.totalEarnings,
    this.cashEarnings = 0.0,
    this.completedBookings = 0,
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
      completedBookings:
          ((json['completedBookings'] ?? json['completedJobs'] ?? 0) as num).toInt(),
      serviceBreakdown: (json['serviceBreakdown'] as List? ?? [])
          .map((i) => ServiceBreakdown.fromJson(i))
          .toList(),
      // Backend returns `timeSeriesData`; older builds used `earningsChart`.
      earningsChart: ((json['earningsChart'] ?? json['timeSeriesData']) as List? ?? [])
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
    // Backend earnings analytics groups by category:
    // { serviceCategory, earnings, bookings }.
    return ServiceBreakdown(
      serviceId: json['serviceId'] ?? '',
      serviceTitle: json['serviceTitle'] ?? json['serviceCategory'] ?? '',
      totalAmount: ((json['totalAmount'] ?? json['earnings'] ?? 0) as num).toDouble(),
      bookingCount: ((json['bookingCount'] ?? json['bookings'] ?? 0) as num).toInt(),
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
    // timeSeriesData uses { date, earnings }; older builds used
    // { monthNumber, monthName, totalAmount }.
    return EarningsChartData(
      monthNumber: ((json['monthNumber'] ?? 0) as num).toInt(),
      monthName: (json['monthName'] ?? json['date'] ?? '').toString(),
      totalAmount: ((json['totalAmount'] ?? json['earnings'] ?? 0) as num).toDouble(),
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
    // `/services/payments/my` (mapManualPayment) uses id / serviceName /
    // purposeOfPayment; keep the older keys as fallbacks.
    return PaymentHistory(
      paymentId: (json['paymentId'] ?? json['id'] ?? '').toString(),
      serviceTitle: (json['serviceTitle'] ??
              json['serviceName'] ??
              json['purposeOfPayment'] ??
              'Payment')
          .toString(),
      paymentAmount: ((json['paymentAmount'] ?? 0) as num).toDouble(),
      paymentDate: (json['paymentDate'] ?? json['createdDate'] ?? '').toString(),
    );
  }
}
