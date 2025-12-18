/// Vehicle Lease Application Model
/// Represents an application for a vehicle lease
class VehicleLeaseApplicationModel {
  final String applicationId;
  final String applicantId;
  final String applicantName;
  final String profileImage;
  final String role; // Driver, Fleet Owner, Agent
  final String appliedDate;
  final String leasePeriodStart;
  final String leasePeriodEnd;
  final int proposedPrice;
  final String description;
  final String status; // Pending, Approved, Rejected
  final String vehicleId;
  final String vehicleName;
  final String vehicleNumber;

  VehicleLeaseApplicationModel({
    required this.applicationId,
    required this.applicantId,
    required this.applicantName,
    required this.profileImage,
    required this.role,
    required this.appliedDate,
    required this.leasePeriodStart,
    required this.leasePeriodEnd,
    required this.proposedPrice,
    required this.description,
    required this.status,
    required this.vehicleId,
    required this.vehicleName,
    required this.vehicleNumber,
  });

  factory VehicleLeaseApplicationModel.fromJson(Map<String, dynamic> json) {
    return VehicleLeaseApplicationModel(
      applicationId: json['applicationId'] as String? ?? '',
      applicantId: json['applicantId'] as String? ?? '',
      applicantName: json['applicantName'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
      role: json['role'] as String? ?? 'Driver',
      appliedDate: json['appliedDate'] as String? ?? '',
      leasePeriodStart: json['leasePeriodStart'] as String? ?? '',
      leasePeriodEnd: json['leasePeriodEnd'] as String? ?? '',
      proposedPrice: (json['proposedPrice'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      vehicleId: json['vehicleId'] as String? ?? '',
      vehicleName: json['vehicleName'] as String? ?? '',
      vehicleNumber: json['vehicleNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'profileImage': profileImage,
      'role': role,
      'appliedDate': appliedDate,
      'leasePeriodStart': leasePeriodStart,
      'leasePeriodEnd': leasePeriodEnd,
      'proposedPrice': proposedPrice,
      'description': description,
      'status': status,
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'vehicleNumber': vehicleNumber,
    };
  }

  VehicleLeaseApplicationModel copyWith({
    String? applicationId,
    String? applicantId,
    String? applicantName,
    String? profileImage,
    String? role,
    String? appliedDate,
    String? leasePeriodStart,
    String? leasePeriodEnd,
    int? proposedPrice,
    String? description,
    String? status,
    String? vehicleId,
    String? vehicleName,
    String? vehicleNumber,
  }) {
    return VehicleLeaseApplicationModel(
      applicationId: applicationId ?? this.applicationId,
      applicantId: applicantId ?? this.applicantId,
      applicantName: applicantName ?? this.applicantName,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      appliedDate: appliedDate ?? this.appliedDate,
      leasePeriodStart: leasePeriodStart ?? this.leasePeriodStart,
      leasePeriodEnd: leasePeriodEnd ?? this.leasePeriodEnd,
      proposedPrice: proposedPrice ?? this.proposedPrice,
      description: description ?? this.description,
      status: status ?? this.status,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
    );
  }

  /// Get time ago string (e.g., "Applied 2 days ago")
  String get timeAgo {
    try {
      final now = DateTime.now();
      final applied = DateTime.parse(appliedDate);
      final difference = now.difference(applied);

      if (difference.inDays > 7) {
        final weeks = (difference.inDays / 7).floor();
        return 'Applied $weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
      } else if (difference.inDays > 0) {
        return 'Applied ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return 'Applied ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else {
        return 'Applied just now';
      }
    } catch (e) {
      return 'Applied recently';
    }
  }
}
