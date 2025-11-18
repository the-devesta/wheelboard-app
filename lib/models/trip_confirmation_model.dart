class TripConfirmationModel {
  final String tripCode;
  final String vehicle;
  final String driver;
  final DateTime? pickupDate;
  final String pickupTime;
  final DateTime? createdDate;

  TripConfirmationModel({
    required this.tripCode,
    required this.vehicle,
    required this.driver,
    this.pickupDate,
    required this.pickupTime,
    this.createdDate,
  });

  factory TripConfirmationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is String && dateValue.isNotEmpty) {
        return DateTime.tryParse(dateValue);
      }
      return null;
    }

    String parseTime(dynamic timeValue) {
      if (timeValue == null) return '';
      if (timeValue is String) return timeValue;
      return timeValue.toString();
    }

    return TripConfirmationModel(
      tripCode: json['tripCode'] ?? '',
      vehicle: json['vehicle'] ?? '',
      driver: json['driver'] ?? '',
      pickupDate: parseDate(json['pickupDate']),
      pickupTime: parseTime(json['pickupTime']),
      createdDate: parseDate(json['createdDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripCode': tripCode,
      'vehicle': vehicle,
      'driver': driver,
      'pickupDate': pickupDate?.toIso8601String(),
      'pickupTime': pickupTime,
      'createdDate': createdDate?.toIso8601String(),
    };
  }
}

