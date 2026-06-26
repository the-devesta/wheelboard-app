class DashboardModel {
  final TripSummary tripSummary;
  final ActiveVehicles activeVehicles;
  final MonthlyExpenses monthlyExpenses;
  final JobsSummary jobsSummary;
  final TripEfficiency? tripEfficiency;
  final VehiclesOnLease? vehiclesOnLease;
  final List<TripCompletionTrend> tripCompletionTrend;
  final VehicleAvailability vehicleAvailability;
  final List<TopProfessional> topProfessionals;
  final List<JobItem> jobList;
  final List<RecentTransaction> recentTransactions;
  final List<AssignedService> assignedServices;
  final List<UpcomingTrip> upcomingTrips;

  DashboardModel({
    required this.tripSummary,
    required this.activeVehicles,
    required this.monthlyExpenses,
    required this.jobsSummary,
    this.tripEfficiency,
    this.vehiclesOnLease,
    required this.tripCompletionTrend,
    required this.vehicleAvailability,
    required this.topProfessionals,
    required this.jobList,
    required this.recentTransactions,
    required this.assignedServices,
    required this.upcomingTrips,
  });

  /// Returns a copy with the given fields replaced. Used to merge authoritative
  /// fleet data (from GET /fleet/summary) over the /dashboard/stats payload so
  /// the vehicle cards always match the Fleet page.
  DashboardModel copyWith({
    TripSummary? tripSummary,
    ActiveVehicles? activeVehicles,
    MonthlyExpenses? monthlyExpenses,
    JobsSummary? jobsSummary,
    TripEfficiency? tripEfficiency,
    VehiclesOnLease? vehiclesOnLease,
    List<TripCompletionTrend>? tripCompletionTrend,
    VehicleAvailability? vehicleAvailability,
    List<TopProfessional>? topProfessionals,
    List<JobItem>? jobList,
    List<RecentTransaction>? recentTransactions,
    List<AssignedService>? assignedServices,
    List<UpcomingTrip>? upcomingTrips,
  }) {
    return DashboardModel(
      tripSummary: tripSummary ?? this.tripSummary,
      activeVehicles: activeVehicles ?? this.activeVehicles,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      jobsSummary: jobsSummary ?? this.jobsSummary,
      tripEfficiency: tripEfficiency ?? this.tripEfficiency,
      vehiclesOnLease: vehiclesOnLease ?? this.vehiclesOnLease,
      tripCompletionTrend: tripCompletionTrend ?? this.tripCompletionTrend,
      vehicleAvailability: vehicleAvailability ?? this.vehicleAvailability,
      topProfessionals: topProfessionals ?? this.topProfessionals,
      jobList: jobList ?? this.jobList,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      assignedServices: assignedServices ?? this.assignedServices,
      upcomingTrips: upcomingTrips ?? this.upcomingTrips,
    );
  }

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      tripSummary: TripSummary.fromJson(json['tripSummary'] ?? {}),
      activeVehicles: ActiveVehicles.fromJson(json['activeVehicles'] ?? {}),
      monthlyExpenses: MonthlyExpenses.fromJson(json['monthlyExpenses'] ?? {}),
      jobsSummary: JobsSummary.fromJson(json['jobsSummary'] ?? {}),
      tripEfficiency: json['tripEfficiency'] != null
          ? TripEfficiency.fromJson(json['tripEfficiency'])
          : null,
      vehiclesOnLease: json['vehiclesOnLease'] != null
          ? VehiclesOnLease.fromJson(json['vehiclesOnLease'])
          : null,
      tripCompletionTrend:
          (json['tripCompletionTrend'] as List<dynamic>?)
              ?.map(
                (e) => TripCompletionTrend.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      vehicleAvailability: VehicleAvailability.fromJson(
        json['vehicleAvailability'] ?? {},
      ),
      topProfessionals:
          (json['topProfessionals'] as List<dynamic>?)
              ?.map((e) => TopProfessional.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      jobList:
          (json['jobList'] as List<dynamic>?)
              ?.map((e) => JobItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentTransactions:
          (json['recentTransactions'] as List<dynamic>?)
              ?.map(
                (e) => RecentTransaction.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      assignedServices:
          (json['assignedServices'] as List<dynamic>?)
              ?.map((e) => AssignedService.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      upcomingTrips:
          (json['upcomingTrips'] as List<dynamic>?)
              ?.map((e) => UpcomingTrip.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Maps the web `GET /dashboard/stats` (fleet-owner, JWT-scoped) response —
  /// i.e. `wheelboard-fe/src/lib/dashboardApi.ts` `DashboardData` — into this
  /// model so the existing dashboard UI renders correct, user-scoped data.
  ///
  /// The web stats payload is:
  ///   { stats: { activeTrips, monthlyExpenses, totalTrips, totalVehicles },
  ///     vehicleAvailability, expenseOverview, recentTransactions,
  ///     tripCompletionTrend, upcomingTrips }
  ///
  /// Sections the web dashboard does not provide (jobsSummary, jobList,
  /// topProfessionals, assignedServices, vehiclesOnLease, tripEfficiency)
  /// default to empty/null — the existing widgets already guard for that.
  factory DashboardModel.fromStats(Map<String, dynamic> json) {
    final stats = (json['stats'] as Map<String, dynamic>?) ?? const {};
    final activeTrips = (stats['activeTrips'] as Map<String, dynamic>?) ?? const {};
    final monthlyExp = (stats['monthlyExpenses'] as Map<String, dynamic>?) ?? const {};
    final totalTrips = (stats['totalTrips'] as Map<String, dynamic>?) ?? const {};
    final totalVehicles =
        (stats['totalVehicles'] as Map<String, dynamic>?) ?? const {};
    final availability =
        (json['vehicleAvailability'] as Map<String, dynamic>?) ?? const {};
    final expenseOverview =
        (json['expenseOverview'] as Map<String, dynamic>?) ?? const {};

    // Web sends only the highest-spending category *name* in
    // monthlyExpenses.highestSpending; derive the amount from the categories.
    double highestCategoryAmount = 0;
    for (final c in (expenseOverview['categories'] as List<dynamic>?) ?? const []) {
      final amt = ((c as Map<String, dynamic>)['amount'] as num?)?.toDouble() ?? 0;
      if (amt > highestCategoryAmount) highestCategoryAmount = amt;
    }

    final onTrip = (availability['onTrip'] as num?)?.toInt() ?? 0;

    // Total fleet vehicles the owner has added (backend: stats.totalVehicles.value
    // === vehicleAvailability.total). The "Active Vehicles" card previously showed
    // `onTrip`, which is 0 whenever no vehicle is mid-trip — hence "0 active
    // vehicles" even after adding vehicles. It must reflect the real count.
    final totalVehiclesValue = (totalVehicles['value'] as num?)?.toInt() ??
        (availability['total'] as num?)?.toInt() ??
        0;
    final availableVehicles = (availability['available'] as num?)?.toInt() ??
        (totalVehicles['available'] as num?)?.toInt() ??
        (totalVehiclesValue - onTrip).clamp(0, totalVehiclesValue);

    return DashboardModel(
      tripSummary: TripSummary(
        // "Active Trips" card → the active count (was wrongly the total-trips
        // count). Falls back to the total when the backend omits activeTrips.
        totalTrips: (activeTrips['value'] as num?)?.toInt() ??
            (totalTrips['value'] as num?)?.toInt() ??
            0,
        scheduledToday: (activeTrips['scheduledToday'] as num?)?.toInt() ?? 0,
      ),
      activeVehicles: ActiveVehicles(
        activeVehicles: totalVehiclesValue,
        inMaintenance: 0,
      ),
      monthlyExpenses: MonthlyExpenses(
        totalExpenses: (expenseOverview['total'] as num?)?.toDouble() ??
            (monthlyExp['value'] as num?)?.toDouble() ??
            0.0,
        highestFuelAmount: highestCategoryAmount,
      ),
      // Fleet-owner jobs now come from /dashboard/stats (`jobs:{total,active}`).
      jobsSummary: JobsSummary(
        activeJobs:
            ((json['jobs'] as Map<String, dynamic>?)?['active'] as num?)
                    ?.toInt() ??
                0,
        unfilledJobs:
            ((json['jobs'] as Map<String, dynamic>?)?['total'] as num?)
                    ?.toInt() ??
                0,
      ),
      // Trip efficiency (₹/km + km this month) now provided by /dashboard/stats.
      tripEfficiency: json['tripEfficiency'] != null
          ? TripEfficiency.fromJson(
              json['tripEfficiency'] as Map<String, dynamic>,
            )
          : null,
      vehiclesOnLease: null,
      tripCompletionTrend:
          ((json['tripCompletionTrend'] as List<dynamic>?) ?? const []).map((e) {
        final m = e as Map<String, dynamic>;
        return TripCompletionTrend(
          dayName: m['day'] as String?,
          completedTrips: (m['trips'] as num?)?.toInt() ?? 0,
        );
      }).toList(),
      vehicleAvailability: VehicleAvailability(
        available: availableVehicles,
        onTrip: onTrip,
        onRent: 0,
      ),
      topProfessionals: const [],
      jobList: const [],
      recentTransactions:
          ((json['recentTransactions'] as List<dynamic>?) ?? const []).map((e) {
        final m = e as Map<String, dynamic>;
        return RecentTransaction(
          expenseType: (m['type'] ?? m['description']) as String?,
          dateEntered: m['date'] as String?,
          amount: (m['amount'] as num?)?.toDouble(),
        );
      }).toList(),
      assignedServices: const [],
      upcomingTrips:
          ((json['upcomingTrips'] as List<dynamic>?) ?? const []).map((e) {
        final m = e as Map<String, dynamic>;
        return UpcomingTrip(
          tripId: m['id']?.toString(),
          tripCode: m['title'] as String?,
          pickupLocation: m['route'] as String?,
          deliveryLocation: null,
          pickupDate: null,
          pickupTime: m['time'] as String?,
          driverName: m['driver'] as String?,
        );
      }).toList(),
    );
  }
}

class TripSummary {
  final int totalTrips;
  final int scheduledToday;

  TripSummary({required this.totalTrips, required this.scheduledToday});

  factory TripSummary.fromJson(Map<String, dynamic> json) {
    return TripSummary(
      totalTrips: json['totalTrips'] as int? ?? 0,
      scheduledToday: json['scheduledToday'] as int? ?? 0,
    );
  }
}

class ActiveVehicles {
  final int activeVehicles;
  final int inMaintenance;

  ActiveVehicles({required this.activeVehicles, required this.inMaintenance});

  factory ActiveVehicles.fromJson(Map<String, dynamic> json) {
    return ActiveVehicles(
      activeVehicles: json['activeVehicles'] as int? ?? 0,
      inMaintenance: json['inMaintenance'] as int? ?? 0,
    );
  }
}

class MonthlyExpenses {
  final double totalExpenses;
  final double highestFuelAmount;

  MonthlyExpenses({
    required this.totalExpenses,
    required this.highestFuelAmount,
  });

  factory MonthlyExpenses.fromJson(Map<String, dynamic> json) {
    return MonthlyExpenses(
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      highestFuelAmount: (json['highestFuelAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class JobsSummary {
  final int activeJobs;
  final int unfilledJobs;

  JobsSummary({required this.activeJobs, required this.unfilledJobs});

  factory JobsSummary.fromJson(Map<String, dynamic> json) {
    return JobsSummary(
      activeJobs: json['activeJobs'] as int? ?? 0,
      unfilledJobs: json['unfilledJobs'] as int? ?? 0,
    );
  }
}

class TripEfficiency {
  final double? avgCostPerKm;
  final double? totalKmPerMonth;

  TripEfficiency({this.avgCostPerKm, this.totalKmPerMonth});

  factory TripEfficiency.fromJson(Map<String, dynamic> json) {
    return TripEfficiency(
      avgCostPerKm: (json['avgCostPerKm'] as num?)?.toDouble(),
      totalKmPerMonth: (json['totalKmPerMonth'] as num?)?.toDouble(),
    );
  }
}

class VehiclesOnLease {
  final int total;
  final int leasedThisWeek;

  VehiclesOnLease({required this.total, required this.leasedThisWeek});

  factory VehiclesOnLease.fromJson(Map<String, dynamic> json) {
    return VehiclesOnLease(
      total: json['total'] as int? ?? 0,
      leasedThisWeek: json['leasedThisWeek'] as int? ?? 0,
    );
  }
}

class TripCompletionTrend {
  final String? dayName;
  final int? completedTrips;

  TripCompletionTrend({this.dayName, this.completedTrips});

  factory TripCompletionTrend.fromJson(Map<String, dynamic> json) {
    return TripCompletionTrend(
      dayName: json['dayName'] as String?,
      completedTrips: json['completedTrips'] as int? ?? 0,
    );
  }
}

class VehicleAvailability {
  final int available;
  final int onTrip;
  final int onRent;

  VehicleAvailability({
    required this.available,
    required this.onTrip,
    required this.onRent,
  });

  factory VehicleAvailability.fromJson(Map<String, dynamic> json) {
    return VehicleAvailability(
      available: json['available'] as int? ?? 0,
      onTrip: json['onTrip'] as int? ?? 0,
      onRent: json['onRent'] as int? ?? 0,
    );
  }
}

class TopProfessional {
  final String fullName;
  final String professionalType;
  final String city;
  final String driverImagePath;

  TopProfessional({
    required this.fullName,
    required this.professionalType,
    required this.city,
    required this.driverImagePath,
  });

  factory TopProfessional.fromJson(Map<String, dynamic> json) {
    return TopProfessional(
      fullName: json['fullName'] as String? ?? '',
      professionalType: json['professionalType'] as String? ?? '',
      city: json['city'] as String? ?? '',
      driverImagePath: json['driverImagePath'] as String? ?? '',
    );
  }
}

class JobItem {
  final String? jobId;
  final String? role;
  final String? jobDuration;
  final int? openings;
  final double? salary;
  final String? city;
  final String? jobType;
  final String? description;
  final int? applicants;
  final int? likeCount;

  JobItem({
    this.jobId,
    this.role,
    this.jobDuration,
    this.openings,
    this.salary,
    this.city,
    this.jobType,
    this.description,
    this.applicants,
    this.likeCount,
  });

  factory JobItem.fromJson(Map<String, dynamic> json) {
    return JobItem(
      jobId: json['jobId'] as String?,
      role: json['role'] as String?,
      jobDuration: json['jobDuration'] as String?,
      openings: json['openings'] as int?,
      salary: (json['salary'] as num?)?.toDouble(),
      city: json['city'] as String?,
      jobType: json['jobType'] as String?,
      description: json['description'] as String?,
      applicants: json['applicants'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
    );
  }
}

class RecentTransaction {
  final String? expenseType;
  final String? dateEntered;
  final double? amount;

  RecentTransaction({this.expenseType, this.dateEntered, this.amount});

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      expenseType: json['expenseType'] as String?,
      dateEntered: json['dateEntered'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
    );
  }
}

class AssignedService {
  final String? serviceId;
  final String? serviceTitle;
  final String? category;
  final String? dateModified;

  AssignedService({
    this.serviceId,
    this.serviceTitle,
    this.category,
    this.dateModified,
  });

  factory AssignedService.fromJson(Map<String, dynamic> json) {
    return AssignedService(
      serviceId: json['serviceId'] as String?,
      serviceTitle: json['serviceTitle'] as String?,
      category: json['category'] as String?,
      dateModified: json['dateModified'] as String?,
    );
  }
}

class UpcomingTrip {
  final String? tripId;
  final String? tripCode;
  final String? pickupLocation;
  final String? deliveryLocation;
  final String? pickupDate;
  final String? pickupTime;
  final String? driverName;

  UpcomingTrip({
    this.tripId,
    this.tripCode,
    this.pickupLocation,
    this.deliveryLocation,
    this.pickupDate,
    this.pickupTime,
    this.driverName,
  });

  factory UpcomingTrip.fromJson(Map<String, dynamic> json) {
    return UpcomingTrip(
      tripId: json['tripId'] as String?,
      tripCode: json['tripCode'] as String?,
      pickupLocation: json['pickupLocation'] as String?,
      deliveryLocation: json['deliveryLocation'] as String?,
      pickupDate: json['pickupDate'] as String?,
      pickupTime: json['pickupTime'] as String?,
      driverName: json['driverName'] as String?,
    );
  }
}
