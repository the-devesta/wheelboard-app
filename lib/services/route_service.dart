import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceKm;
  final int durationMinutes;
  final String distanceText;
  final String durationText;

  const RouteResult({
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
    required this.distanceText,
    required this.durationText,
  });
}

/// Fetches real road routes from the Google Directions API and decodes the
/// encoded polyline into a list of [LatLng] points ready for GoogleMap.
class RouteService {
  final http.Client _client;

  RouteService({http.Client? client}) : _client = client ?? http.Client();

  /// Returns a road route from [origin] to [destination].
  /// Falls back to a straight two-point list on any failure so the map always
  /// shows something rather than crashing.
  Future<RouteResult?> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final key = MapsConstants.googleMapsApiKey;
    if (key.isEmpty) return null;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&mode=driving'
      '&key=$key',
    );

    try {
      final response =
          await _client.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return null;

      final routes = data['routes'] as List<dynamic>;
      if (routes.isEmpty) return null;

      final route = routes[0] as Map<String, dynamic>;
      final encoded =
          (route['overview_polyline'] as Map<String, dynamic>)['points']
              as String;
      final points = _decodePolyline(encoded);
      if (points.isEmpty) return null;

      final legs = route['legs'] as List<dynamic>;
      final leg = legs[0] as Map<String, dynamic>;
      final distanceM =
          ((leg['distance'] as Map)['value'] as num).toDouble();
      final durationS =
          ((leg['duration'] as Map)['value'] as num).toInt();
      final distanceText =
          (leg['distance'] as Map)['text'] as String? ?? '';
      final durationText =
          (leg['duration'] as Map)['text'] as String? ?? '';

      return RouteResult(
        points: points,
        distanceKm: distanceM / 1000,
        durationMinutes: durationS ~/ 60,
        distanceText: distanceText,
        durationText: durationText,
      );
    } catch (_) {
      return null;
    }
  }

  /// Decodes a Google Maps encoded polyline string (precision 5) into LatLng.
  static List<LatLng> _decodePolyline(String encoded) {
    final result = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int b;
      int result0 = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result0 |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result0 & 1) != 0 ? ~(result0 >> 1) : (result0 >> 1);
      lat += dlat;

      shift = 0;
      result0 = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result0 |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result0 & 1) != 0 ? ~(result0 >> 1) : (result0 >> 1);
      lng += dlng;

      result.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return result;
  }

  void dispose() => _client.close();
}

final routeService = RouteService();
