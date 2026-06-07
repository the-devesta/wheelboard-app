import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../models/issue_model.dart';

/// Issues (support ticket) API client — mirrors wheelboard-fe `issuesApi.ts`
/// against `modules/issues`. Responses are wrapped as `{ success, data }`.
class IssueService {
  /// POST /issues — report a new issue.
  Future<Issue> createIssue(CreateIssuePayload payload) async {
    try {
      final raw = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.issues.create,
        data: payload.toJson(),
      );
      if (raw is Map<String, dynamic>) return Issue.fromJson(raw);
      throw Exception('Unexpected response while creating issue.');
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to report issue'));
    }
  }

  /// GET /issues/my — the current user's reported issues.
  Future<List<Issue>> getMyIssues() async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.issues.myIssues,
      );
      final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Issue.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to load your issues'));
    }
  }

  /// GET /issues/:id
  Future<Issue> getIssue(String id) async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.issues.details(id),
      );
      if (raw is Map<String, dynamic>) return Issue.fromJson(raw);
      throw Exception('Unexpected response while loading issue.');
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to load issue'));
    }
  }

  String _msg(DioException e, String fallback) {
    if (e.error is ApiException) return (e.error as ApiException).message;
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      return m is List ? m.join(', ') : m.toString();
    }
    return '$fallback (${e.response?.statusCode ?? 'network error'})';
  }
}
