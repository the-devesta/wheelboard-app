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
      tripCompletionTrend: (json['tripCompletionTrend'] as List<dynamic>?)
              ?.map((e) => TripCompletionTrend.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      vehicleAvailability:
          VehicleAvailability.fromJson(json['vehicleAvailability'] ?? {}),
      topProfessionals: (json['topProfessionals'] as List<dynamic>?)
              ?.map((e) => TopProfessional.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      jobList: (json['jobList'] as List<dynamic>?)
              ?.map((e) => JobItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentTransactions: (json['recentTransactions'] as List<dynamic>?)
              ?.map((e) => RecentTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      assignedServices: (json['assignedServices'] as List<dynamic>?)
              ?.map((e) => AssignedService.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      upcomingTrips: (json['upcomingTrips'] as List<dynamic>?)
              ?.map((e) => UpcomingTrip.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TripSummary {
  final int totalTrips;
  final int scheduledToday;

  TripSummary({
    required this.totalTrips,
    required this.scheduledToday,
  });

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

  ActiveVehicles({
    required this.activeVehicles,
    required this.inMaintenance,
  });

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

  JobsSummary({
    required this.activeJobs,
    required this.unfilledJobs,
  });

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

  TripEfficiency({
    this.avgCostPerKm,
    this.totalKmPerMonth,
  });

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

  VehiclesOnLease({
    required this.total,
    required this.leasedThisWeek,
  });

  factory VehiclesOnLease.fromJson(Map<String, dynamic> json) {
    return VehiclesOnLease(
      total: json['total'] as int? ?? 0,
      leasedThisWeek: json['leasedThisWeek'] as int? ?? 0,
    );
  }
}

class TripCompletionTrend {
  final String? date;
  final int? completedTrips;

  TripCompletionTrend({
    this.date,
    this.completedTrips,
  });

  factory TripCompletionTrend.fromJson(Map<String, dynamic> json) {
    return TripCompletionTrend(
      date: json['date'] as String?,
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

  RecentTransaction({
    this.expenseType,
    this.dateEntered,
    this.amount,
  });

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
  final String? id;
  final String? route;
  final String? time;
  final String? driver;

  UpcomingTrip({
    this.id,
    this.route,
    this.time,
    this.driver,
  });

  factory UpcomingTrip.fromJson(Map<String, dynamic> json) {
    return UpcomingTrip(
      id: json['id'] as String?,
      route: json['route'] as String?,
      time: json['time'] as String?,
      driver: json['driver'] as String?,
    );
  }
}

