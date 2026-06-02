/// Feed models — a 1:1 Dart mirror of the backend `FeedResponse`
/// (`wheelboard-be/src/dto/feed.dto.ts`) and the FE `Feed` type
/// (`wheelboard-fe/src/lib/api.ts`).
///
/// The primary class is named [Post] for backward-compatibility with the
/// existing app screens/controllers that already reference `Post`.
library;

/// Allowed feed categories (mirrors `FeedCategory` in the backend DTO).
class FeedCategory {
  static const promotions = 'Promotions';
  static const tip = 'tip';
  static const services = 'services';
  static const question = 'question';
  static const general = 'general';

  static const all = <String>[promotions, tip, services, question, general];
}

/// Author of a feed post: `{ id, name, avatar, initials, userType, company? }`.
class FeedAuthor {
  final String id;
  final String name;
  final String avatar;
  final String initials;
  final String userType; // company | business | professional
  final String? company;

  const FeedAuthor({
    required this.id,
    required this.name,
    required this.avatar,
    required this.initials,
    required this.userType,
    this.company,
  });

  factory FeedAuthor.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? '';
    return FeedAuthor(
      id: json['id']?.toString() ?? '',
      name: name,
      avatar: json['avatar']?.toString() ?? '',
      initials: json['initials']?.toString() ?? _initialsFrom(name),
      userType: json['userType']?.toString() ?? '',
      company: json['company']?.toString(),
    );
  }

  static String _initialsFrom(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'U';
    return parts.map((p) => p[0]).take(2).join().toUpperCase();
  }
}

/// Minimal author reference embedded in a comment: `{ id, name, avatar }`.
class FeedCommentAuthor {
  final String id;
  final String name;
  final String avatar;

  const FeedCommentAuthor({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory FeedCommentAuthor.fromJson(Map<String, dynamic> json) {
    return FeedCommentAuthor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
    );
  }
}

/// A feed comment: `{ id, author{id,name,avatar}, content, createdAt, timeAgo }`.
class FeedComment {
  final String id;
  final FeedCommentAuthor author;
  final String content;
  final DateTime? createdAt;
  final String timeAgo;

  const FeedComment({
    required this.id,
    required this.author,
    required this.content,
    this.createdAt,
    this.timeAgo = '',
  });

  factory FeedComment.fromJson(Map<String, dynamic> json) {
    final authorJson = json['author'];
    return FeedComment(
      id: json['id']?.toString() ?? '',
      author: authorJson is Map<String, dynamic>
          ? FeedCommentAuthor.fromJson(authorJson)
          : const FeedCommentAuthor(id: '', name: '', avatar: ''),
      content: json['content']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt']),
      timeAgo: json['timeAgo']?.toString() ?? '',
    );
  }
}

/// A feed post — mirrors the backend `FeedResponse`.
///
/// Named [Post] for backward-compatibility with existing screens. Thin getters
/// (`userName`, `companyLogo`, `likeCount`, `imageUrls`, `postId`, `timeAgo`)
/// preserve the legacy field names some widgets still use.
class Post {
  final String id;
  final FeedAuthor author;
  final String content;
  final String? image;
  final List<String> images;
  final String category;
  final int likes;
  final bool isLiked;
  final int shares;
  final List<FeedComment> comments;
  final DateTime createdAt;
  final String serverTimeAgo;

  /// Moderation status. Public feeds are already `approved`, so this is usually
  /// empty for the app; retained for compat with the existing status badge.
  final String status;

  Post({
    required this.id,
    required this.author,
    required this.content,
    this.image,
    this.images = const [],
    required this.category,
    this.likes = 0,
    this.isLiked = false,
    this.shares = 0,
    this.comments = const [],
    required this.createdAt,
    this.serverTimeAgo = '',
    this.status = '',
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final authorJson = json['author'];
    final author = authorJson is Map<String, dynamic>
        ? FeedAuthor.fromJson(authorJson)
        // Legacy/flat fallback (older payloads without a nested author object).
        : FeedAuthor(
            id: json['companyId']?.toString() ?? '',
            name: json['userName']?.toString() ?? '',
            avatar: json['companyLogo']?.toString() ?? '',
            initials: FeedAuthor._initialsFrom(json['userName']?.toString() ?? ''),
            userType: json['userType']?.toString() ?? '',
          );

    final commentsList = json['comments'] as List<dynamic>? ?? const [];

    return Post(
      id: json['id']?.toString() ?? json['postId']?.toString() ?? '',
      author: author,
      content: json['content']?.toString() ?? '',
      image: (json['image']?.toString().isNotEmpty ?? false)
          ? json['image'].toString()
          : null,
      images: _parseImages(json['images']),
      category: json['category']?.toString() ?? '',
      likes: (json['likes'] as num?)?.toInt() ??
          (json['likeCount'] as num?)?.toInt() ??
          0,
      isLiked: json['isLiked'] as bool? ?? false,
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      comments: commentsList
          .whereType<Map<String, dynamic>>()
          .map(FeedComment.fromJson)
          .toList(),
      createdAt: _parseDate(json['createdAt'] ?? json['dateEntered']) ??
          DateTime.now(),
      serverTimeAgo: json['timeAgo']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  // ── Backward-compatibility getters (legacy field names) ───────────────────
  String get postId => id;
  String get userName => author.name;
  String? get companyId => author.id.isNotEmpty ? author.id : null;
  String? get companyLogo =>
      author.avatar.isNotEmpty ? author.avatar : null;
  int get likeCount => likes;
  int get commentCount => comments.length;
  List<String> get imageUrls => [
        if (image != null && image!.isNotEmpty) image!,
        ...images,
      ];

  String get timeAgo {
    if (serverTimeAgo.isNotEmpty) return serverTimeAgo;
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
    return 'Just now';
  }

  Post copyWith({
    String? id,
    FeedAuthor? author,
    String? content,
    String? image,
    List<String>? images,
    String? category,
    int? likes,
    bool? isLiked,
    int? shares,
    List<FeedComment>? comments,
    DateTime? createdAt,
    String? serverTimeAgo,
    String? status,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      image: image ?? this.image,
      images: images ?? this.images,
      category: category ?? this.category,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      shares: shares ?? this.shares,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      serverTimeAgo: serverTimeAgo ?? this.serverTimeAgo,
      status: status ?? this.status,
    );
  }

  static List<String> _parseImages(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    if (value is String && value.isNotEmpty) return [value];
    return [];
  }
}

/// Community statistics (`GET /feeds/stats`).
class FeedStats {
  final int totalMembers;
  final int activeDiscussions;
  final int postsThisWeek;

  const FeedStats({
    this.totalMembers = 0,
    this.activeDiscussions = 0,
    this.postsThisWeek = 0,
  });

  factory FeedStats.fromJson(Map<String, dynamic> json) {
    return FeedStats(
      totalMembers: (json['totalMembers'] as num?)?.toInt() ?? 0,
      activeDiscussions: (json['activeDiscussions'] as num?)?.toInt() ?? 0,
      postsThisWeek: (json['postsThisWeek'] as num?)?.toInt() ?? 0,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
