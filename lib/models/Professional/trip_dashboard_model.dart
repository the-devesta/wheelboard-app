class TripDashboardModel {
  final TripSummary summary;
  final List<WeeklyTrend> weeklyTrend;

  TripDashboardModel({required this.summary, required this.weeklyTrend});

  factory TripDashboardModel.fromJson(Map<String, dynamic> json) {
    return TripDashboardModel(
      summary: TripSummary.fromJson(json['summary'] ?? {}),
      weeklyTrend: (json['weeklyTrend'] as List? ?? [])
          .map((i) => WeeklyTrend.fromJson(i))
          .toList(),
    );
  }
}

class TripSummary {
  final int completedTrips;
  final double monthlyEarnings;
  final double avgRating;

  TripSummary({
    required this.completedTrips,
    required this.monthlyEarnings,
    required this.avgRating,
  });

  factory TripSummary.fromJson(Map<String, dynamic> json) {
    return TripSummary(
      completedTrips: json['completedTrips'] ?? 0,
      monthlyEarnings: (json['monthlyEarnings'] ?? 0).toDouble(),
      avgRating: (json['avgRating'] ?? 0).toDouble(),
    );
  }
}

class WeeklyTrend {
  final String dayName;
  final int trips;
  final double earnings;
  final double distance;

  WeeklyTrend({
    required this.dayName,
    required this.trips,
    required this.earnings,
    required this.distance,
  });

  factory WeeklyTrend.fromJson(Map<String, dynamic> json) {
    return WeeklyTrend(
      dayName: json['dayName'] ?? '',
      trips: _parseInt(json['trips']),
      earnings: _parseDouble(json['earnings']),
      distance: _parseDouble(json['distance']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
