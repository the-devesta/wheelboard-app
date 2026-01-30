import 'dart:convert';
import 'package:get/get.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../Transport/post_controller.dart';
import '../../utils/app_logger.dart';

class FeedsController extends GetxController {
  var isLoading = false.obs;
  var feeds = <Post>[].obs;
  var likedPosts = <String>{}.obs; // Track liked post IDs

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() => fetchFeeds());
  }

  /// Fetch all feeds/posts
  Future<void> fetchFeeds() async {
    try {
      isLoading.value = true;

      final authService = AuthService.to;
      final userId = authService.currentUserId;
      final token = authService.currentToken;

      if (userId.isEmpty) {
        AppLogger.d("⚠️ User not logged in, cannot fetch feeds");
        return;
      }

      AppLogger.d("📰 Fetching feeds...");

      // Using getUserPosts API - if it returns all posts, great. Otherwise, we might need a different endpoint
      final response = await HttpHelper.getData(
        endpoint: API.getAllPost,
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      AppLogger.d("📰 Feeds response status: ${response.statusCode}");
      AppLogger.d("📰 Feeds response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        feeds.value = data.map((e) => Post.fromJson(e)).toList();
        AppLogger.d("✅ Fetched ${feeds.length} feeds");
      } else {
        AppLogger.d("❌ Failed to fetch feeds: ${response.statusCode}");
        Get.snackbar("Error", "Failed to load feeds");
      }
    } catch (e) {
      AppLogger.d("❌ Error fetching feeds: $e");
      Get.snackbar("Error", "Failed to load feeds: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle like on a post
  Future<void> toggleLike(String postId) async {
    try {
      // Get or create PostController instance
      PostController postController;
      try {
        postController = Get.find<PostController>();
      } catch (e) {
        // If not found, create it
        postController = Get.put(PostController());
      }

      // Call API to toggle like
      final success = await postController.togglePostLike(postId);

      if (success) {
        // Update local state for immediate UI feedback
        if (likedPosts.contains(postId)) {
          likedPosts.remove(postId);
        } else {
          likedPosts.add(postId);
        }
      }
    } catch (e) {
      AppLogger.d("❌ Error toggling like: $e");
    }
  }

  /// Check if post is liked
  bool isLiked(String postId) {
    return likedPosts.contains(postId);
  }

  /// Refresh feeds
  Future<void> refreshFeeds() async {
    await fetchFeeds();
  }
}
