import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'app_logger.dart';

class Suggestion {
  final String placeId;
  final String description;
  final String sector;
  final String city;
  final String state;
  final String country;
  final String subTitle;

  Suggestion({
    required this.placeId,
    required this.description,
    required this.sector,
    required this.city,
    required this.state,
    required this.country,
    required this.subTitle,
  });

  /// Create Suggestion from the `prediction` object returned by Places Autocomplete
  factory Suggestion.fromPrediction(Map<String, dynamic> p) {
    final terms = (p['terms'] as List<dynamic>?) ?? [];

    // Improved term extraction
    final sector = _getTerm(terms, 4);
    final city = _getTerm(terms, 3);
    final state = _getTerm(terms, 2);
    final country = _getTerm(terms, 1);

    final parts = [
      if (sector.isNotEmpty) sector,
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
    ];
    final subTitle =
        (parts.join(', ') + (country.isNotEmpty ? ', $country' : '')).trim();

    return Suggestion(
      placeId: p['place_id'] as String? ?? '',
      description: (p['description'] as String? ?? '').trim(),
      sector: sector,
      city: city,
      state: state,
      country: country,
      subTitle: subTitle,
    );
  }

  static String _getTerm(List<dynamic> terms, int indexFromEnd) {
    final index = terms.length - indexFromEnd;
    if (index >= 0 && index < terms.length) {
      final val = terms[index];
      if (val is Map && val['value'] != null) return val['value'] as String;
    }
    return '';
  }

  @override
  String toString() =>
      'Suggestion(description: $description, subTitle: $subTitle)';
}

class PlacesService {
  final String apiKey;
  final http.Client client;
  String? _sessionToken;
  final _uuid = const Uuid();

  PlacesService({required this.apiKey, http.Client? client})
    : client = client ?? http.Client();

  /// Start a new session for typing
  void startNewSession() {
    _sessionToken = _uuid.v4();
    AppLogger.d('🗺️ New Places session started: $_sessionToken');
  }

  Future<List<Suggestion>> fetchSuggestions(String input) async {
    if (input.isEmpty) return [];

    if (_sessionToken == null) startNewSession();

    final encoded = Uri.encodeQueryComponent(input);
    final requestUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=$encoded'
        '&types=geocode'
        '&language=en'
        '&components=country:in'
        '&sessiontoken=$_sessionToken'
        '&key=$apiKey';

    try {
      AppLogger.d('🗺️ Fetching suggestions for: "$input"');

      final response = await client
          .get(Uri.parse(requestUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        AppLogger.e('❌ Places API HTTP Error: ${response.statusCode}');
        return [];
      }

      final Map<String, dynamic> result = json.decode(response.body);
      final status = result['status'] as String? ?? 'UNKNOWN';

      if (status == 'OK') {
        final preds = result['predictions'] as List<dynamic>;
        return preds
            .map((p) => Suggestion.fromPrediction(p as Map<String, dynamic>))
            .toList();
      } else if (status == 'ZERO_RESULTS') {
        return [];
      } else {
        AppLogger.e('❌ Places API Error: ${result['error_message'] ?? status}');
        return [];
      }
    } catch (e) {
      AppLogger.e('❌ Places API Exception: $e');
      return [];
    }
  }

  /// Optional: get lat/lng for a placeId using Place Details API
  Future<Map<String, double>?> fetchPlaceLocation(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=${Uri.encodeQueryComponent(placeId)}'
        '&fields=geometry'
        '&sessiontoken=$_sessionToken'
        '&key=$apiKey';

    try {
      final resp = await client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode != 200) {
        AppLogger.e('❌ Place Details HTTP Error: ${resp.statusCode}');
        return null;
      }

      final Map<String, dynamic> body = json.decode(resp.body);
      final status = body['status'] as String?;

      if (status == 'OK') {
        final loc =
            body['result']['geometry']['location'] as Map<String, dynamic>;
        // Reset session token after a selection is completed
        _sessionToken = null;
        return {
          'lat': (loc['lat'] as num).toDouble(),
          'lng': (loc['lng'] as num).toDouble(),
        };
      } else {
        AppLogger.e(
          '❌ Place Details API Error: ${body['error_message'] ?? status}',
        );
        return null;
      }
    } catch (e) {
      AppLogger.e('❌ Place Details Exception: $e');
      return null;
    }
  }
}
