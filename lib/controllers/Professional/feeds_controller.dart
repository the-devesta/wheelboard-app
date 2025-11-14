import 'dart:convert';
import 'package:get/get.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../controllers/post_controller.dart';

class FeedsController extends GetxController {
  var isLoading = false.obs;
  var feeds = <Post>[].obs;
  var likedPosts = <String>{}.obs; // Track liked post IDs

  @override
  void onInit() {
    super.onInit();
    fetchFeeds();
  }

  /// Fetch all feeds/posts
  Future<void> fetchFeeds() async {
    try {
      isLoading.value = true;

      final authService = AuthService.to;
      final userId = authService.currentUserId;
      final token = authService.currentToken;

      if (userId.isEmpty) {
        print("⚠️ User not logged in, cannot fetch feeds");
        return;
      }

      print("📰 Fetching feeds...");

      // Using getUserPosts API - if it returns all posts, great. Otherwise, we might need a different endpoint
      final response = await HttpHelper.getData(
        endpoint: API.getAllPost,
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      print("📰 Feeds response status: ${response.statusCode}");
      print("📰 Feeds response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        feeds.value = data.map((e) => Post.fromJson(e)).toList();
        print("✅ Fetched ${feeds.length} feeds");
      } else {
        print("❌ Failed to fetch feeds: ${response.statusCode}");
        Get.snackbar("Error", "Failed to load feeds");
      }
    } catch (e) {
      print("❌ Error fetching feeds: $e");
      Get.snackbar("Error", "Failed to load feeds: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle like on a post
  void toggleLike(String postId) {
    if (likedPosts.contains(postId)) {
      likedPosts.remove(postId);
    } else {
      likedPosts.add(postId);
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

