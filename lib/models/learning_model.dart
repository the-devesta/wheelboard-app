/// Learning module models — mirror wheelboard-be
/// `src/modules/learning/learning.service.ts` (`LearningModuleResponse`,
/// category/stats DTOs and the user-progress response).
library;

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

/// A learning module. The user-specific fields (`progress`, `isCompleted`,
/// `isEnrolled`, `userRating`) are only populated when the backend has the
/// caller's progress; otherwise they default to "not started".
class LearningModule {
  final String id;
  final String title;
  final String description;
  final String category;
  final String duration;
  final String? thumbnail;
  final String contentType; // video | article
  final String? videoUrl;
  final String? articleContent;
  final String? articleUrl;
  final int totalLessons;
  final List<String> tags;
  final String difficulty; // beginner | intermediate | advanced
  final String? instructor;
  final double rating;
  final int enrolledCount;
  final bool isActive;
  final int sortOrder;

  // User-specific (merged from progress)
  final int progress;
  final bool isCompleted;
  final bool isEnrolled;
  final double userRating;

  const LearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    this.thumbnail,
    required this.contentType,
    this.videoUrl,
    this.articleContent,
    this.articleUrl,
    required this.totalLessons,
    required this.tags,
    required this.difficulty,
    this.instructor,
    required this.rating,
    required this.enrolledCount,
    this.isActive = true,
    this.sortOrder = 0,
    this.progress = 0,
    this.isCompleted = false,
    this.isEnrolled = false,
    this.userRating = 0,
  });

  bool get isArticle => contentType == 'article';
  bool get isInProgress => progress > 0 && !isCompleted;

  factory LearningModule.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    return LearningModule(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      duration: (json['duration'] ?? '').toString(),
      thumbnail: json['thumbnail']?.toString(),
      contentType: (json['contentType'] ?? 'video').toString(),
      videoUrl: json['videoUrl']?.toString(),
      articleContent: json['articleContent']?.toString(),
      articleUrl: json['articleUrl']?.toString(),
      totalLessons: _toInt(json['totalLessons']),
      tags: rawTags is List
          ? rawTags.map((e) => e.toString()).toList()
          : const [],
      difficulty: (json['difficulty'] ?? 'beginner').toString(),
      instructor: json['instructor']?.toString(),
      rating: _toDouble(json['rating']),
      enrolledCount: _toInt(json['enrolledCount']),
      isActive: json['isActive'] != false,
      sortOrder: _toInt(json['sortOrder']),
      progress: _toInt(json['userProgress'] ?? json['progress']),
      isCompleted: json['isCompleted'] == true,
      isEnrolled: json['isEnrolled'] == true,
      userRating: _toDouble(json['userRating']),
    );
  }

  LearningModule copyWith({
    int? progress,
    bool? isCompleted,
    bool? isEnrolled,
    double? userRating,
    int? enrolledCount,
  }) {
    return LearningModule(
      id: id,
      title: title,
      description: description,
      category: category,
      duration: duration,
      thumbnail: thumbnail,
      contentType: contentType,
      videoUrl: videoUrl,
      articleContent: articleContent,
      articleUrl: articleUrl,
      totalLessons: totalLessons,
      tags: tags,
      difficulty: difficulty,
      instructor: instructor,
      rating: rating,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      isActive: isActive,
      sortOrder: sortOrder,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      userRating: userRating ?? this.userRating,
    );
  }

  /// Merge a [LearningProgress] (from `GET /learning/:id/my-progress`).
  LearningModule mergeProgress(LearningProgress? p) {
    if (p == null) return copyWith(isEnrolled: false);
    return copyWith(
      progress: p.progress,
      isCompleted: p.isCompleted,
      isEnrolled: true,
      userRating: p.rating,
    );
  }
}

/// A learning category with its module count (backend `LearningCategoryDto`).
class LearningCategory {
  final String id;
  final String name;
  final String icon;
  final String color;
  final int count;

  const LearningCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
  });

  factory LearningCategory.fromJson(Map<String, dynamic> json) =>
      LearningCategory(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        icon: (json['icon'] ?? '📚').toString(),
        color: (json['color'] ?? '#F36969').toString(),
        count: _toInt(json['count']),
      );
}

/// Aggregate learning statistics (backend `LearningStatsDto`).
class LearningStats {
  final int totalModules;
  final int activeModules;
  final int categoriesCount;
  final Map<String, int> byCategory;
  final Map<String, int> byDifficulty;

  const LearningStats({
    required this.totalModules,
    required this.activeModules,
    required this.categoriesCount,
    required this.byCategory,
    required this.byDifficulty,
  });

  factory LearningStats.fromJson(Map<String, dynamic> json) {
    Map<String, int> toMap(dynamic v) {
      if (v is Map) {
        return v.map((k, val) => MapEntry(k.toString(), _toInt(val)));
      }
      return {};
    }

    return LearningStats(
      totalModules: _toInt(json['totalModules']),
      activeModules: _toInt(json['activeModules']),
      categoriesCount: _toInt(json['categoriesCount']),
      byCategory: toMap(json['byCategory']),
      byDifficulty: toMap(json['byDifficulty']),
    );
  }
}

/// The caller's progress for a single module
/// (backend `GET /learning/:id/my-progress`).
class LearningProgress {
  final int progress;
  final bool isCompleted;
  final double rating;
  final DateTime? lastWatchedAt;
  final DateTime? enrolledAt;

  const LearningProgress({
    required this.progress,
    required this.isCompleted,
    required this.rating,
    this.lastWatchedAt,
    this.enrolledAt,
  });

  factory LearningProgress.fromJson(Map<String, dynamic> json) =>
      LearningProgress(
        progress: _toInt(json['progress']),
        isCompleted: json['isCompleted'] == true,
        rating: _toDouble(json['rating']),
        lastWatchedAt: json['lastWatchedAt'] != null
            ? DateTime.tryParse(json['lastWatchedAt'].toString())
            : null,
        enrolledAt: json['enrolledAt'] != null
            ? DateTime.tryParse(json['enrolledAt'].toString())
            : null,
      );
}
