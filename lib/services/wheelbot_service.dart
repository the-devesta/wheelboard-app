import 'package:dio/dio.dart';

import '../core/auth/auth_service.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../models/wheelbot_message.dart';

class WheelbotService {
  const WheelbotService();

  Future<WheelbotReply> send({
    required List<WheelbotMessage> messages,
    String? provider,
  }) async {
    try {
      final raw = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.chat.send,
        data: {
          'messages': messages.map((m) => m.toApiJson()).toList(),
          if (AuthService.to.userId.isNotEmpty) 'userId': AuthService.to.userId,
          if (provider != null) 'provider': provider,
        },
      );

      if (raw is Map) {
        return WheelbotReply.fromJson(Map<String, dynamic>.from(raw));
      }

      return const WheelbotReply(
        success: false,
        error: 'WheelBot returned an unexpected response.',
      );
    } on DioException catch (e) {
      return WheelbotReply(success: false, error: _message(e));
    } catch (e) {
      return WheelbotReply(
        success: false,
        error: 'WheelBot could not respond right now. Please try again.',
      );
    }
  }

  String _message(DioException e) {
    if (e.error is ApiException) return (e.error as ApiException).message;
    final data = e.response?.data;
    if (data is Map) {
      final error = data['error'] ?? data['message'];
      if (error is List) return error.join(', ');
      if (error != null) return error.toString();
    }
    return 'WheelBot backend is not reachable. Please check your connection.';
  }
}
