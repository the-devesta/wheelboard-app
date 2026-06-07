/// Issue (support ticket) models — mirror wheelboard-fe `issuesApi.ts` and the
/// backend `modules/issues` controller.
///
/// User-facing flow: report an issue, list my issues, view an issue.
/// Status/resolution are set by admins; the app reports and tracks.
library;

/// Allowed issue categories (backend `CreateIssueDto`).
const kIssueCategories = <String>[
  'Login',
  'Payment',
  'Booking',
  'Technical',
  'Account',
  'Other',
];

/// Allowed issue priorities.
const kIssuePriorities = <String>['Low', 'Medium', 'High'];

class Issue {
  final String id;
  final String issueId;
  final String title;
  final String description;
  final String category;
  final String status; // Open | In-Process | Resolved
  final String priority; // Low | Medium | High
  final String reportedByName;
  final String reportedByEmail;
  final String? resolution;
  final DateTime? resolvedAt;
  final List<String> attachments;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Issue({
    required this.id,
    required this.issueId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    required this.reportedByName,
    required this.reportedByEmail,
    this.resolution,
    this.resolvedAt,
    this.attachments = const [],
    this.createdAt,
    this.updatedAt,
  });

  bool get isResolved => status.toLowerCase() == 'resolved';
  bool get isInProcess => status.toLowerCase() == 'in-process';
  bool get isOpen => status.toLowerCase() == 'open';

  factory Issue.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    DateTime? date(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return Issue(
      id: (root['_id'] ?? root['id'] ?? '').toString(),
      issueId: (root['issueId'] ?? '').toString(),
      title: (root['title'] ?? '').toString(),
      description: (root['description'] ?? '').toString(),
      category: (root['category'] ?? 'Other').toString(),
      status: (root['status'] ?? 'Open').toString(),
      priority: (root['priority'] ?? 'Medium').toString(),
      reportedByName: (root['reportedByName'] ?? '').toString(),
      reportedByEmail: (root['reportedByEmail'] ?? '').toString(),
      resolution: root['resolution']?.toString(),
      resolvedAt: date(root['resolvedAt']),
      attachments: root['attachments'] is List
          ? (root['attachments'] as List).map((e) => e.toString()).toList()
          : const [],
      createdAt: date(root['createdAt']),
      updatedAt: date(root['updatedAt']),
    );
  }
}

/// Payload for `POST /issues`.
class CreateIssuePayload {
  final String title;
  final String description;
  final String category;
  final String priority;

  const CreateIssuePayload({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
      };
}
