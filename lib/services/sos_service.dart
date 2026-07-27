import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// SOS emergency webhook.
///
/// Single implementation used by EVERY SOS trigger in the app, mirroring the
/// web helper in `wheelboard-fe/src/lib/sos.ts` so both platforms send an
/// identical payload to the same workflow.
///
/// Fired directly from the client (not via the Wheelboard backend) so an
/// emergency alert still goes out if our own API is unreachable.
const String sosWebhookUrl =
    'https://n8n.srv1694525.hstgr.cloud/webhook/sos-call';

/// Notify the emergency workflow that a driver has triggered SOS.
///
/// Never throws: an SOS press must not be blocked by a network problem, so all
/// failures are logged and swallowed. Callers can dial/update UI immediately.
///
/// [lat]/[lng] may be null when location permission was denied — the
/// coordinates are then omitted from the payload rather than sent as nulls,
/// matching the web helper (where `JSON.stringify` drops undefined values).
Future<void> triggerSOSCall({
  String? tripId,
  String? driverName,
  String? driverPhone,
  double? lat,
  double? lng,
}) async {
  try {
    final location = <String, dynamic>{
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    };

    final body = jsonEncode({
      'tripId': tripId ?? '',
      'driver_name': (driverName == null || driverName.isEmpty)
          ? 'Unknown Driver'
          : driverName,
      'driver_phone': driverPhone,
      'location': location,
    });

    debugPrint('[SOS] 📤 Sending POST → $sosWebhookUrl');
    debugPrint('[SOS] 📦 Payload: $body');

    final webhookResponse = await http.post(
      Uri.parse(sosWebhookUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    debugPrint('[SOS] SOS Webhook Status: ${webhookResponse.statusCode}');
    debugPrint('[SOS] SOS Webhook Response: ${webhookResponse.body}');

    final ok =
        webhookResponse.statusCode >= 200 && webhookResponse.statusCode < 300;
    if (!ok) {
      debugPrint('[SOS] ❌ Failed to trigger SOS on server side.');
    }
  } catch (error, stackTrace) {
    // Webhook failure must never block the emergency call.
    debugPrint('[SOS] ❌ SOS Webhook Network Error: $error');
    debugPrint('[SOS] 🔍 Stack trace: $stackTrace');
  }
}
