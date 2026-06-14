import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../models/lead_model.dart';

/// Leads (service-provider CRM) API client — mirrors wheelboard-fe `leadsApi.ts`
/// against `modules/leads`. The backend returns results unwrapped (raw arrays /
/// objects), which the models' `fromJson` also handles if wrapped.
class LeadService {
  Future<List<Lead>> getProviderLeads(
    String providerId, {
    String? status,
    String? source,
  }) async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.leads.providerLeads(providerId),
        queryParameters: {
          if (status != null && status.isNotEmpty && status != 'All')
            'status': status,
          if (source != null && source.isNotEmpty) 'source': source,
        },
      );
      final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Lead.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to load leads'));
    }
  }

  Future<LeadStats> getStats(String providerId) async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.leads.providerStats(providerId),
      );
      if (raw is Map<String, dynamic>) return LeadStats.fromJson(raw);
      return LeadStats.empty;
    } on DioException {
      return LeadStats.empty; // stats are non-critical
    }
  }

  Future<Lead> getLead(String id) async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.leads.details(id),
      );
      if (raw is Map<String, dynamic>) return Lead.fromJson(raw);
      throw Exception('Unexpected response while loading lead.');
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to load lead'));
    }
  }

  Future<Lead> _patch(String path, Map<String, dynamic> body, String fallback) async {
    try {
      final raw = await ApiClient.instance.patch<dynamic>(path, data: body);
      if (raw is Map<String, dynamic>) return Lead.fromJson(raw);
      throw Exception('Unexpected response.');
    } on DioException catch (e) {
      throw Exception(_msg(e, fallback));
    }
  }

  Future<Lead> updateStatus(String id, String status, {String? notes}) =>
      _patch(ApiEndpoints.leads.updateStatus(id),
          {'status': status, if (notes != null) 'notes': notes},
          'Failed to update status');

  Future<Lead> markContacted(String id, {String? notes}) =>
      _patch(ApiEndpoints.leads.contact(id),
          {if (notes != null) 'notes': notes}, 'Failed to mark contacted');

  Future<Lead> convert(String id, {String? notes}) =>
      _patch(ApiEndpoints.leads.convert(id),
          {if (notes != null) 'notes': notes}, 'Failed to convert lead');

  Future<Lead> markLost(String id, String reason) => _patch(
      ApiEndpoints.leads.lost(id), {'reason': reason}, 'Failed to mark lost');

  Future<Lead> addNotes(String id, String notes) => _patch(
      ApiEndpoints.leads.notes(id), {'notes': notes}, 'Failed to add notes');

  Future<Lead> scheduleFollowUp(String id, DateTime date) => _patch(
      ApiEndpoints.leads.followUp(id), {'date': date.toIso8601String()},
      'Failed to schedule follow-up');

  Future<void> deleteLead(String id) async {
    try {
      await ApiClient.instance.delete<dynamic>(ApiEndpoints.leads.details(id));
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to delete lead'));
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
