import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/app_environment.dart';
import '../storage/secure_session_manager.dart';
import '../../models/get_vehicle_model.dart';
import '../../utils/app_logger.dart';

class VehicleGpsSocketService {
  io.Socket? _socket;

  void Function(VehicleGpsPoint point)? onPoint;
  void Function(bool connected)? onConnectionChange;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connectAndSubscribe(String vehicleId) async {
    if (_socket != null) {
      if (!(_socket!.connected)) _socket!.connect();
      _socket!.emit('gps:subscribe', {'vehicleId': vehicleId});
      return;
    }

    final token = await SecureSessionManager().getAccessToken();
    if (token == null || token.isEmpty) {
      AppLogger.e('VehicleGpsSocket: no access token; cannot connect');
      return;
    }

    final socket = io.io(
      '${AppEnvironment.origin}/gps',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .setQuery({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) {
      AppLogger.d('VehicleGpsSocket connected');
      onConnectionChange?.call(true);
      socket.emit('gps:subscribe', {'vehicleId': vehicleId});
    });
    socket.onDisconnect((_) {
      AppLogger.d('VehicleGpsSocket disconnected');
      onConnectionChange?.call(false);
    });
    socket.onConnectError((e) {
      AppLogger.e('VehicleGpsSocket connect_error: $e');
      onConnectionChange?.call(false);
    });
    socket.on('gps:update', (data) {
      if (data is! Map) return;
      final point = VehicleGpsPoint.fromJson(Map<String, dynamic>.from(data));
      if (point.vehicleId != vehicleId) return;
      onPoint?.call(point);
    });

    socket.connect();
  }

  void unsubscribe(String vehicleId) {
    _socket?.emit('gps:unsubscribe', {'vehicleId': vehicleId});
  }

  void dispose() {
    try {
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
  }
}
