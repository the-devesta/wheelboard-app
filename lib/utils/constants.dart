import 'package:flutter/material.dart';
import 'package:wheelboard/core/config/app_environment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  /// Full API base URL including /api prefix — use for all API calls.
  static String get baseUrl => AppEnvironment.apiBaseUrl;

  /// Raw server origin without /api — use for image/asset URLs.
  static String get origin => AppEnvironment.origin;
}

class MapsConstants {
  /// Google Maps API Key loaded from .env file
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
}

class AppImages {
  static const String mechanics = 'assets/mechanics.jpeg';
  static const String driver = 'assets/truck_driver.jpeg';
  static const String service = 'assets/service_page.jpeg';
  static const String trip = 'assets/trip_post_schedule.jpg';
}

String formatDateShort(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return "-";
  }

  try {
    final dateTime = DateTime.parse(dateString);
    return "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}";
  } catch (e) {
    debugPrint('Invalid date: $dateString');
    return dateString;
  }
}

String _getMonthName(int month) {
  const months = [
    '',
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
  return months[month];
}
