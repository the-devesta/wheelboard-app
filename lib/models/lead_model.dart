/// Lead (service-provider CRM) models — mirror wheelboard-fe `leadsApi.ts` and
/// the backend `modules/leads` controller.
library;

const kLeadStatuses = <String>[
  'New',
  'Contacted',
  'Qualified',
  'Converted',
  'Lost',
];

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

class Lead {
  final String id;
  final String companyName;
  final String? companyPhone;
  final String? companyEmail;
  final String providerName;
  final String source; // Service Assignment | Direct Inquiry | Website | Referral | Other
  final String status; // New | Contacted | Qualified | Converted | Lost
  final String? serviceName;
  final String? serviceCategory;
  final double? estimatedValue;
  final String? notes;
  final String? requirements;
  final DateTime? lastContactedAt;
  final DateTime? nextFollowUpAt;
  final DateTime? convertedAt;
  final String? lostReason;
  final List<String> tags;
  final DateTime? createdAt;

  const Lead({
    required this.id,
    required this.companyName,
    this.companyPhone,
    this.companyEmail,
    required this.providerName,
    required this.source,
    required this.status,
    this.serviceName,
    this.serviceCategory,
    this.estimatedValue,
    this.notes,
    this.requirements,
    this.lastContactedAt,
    this.nextFollowUpAt,
    this.convertedAt,
    this.lostReason,
    this.tags = const [],
    this.createdAt,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    DateTime? date(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return Lead(
      id: (root['id'] ?? root['_id'] ?? '').toString(),
      companyName: (root['companyName'] ?? 'Unknown').toString(),
      companyPhone: root['companyPhone']?.toString(),
      companyEmail: root['companyEmail']?.toString(),
      providerName: (root['providerName'] ?? '').toString(),
      source: (root['source'] ?? 'Other').toString(),
      status: (root['status'] ?? 'New').toString(),
      serviceName: root['serviceName']?.toString(),
      serviceCategory: root['serviceCategory']?.toString(),
      estimatedValue: root['estimatedValue'] == null
          ? null
          : _toDouble(root['estimatedValue']),
      notes: root['notes']?.toString(),
      requirements: root['requirements']?.toString(),
      lastContactedAt: date(root['lastContactedAt']),
      nextFollowUpAt: date(root['nextFollowUpAt']),
      convertedAt: date(root['convertedAt']),
      lostReason: root['lostReason']?.toString(),
      tags: root['tags'] is List
          ? (root['tags'] as List).map((e) => e.toString()).toList()
          : const [],
      createdAt: date(root['createdAt']),
    );
  }
}

class LeadStats {
  final int total;
  final int newCount;
  final int contacted;
  final int qualified;
  final int converted;
  final int lost;
  final double conversionRate;
  final double totalValue;
  final double averageValue;

  const LeadStats({
    required this.total,
    required this.newCount,
    required this.contacted,
    required this.qualified,
    required this.converted,
    required this.lost,
    required this.conversionRate,
    required this.totalValue,
    required this.averageValue,
  });

  factory LeadStats.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return LeadStats(
      total: _toInt(root['total']),
      newCount: _toInt(root['new']),
      contacted: _toInt(root['contacted']),
      qualified: _toInt(root['qualified']),
      converted: _toInt(root['converted']),
      lost: _toInt(root['lost']),
      conversionRate: _toDouble(root['conversionRate']),
      totalValue: _toDouble(root['totalValue']),
      averageValue: _toDouble(root['averageValue']),
    );
  }

  static const empty = LeadStats(
    total: 0,
    newCount: 0,
    contacted: 0,
    qualified: 0,
    converted: 0,
    lost: 0,
    conversionRate: 0,
    totalValue: 0,
    averageValue: 0,
  );
}
