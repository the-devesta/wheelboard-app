import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';

/// Distance calculation result model
class DistanceResult {
  final double distanceKm;
  final String distanceText;
  final int durationMinutes;
  final String durationText;
  final String truckDurationText; // Estimated for truck (1.5x normal time)

  DistanceResult({
    required this.distanceKm,
    required this.distanceText,
    required this.durationMinutes,
    required this.durationText,
    required this.truckDurationText,
  });

  factory DistanceResult.empty() => DistanceResult(
    distanceKm: 0,
    distanceText: 'Unknown',
    durationMinutes: 0,
    durationText: 'Unknown',
    truckDurationText: 'Unknown',
  );
}

/// Service to calculate distance between two locations using Google Distance Matrix API
///
/// **API Required:** Distance Matrix API
/// **Enable at:** https://console.cloud.google.com/apis/library/distance-matrix-backend.googleapis.com
class DistanceService {
  final String apiKey;
  final http.Client client;

  DistanceService({required this.apiKey, http.Client? client})
    : client = client ?? http.Client();

  /// Calculate distance and travel time between origin and destination
  ///
  /// [origin] - Starting location (address or lat,lng)
  /// [destination] - End location (address or lat,lng)
  ///
  /// Returns [DistanceResult] with distance and duration info
  Future<DistanceResult> calculateDistance({
    required String origin,
    required String destination,
  }) async {
    if (origin.isEmpty || destination.isEmpty) {
      return DistanceResult.empty();
    }

    try {
      final encodedOrigin = Uri.encodeQueryComponent(origin);
      final encodedDestination = Uri.encodeQueryComponent(destination);

      final url =
          'https://maps.googleapis.com/maps/api/distancematrix/json'
          '?origins=$encodedOrigin'
          '&destinations=$encodedDestination'
          '&mode=driving'
          '&language=en'
          '&key=$apiKey';

      AppLogger.d('Distance API URL: $url');

      final response = await client.get(Uri.parse(url));

      if (response.statusCode != 200) {
        AppLogger.d('Distance API Error: ${response.statusCode}');
        return DistanceResult.empty();
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String?;

      if (status != 'OK') {
        AppLogger.d('Distance API Status: $status');
        AppLogger.d('Error: ${data['error_message']}');
        return DistanceResult.empty();
      }

      final rows = data['rows'] as List<dynamic>;
      if (rows.isEmpty) {
        return DistanceResult.empty();
      }

      final elements = rows[0]['elements'] as List<dynamic>;
      if (elements.isEmpty) {
        return DistanceResult.empty();
      }

      final element = elements[0] as Map<String, dynamic>;
      final elementStatus = element['status'] as String?;

      if (elementStatus != 'OK') {
        AppLogger.d('Element Status: $elementStatus');
        return DistanceResult.empty();
      }

      // Distance in meters
      final distance = element['distance'] as Map<String, dynamic>;
      final distanceMeters = (distance['value'] as num).toDouble();
      final distanceText = distance['text'] as String;

      // Duration in seconds
      final duration = element['duration'] as Map<String, dynamic>;
      final durationSeconds = (duration['value'] as num).toInt();
      final durationText = duration['text'] as String;

      // Convert to km
      final distanceKm = distanceMeters / 1000;

      // Convert to minutes
      final durationMinutes = durationSeconds ~/ 60;

      // Calculate truck duration (approximately 1.5x normal driving time)
      final truckDurationMinutes = (durationMinutes * 1.5).round();
      final truckDurationText = _formatDuration(truckDurationMinutes);

      return DistanceResult(
        distanceKm: distanceKm,
        distanceText: distanceText,
        durationMinutes: durationMinutes,
        durationText: durationText,
        truckDurationText: truckDurationText,
      );
    } catch (e) {
      AppLogger.d('Distance calculation error: $e');
      return DistanceResult.empty();
    }
  }

  /// Format duration in minutes to human readable string
  String _formatDuration(int totalMinutes) {
    if (totalMinutes < 60) {
      return '$totalMinutes min';
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours < 24) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    }

    final days = hours ~/ 24;
    final remainingHours = hours % 24;
    return '$days days ${remainingHours > 0 ? '$remainingHours hr' : ''}';
  }

  /// Dispose the HTTP client
  void dispose() {
    client.close();
  }
}

/// Global instance for easy access
/// Usage: distanceService.calculateDistance(origin: "Delhi", destination: "Mumbai")
final distanceService = DistanceService(
  apiKey: "AIzaSyDD1jdzyCZ_QhA4QpsL9qFRg38phVn8mPI",
);
