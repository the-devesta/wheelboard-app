import 'package:flutter/material.dart';

class ServiceAssignmentSummary {
  final String serviceId;
  final String serviceTitle;
  final String vehicleNumber;
  final DateTime scheduledDateTime;
  final TimeOfDay scheduledTime;
  final String description;
  const ServiceAssignmentSummary({
    required this.serviceId,
    required this.serviceTitle,
    required this.vehicleNumber,
    required this.scheduledDateTime,
    required this.scheduledTime,
    required this.description,
  });

  String get formattedDate {
    final monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthName = monthNames[scheduledDateTime.month - 1];
    return '$monthName ${scheduledDateTime.day}, ${scheduledDateTime.year}';
  }

  String get formattedTime {
    final hour = scheduledTime.hourOfPeriod == 0
        ? 12
        : scheduledTime.hourOfPeriod;
    final minute = scheduledTime.minute.toString().padLeft(2, '0');
    final period = scheduledTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
