class TripBid {
  final String bidId;
  final String tripId;
  final String driverId;
  final double bidAmount;
  final String bidDescription;
  final DateTime? dateEntered;
  final String name;
  final String contactNumber;

  TripBid({
    required this.bidId,
    required this.tripId,
    required this.driverId,
    required this.bidAmount,
    required this.bidDescription,
    this.dateEntered,
    required this.name,
    required this.contactNumber,
  });

  factory TripBid.fromJson(Map<String, dynamic> json) {
    return TripBid(
      bidId: json['bidId'] ?? '',
      tripId: json['tripId'] ?? '',
      driverId: json['driverId'] ?? '',
      bidAmount: (json['bidAmount'] is int)
          ? (json['bidAmount'] as int).toDouble()
          : (json['bidAmount'] as num?)?.toDouble() ?? 0.0,
      bidDescription: json['bidDescription'] ?? '',
      dateEntered: json['dateEntered'] != null && json['dateEntered'] != ""
          ? DateTime.tryParse(json['dateEntered'])
          : null,
      name: json['name'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
    );
  }
}
