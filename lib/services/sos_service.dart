import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

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

/* -------------------------------------------------------------------------- */
/* Canonical Wheelboard SOS                                                    */
/* -------------------------------------------------------------------------- */

/// Outcome of the two SOS channels, reported independently.
///
/// Mirrors `SosDispatchResult` in `wheelboard-fe/src/lib/sos.ts` so the two
/// platforms present the same states to the user.
class SosDispatchResult {
  /// Wheelboard recorded the SOS: audit + trip timeline + fleet-owner alert.
  final bool recorded;

  /// The external emergency workflow accepted the alert.
  final bool emergencyDispatched;

  /// Why the Wheelboard record failed — already user-safe.
  final String? recordError;

  /// True when there was no active trip to attach the SOS to.
  final bool skippedNoTrip;

  const SosDispatchResult({
    required this.recorded,
    required this.emergencyDispatched,
    this.recordError,
    this.skippedNoTrip = false,
  });
}

/// Record the SOS against the trip through Wheelboard's canonical endpoint.
///
/// All SOS business logic — trip validation, audit, timeline, fleet-owner
/// notification, driver acknowledgement — lives in `TripsService.triggerSOS`
/// on the backend. This only calls it; nothing is reimplemented here.
///
/// Never throws: the caller renders a partial-failure state instead.
Future<({bool ok, String? error})> _recordCanonicalSos({
  required String tripId,
  String? message,
  double? lat,
  double? lng,
}) async {
  try {
    await ApiClient.instance.post<dynamic>(
      ApiEndpoints.trips.sos(tripId),
      data: {
        if (message != null && message.isNotEmpty) 'message': message,
        // The backend expects [longitude, latitude].
        if (lat != null && lng != null)
          'location': {
            'coordinates': [lng, lat],
          },
      },
    );
    return (ok: true, error: null);
  } on dio.DioException catch (e) {
    final status = e.response?.statusCode;
    // The backend's own business rules, surfaced plainly rather than as a
    // status code or a DioException string.
    final friendly = switch (status) {
      403 => 'Only the driver assigned to this trip can raise an SOS.',
      400 => 'This trip is not active, so it could not be recorded against it.',
      404 => 'That trip could not be found.',
      _ => 'We could not record the SOS on your trip.',
    };
    debugPrint('[SOS] ❌ canonical record failed ($status): $e');
    return (ok: false, error: friendly);
  } catch (e) {
    debugPrint('[SOS] ❌ canonical record failed: $e');
    return (ok: false, error: 'We could not record the SOS on your trip.');
  }
}

/// Trigger a full SOS: record it in Wheelboard AND alert the emergency workflow.
///
/// Both run CONCURRENTLY and are reported independently, so a webhook outage
/// can never stop the SOS being recorded, and a Wheelboard outage can never
/// stop the emergency alert going out.
///
/// [tripId] must be the SAME identity the web app sends. The backend resolves
/// either the trip code or the trip row id, but both clients now pass the trip
/// code so the platforms are indistinguishable server-side.
Future<SosDispatchResult> dispatchSos({
  String? tripId,
  String? driverName,
  String? driverPhone,
  String? message,
  double? lat,
  double? lng,
}) async {
  final hasTrip = tripId != null && tripId.isNotEmpty;

  final results = await Future.wait([
    // Without an active trip there is nothing to attach a canonical SOS to;
    // the emergency channel below still fires.
    hasTrip
        ? _recordCanonicalSos(
            tripId: tripId,
            message: message,
            lat: lat,
            lng: lng,
          )
        : Future.value((ok: false, error: null)),
    triggerSOSCall(
      tripId: tripId,
      driverName: driverName,
      driverPhone: driverPhone,
      lat: lat,
      lng: lng,
    ).then((_) => (ok: true, error: null)),
  ]);

  final record = results[0];
  final emergency = results[1];

  return SosDispatchResult(
    recorded: record.ok,
    recordError: record.error,
    skippedNoTrip: !hasTrip,
    emergencyDispatched: emergency.ok,
  );
}
