class AssignTripBid {
  final String bidId;
  final double bidAmount;
  final String bidDescription;
  final String pickupLocation;
  final String deliveryLocation;
  final DateTime? pickupDate;
  final String pickupTime;
  final String specialInstructions;
  final String driverName;
  final String driverPhoto;
  final double platformFee;
  final double amountToDriver;
  final double totalTripCost;

  AssignTripBid({
    required this.bidId,
    required this.bidAmount,
    required this.bidDescription,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.pickupDate,
    required this.pickupTime,
    required this.specialInstructions,
    required this.driverName,
    required this.driverPhoto,
    required this.platformFee,
    required this.amountToDriver,
    required this.totalTripCost,
  });

  factory AssignTripBid.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final pickupDateValue = json['pickupDate'];
    if (pickupDateValue != null && pickupDateValue.toString().isNotEmpty) {
      parsedDate = DateTime.tryParse(pickupDateValue.toString());
    }

    double _parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.tryParse(value.toString()) ?? 0;
    }

    return AssignTripBid(
      bidId: json['bidId'] ?? '',
      bidAmount: _parseDouble(json['bidAmount']),
      bidDescription: json['bidDescription'] ?? '',
      pickupLocation: json['pickupLocation'] ?? '',
      deliveryLocation: json['deliveryLocation'] ?? '',
      pickupDate: parsedDate,
      pickupTime: json['pickupTime'] ?? '',
      specialInstructions: json['specialInstructions'] ?? '',
      driverName: json['driverName'] ?? '',
      driverPhoto: json['driverPhoto'] ?? '',
      platformFee: _parseDouble(json['platformFee']),
      amountToDriver: _parseDouble(json['amountToDriver']),
      totalTripCost: _parseDouble(json['totalTripCost']),
    );
  }
}




