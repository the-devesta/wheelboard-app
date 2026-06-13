import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_logger.dart';

class MapNavigationUtils {
  const MapNavigationUtils._();

  static Future<bool> openDirections({
    LatLng? origin,
    required LatLng destination,
    String? destinationLabel,
  }) async {
    final encodedLabel = Uri.encodeComponent(
      destinationLabel?.trim().isNotEmpty == true
          ? destinationLabel!.trim()
          : '${destination.latitude},${destination.longitude}',
    );
    final destinationParam = '${destination.latitude},${destination.longitude}';
    final originParam = origin == null
        ? null
        : '${origin.latitude},${origin.longitude}';

    final candidates = <Uri>[];

    if (!kIsWeb && Platform.isIOS) {
      candidates.add(
        Uri.parse(
          'http://maps.apple.com/?daddr=$destinationParam&dirflg=d'
          '${originParam != null ? '&saddr=$originParam' : ''}',
        ),
      );
      candidates.add(
        Uri.parse(
          'comgooglemaps://?daddr=$destinationParam&directionsmode=driving'
          '${originParam != null ? '&saddr=$originParam' : ''}',
        ),
      );
    } else if (!kIsWeb && Platform.isAndroid) {
      candidates.add(Uri.parse('google.navigation:q=$destinationParam&mode=d'));
      candidates.add(Uri.parse('geo:0,0?q=$destinationParam($encodedLabel)'));
    }

    candidates.add(
      Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=$destinationParam'
        '${originParam != null ? '&origin=$originParam' : ''}'
        '&travelmode=driving',
      ),
    );

    for (final uri in candidates) {
      try {
        if (await canLaunchUrl(uri)) {
          return launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        AppLogger.w('Map launch failed for $uri: $e');
      }
    }

    AppLogger.e('No maps application could open destination $destinationParam');
    return false;
  }
}
