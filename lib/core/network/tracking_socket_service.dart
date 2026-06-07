import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/app_environment.dart';
import '../storage/secure_session_manager.dart';
import '../../utils/app_logger.dart';

/// Realtime trip-tracking Socket.IO client — the Flutter counterpart of the web
/// `useRealtimeTracking` hook (wheelboard-fe/src/hooks/useRealtimeTracking.ts).
///
/// It speaks the EXACT same contract as the backend
/// `RealtimeTrackingGateway` (`/tracking` namespace):
///   * Auth: JWT in the `token` handshake query.
///   * Viewer: emit `subscribe:trip {tripId}`; listen `location:update`,
///     `location:current`, `tracking:stopped`.
///   * Driver: emit `tracking:start {tripId, route, destination}` once, then
///     `gps:ping {tripId, ping}` per fix, and `tracking:stop {tripId}` at the
///     end.
///
/// One instance per tracking screen / controller. Always call [dispose].
class TrackingSocketService {
  io.Socket? _socket;

  /// Fired for both `location:update` and `location:current`.
  void Function(double lat, double lng, Map<String, dynamic>? eta)? onLocation;
  void Function()? onTrackingStopped;
  void Function(bool connected)? onConnectionChange;

  bool get isConnected => _socket?.connected ?? false;

  /// Connect using the stored access token. Safe to call once per instance.
  Future<void> connect() async {
    if (_socket != null) {
      if (!(_socket!.connected)) _socket!.connect();
      return;
    }
    final token = await SecureSessionManager().getAccessToken();
    if (token == null || token.isEmpty) {
      AppLogger.e('TrackingSocket: no access token; cannot connect');
      return;
    }

    final socket = io.io(
      AppEnvironment.socketUrl, // <origin>/tracking — same as the web
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) {
      AppLogger.d('TrackingSocket connected');
      onConnectionChange?.call(true);
    });
    socket.onDisconnect((_) {
      AppLogger.d('TrackingSocket disconnected');
      onConnectionChange?.call(false);
    });
    socket.onConnectError((e) {
      AppLogger.e('TrackingSocket connect_error: $e');
      onConnectionChange?.call(false);
    });

    socket.on('location:update', _emitLocation);
    socket.on('location:current', _emitLocation);
    socket.on('tracking:stopped', (_) => onTrackingStopped?.call());

    socket.connect();
  }

  void _emitLocation(dynamic data) {
    if (data is! Map) return;
    final loc = data['location'];
    if (loc is! Map) return;
    final lat = (loc['latitude'] as num?)?.toDouble();
    final lng = (loc['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return;
    final eta = data['eta'] is Map
        ? Map<String, dynamic>.from(data['eta'] as Map)
        : null;
    onLocation?.call(lat, lng, eta);
  }

  // ── viewer ────────────────────────────────────────────────────────────────
  void subscribeTrip(String tripId) =>
      _socket?.emit('subscribe:trip', {'tripId': tripId});

  void unsubscribeTrip(String tripId) =>
      _socket?.emit('unsubscribe:trip', {'tripId': tripId});

  // ── driver ────────────────────────────────────────────────────────────────
  void startTracking({
    required String tripId,
    required Map<String, dynamic> route,
    required Map<String, dynamic> destination,
  }) {
    _socket?.emit('tracking:start', {
      'tripId': tripId,
      'route': route,
      'destination': destination,
    });
  }

  void sendPing({required String tripId, required Map<String, dynamic> ping}) {
    _socket?.emit('gps:ping', {'tripId': tripId, 'ping': ping});
  }

  void stopTracking(String tripId) =>
      _socket?.emit('tracking:stop', {'tripId': tripId});

  void dispose() {
    try {
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
  }

  /// Build the minimal `StoredRoute` the gateway needs. The gateway only reads
  /// `polyline` (for deviation/remaining-distance) and `distanceMeters`; an
  /// empty polyline is handled safely server-side (no deviation, remaining =
  /// distanceMeters), so we don't need a Google Directions polyline here.
  static Map<String, dynamic> buildStoredRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required double distanceMeters,
    required int durationSeconds,
  }) {
    return {
      'polyline': '',
      'legs': <dynamic>[],
      'distanceMeters': distanceMeters,
      'distanceText': '${(distanceMeters / 1000).round()} km',
      'durationSeconds': durationSeconds,
      'durationText': '${(durationSeconds / 60).round()} min',
      'bounds': {
        'northeast': {
          'lat': startLat > endLat ? startLat : endLat,
          'lng': startLng > endLng ? startLng : endLng,
        },
        'southwest': {
          'lat': startLat < endLat ? startLat : endLat,
          'lng': startLng < endLng ? startLng : endLng,
        },
      },
      'calculatedAt': DateTime.now().toUtc().toIso8601String(),
      'travelMode': 'DRIVING',
    };
  }
}
