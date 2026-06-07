import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../models/learning_model.dart';

/// Learning API client — mirrors wheelboard-fe `learningApi.ts` against the
/// authoritative backend controller (`modules/learning/learning.controller.ts`).
///
/// All responses are wrapped as `{ success, data }`; [_data] unwraps that.
/// List/categories/stats/detail are public; enroll/progress/rate/my-progress/
/// certificate require auth — the bearer token is injected by [ApiClient].
class LearningService {
  /// GET /learning  (optionally filtered by category).
  Future<List<LearningModule>> getModules({String? category}) async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.learning.list,
        queryParameters: (category != null && category.isNotEmpty && category != 'all')
            ? {'category': category}
            : null,
      );
      final data = _data(raw);
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => LearningModule.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to load learning modules'));
    }
  }

  /// GET /learning/categories
  Future<List<LearningCategory>> getCategories() async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.learning.categories,
      );
      final data = _data(raw);
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => LearningCategory.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to load categories'));
    }
  }

  /// GET /learning/stats
  Future<LearningStats?> getStats() async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.learning.stats,
      );
      final data = _data(raw);
      if (data is Map) {
        return LearningStats.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } on DioException {
      return null; // stats are non-critical
    }
  }

  /// GET /learning/:id
  Future<LearningModule> getModule(String id) async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.learning.details(id),
      );
      final data = _data(raw);
      if (data is Map) {
        return LearningModule.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception('Unexpected response while loading module.');
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to load module'));
    }
  }

  /// POST /learning/:id/enroll
  Future<void> enroll(String id) async {
    try {
      await ApiClient.instance.post<dynamic>(ApiEndpoints.learning.enroll(id));
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to enroll'));
    }
  }

  /// POST /learning/:id/progress  { progress }
  Future<void> updateProgress(String id, int progress) async {
    try {
      await ApiClient.instance.post<dynamic>(
        ApiEndpoints.learning.progress(id),
        data: {'progress': progress},
      );
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to update progress'));
    }
  }

  /// POST /learning/:id/rate  { rating }
  Future<void> rate(String id, int rating) async {
    try {
      await ApiClient.instance.post<dynamic>(
        ApiEndpoints.learning.rate(id),
        data: {'rating': rating},
      );
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to submit rating'));
    }
  }

  /// GET /learning/:id/my-progress  → null when not enrolled.
  Future<LearningProgress?> getMyProgress(String id) async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.learning.myProgress(id),
      );
      final data = _data(raw);
      if (data is Map) {
        return LearningProgress.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } on DioException {
      return null; // treat fetch failure as "no progress"
    }
  }

  /// POST /learning/:id/certificate  → certificate URL.
  Future<String> getCertificate(String id) async {
    try {
      final raw = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.learning.certificate(id),
      );
      final data = _data(raw);
      if (data is Map && data['url'] != null) return data['url'].toString();
      throw Exception('Certificate URL not returned.');
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to generate certificate'));
    }
  }

  dynamic _data(dynamic raw) {
    if (raw is Map && raw.containsKey('data')) return raw['data'];
    return raw;
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
