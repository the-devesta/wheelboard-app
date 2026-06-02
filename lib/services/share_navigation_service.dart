import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';

/// Response of `POST /share-navigation/generate`.
///
/// Mirrors web `ShareLinkResponse` from `shareNavigationApi.ts`.
class ShareLink {
  ShareLink({
    required this.token,
    required this.otp,
    required this.shareUrl,
    this.expiresAt,
  });

  final String token;
  final String otp;
  final String shareUrl;
  final DateTime? expiresAt;

  factory ShareLink.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'])
        : json;
    return ShareLink(
      token: (root['token'] ?? '').toString(),
      otp: (root['otp'] ?? '').toString(),
      shareUrl: (root['shareUrl'] ?? root['url'] ?? '').toString(),
      expiresAt: root['expiresAt'] != null
          ? DateTime.tryParse(root['expiresAt'].toString())
          : null,
    );
  }
}

/// Generates shareable navigation links for a trip.
///
/// Mirrors `wheelboard-fe generateShareLink()` →
/// `POST /share-navigation/generate { tripId }`.
class ShareNavigationService {
  Future<ShareLink> generateShareLink(String tripId) async {
    try {
      final raw = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.shareNavigation.generate,
        data: {'tripId': tripId},
      );
      if (raw is Map<String, dynamic>) {
        return ShareLink.fromJson(raw);
      }
      throw Exception('Unexpected response while generating share link.');
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : (e.response?.data is Map
              ? (e.response?.data['message']?.toString())
              : null) ??
              'Failed to generate share link (${e.response?.statusCode ?? "network error"})';
      throw Exception(msg);
    }
  }
}
