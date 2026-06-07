import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';

/// Platform legal policies (Terms of Service + Privacy Policy).
/// Mirrors the public backend endpoint `GET /settings/policies/public`.
class Policies {
  final String termsOfService;
  final String privacyPolicy;
  final String? version;
  final DateTime? lastUpdated;

  const Policies({
    required this.termsOfService,
    required this.privacyPolicy,
    this.version,
    this.lastUpdated,
  });

  factory Policies.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return Policies(
      termsOfService: (root['termsOfService'] ?? '').toString(),
      privacyPolicy: (root['privacyPolicy'] ?? '').toString(),
      version: root['version']?.toString(),
      lastUpdated: root['lastUpdated'] != null
          ? DateTime.tryParse(root['lastUpdated'].toString())
          : null,
    );
  }
}

class PolicyService {
  Future<Policies> getPolicies() async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        '/settings/policies/public',
      );
      if (raw is Map<String, dynamic>) return Policies.fromJson(raw);
      throw Exception('Unexpected response while loading policies.');
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to load policies (${e.response?.statusCode ?? 'network error'})';
      throw Exception(msg);
    }
  }
}
