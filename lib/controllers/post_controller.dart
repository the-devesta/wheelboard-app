import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;

class PostController extends GetxController {
  var isLoading = false.obs;
  var posts = <Post>[].obs;
  var isCreatingPost = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserPosts();
  }

  /// Create a new post
  Future<bool> createPost({
    required String content,
    required String category,
    List<File>? images,
    String? partnerId,
  }) async {
    try {
      isCreatingPost.value = true;

      final authService = AuthService.to;
      final userId = authService.currentUserId;
      final token = authService.currentToken;

      if (userId.isEmpty || token.isEmpty) {
        Get.snackbar("Error", "Please login to create a post");
        return false;
      }

      // Prepare fields
      Map<String, String?> fields = {
        'UserId': userId,
        'Content': content,
        'Category': category,
        'CreatedBy': userId,
        'PartnerId': partnerId ?? '0',
      };

      // If no images, create post without multipart
      if (images == null || images.isEmpty) {
        // Create post without images using regular POST
        final response = await HttpHelper.postData(
          endpoint: API.createPost,
          data: {
            'UserId': userId,
            'Content': content,
            'Category': category,
            'Images': '', // Empty string for no images
            'CreatedBy': userId,
            'PartnerId': partnerId ?? '0',
          },
          headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['message'] != null &&
              data['message'].contains('successfully')) {
            Get.snackbar("Success", "Post created successfully!");
            await fetchUserPosts(); // Refresh posts
            return true;
          }
        }
        Get.snackbar("Error", "Failed to create post: ${response.statusCode}");
        return false;
      } else {
        // Create post with images using multipart
        final streamedResponse = await HttpHelper.uploadMultipart(
          endpoint: API.createPost,
          fields: fields,
          files: images,
          fieldKey: 'Images', // Field name for images
          headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
        );

        final response = await http.Response.fromStream(streamedResponse);

        print("📝 Post creation response status: ${response.statusCode}");
        print("📝 Post creation response body: ${response.body}");

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['message'] != null &&
              data['message'].contains('successfully')) {
            Get.snackbar("Success", "Post created successfully!");
            await fetchUserPosts(); // Refresh posts
            return true;
          }
        }
        Get.snackbar("Error", "Failed to create post: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error creating post: $e");
      Get.snackbar("Error", "Failed to create post: ${e.toString()}");
      return false;
    } finally {
      isCreatingPost.value = false;
    }
  }

  /// Fetch user posts
  Future<void> fetchUserPosts() async {
    try {
      isLoading.value = true;

      final authService = AuthService.to;
      final userId = authService.currentUserId;
      final token = authService.currentToken;

      if (userId.isEmpty || token.isEmpty) {
        print("⚠️ User not logged in, cannot fetch posts");
        return;
      }

      final response = await HttpHelper.getData(
        endpoint: API.getAllPost,
        headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
      );

      print("📝 Fetch posts response status: ${response.statusCode}");
      print("📝 Fetch posts response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        posts.value = data.map((e) => Post.fromJson(e)).toList();
        print("✅ Fetched ${posts.length} posts");
      } else {
        print("❌ Failed to fetch posts: ${response.statusCode}");
        Get.snackbar("Error", "Failed to load posts");
      }
    } catch (e) {
      print("❌ Error fetching posts: $e");
      Get.snackbar("Error", "Failed to load posts: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh posts
  Future<void> refreshPosts() async {
    await fetchUserPosts();
  }

  /// Toggle like on a post
  Future<bool> togglePostLike(String postId) async {
    try {
      final authService = AuthService.to;
      final token = authService.currentToken;
      final userId = authService.currentUserId;

      if (token.isEmpty || userId.isEmpty) {
        Get.snackbar("Error", "Please login to like posts");
        return false;
      }

      print("👍 Toggling like for post: $postId");
      print("👍 User ID: $userId");

      // 🔧 FIX: Send postId and userId as query parameters (not body)
      final endpoint = '${API.togglePostLike}?postId=$postId&userId=$userId';

      final response = await HttpHelper.postData(
        endpoint: endpoint,
        data: {}, // Empty body
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      print("👍 Toggle post like response status: ${response.statusCode}");
      print("👍 Toggle post like response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final postIndex = posts.indexWhere((post) => post.postId == postId);
        if (postIndex != -1) {
          final post = posts[postIndex];
          // Toggle the like status and update count
          final newIsLiked = !post.isLiked;
          final newLikeCount = newIsLiked
              ? post.likeCount + 1
              : (post.likeCount > 0 ? post.likeCount - 1 : 0);

          // Create updated post using copyWith
          final updatedPost = post.copyWith(
            likeCount: newLikeCount,
            isLiked: newIsLiked,
          );

          // Update the post in the list - create new list to trigger GetX reactivity
          final updatedPosts = List<Post>.from(posts);
          updatedPosts[postIndex] = updatedPost;
          posts.value = updatedPosts;
          posts.refresh(); // Force refresh to ensure UI updates
          print("✅ Successfully toggled like for post: $postId");
        }
        return true;
      } else {
        print("❌ Failed to toggle post like: ${response.statusCode}");
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              "Failed to toggle like";
          Get.snackbar("Error", errorMessage);
        } catch (e) {
          Get.snackbar("Error", "Failed to toggle like");
        }
        return false;
      }
    } catch (e) {
      print("❌ Error toggling post like: $e");
      Get.snackbar("Error", "Failed to toggle like: ${e.toString()}");
      return false;
    }
  }
}

/// Post Model
class Post {
  final String postId;
  final String content;
  final String category;
  final String status;
  final List<String> imageUrls;
  final DateTime dateEntered;
  final String userName;
  final String? companyId;
  final String? companyLogo;
  final int likeCount;
  final bool isLiked;

  Post({
    required this.postId,
    required this.content,
    required this.category,
    required this.status,
    required this.imageUrls,
    required this.dateEntered,
    required this.userName,
    required this.companyId,
    this.companyLogo,
    this.likeCount = 0,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? '',
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
      dateEntered: json['dateEntered'] != null
          ? DateTime.parse(json['dateEntered'])
          : DateTime.now(),
      userName: json['userName'] ?? '',
      companyId: json['companyId'] as String?,
      companyLogo: json['companyLogo'] as String?,
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Post copyWith({
    String? postId,
    String? content,
    String? category,
    String? status,
    List<String>? imageUrls,
    DateTime? dateEntered,
    String? userName,
    String? companyId,
    String? companyLogo,
    int? likeCount,
    bool? isLiked,
  }) {
    return Post(
      postId: postId ?? this.postId,
      content: content ?? this.content,
      category: category ?? this.category,
      status: status ?? this.status,
      imageUrls: imageUrls ?? this.imageUrls,
      dateEntered: dateEntered ?? this.dateEntered,
      userName: userName ?? this.userName,
      companyId: companyId ?? this.companyId,
      companyLogo: companyLogo ?? this.companyLogo,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(dateEntered);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
