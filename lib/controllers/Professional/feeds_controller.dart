import 'package:get/get.dart';
import '../Transport/post_controller.dart';

/// Thin wrapper around [PostController] kept for backward-compatibility with
/// screens that resolve a `FeedsController`. It delegates to the single
/// canonical feed controller so like/comment/share state stays consistent.
class FeedsController extends GetxController {
  PostController get _post =>
      Get.isRegistered<PostController>() ? Get.find<PostController>() : Get.put(PostController());

  RxList<Post> get feeds => _post.posts;
  RxBool get isLoading => _post.isLoading;
  Rxn<FeedStats> get stats => _post.stats;

  @override
  void onInit() {
    super.onInit();
    // Ensure the canonical controller exists and is loading.
    _post;
  }

  Future<void> fetchFeeds() => _post.fetchFeeds();

  Future<void> refreshFeeds() => _post.refreshPosts();

  /// Toggle like on a post (delegates to the canonical controller).
  Future<void> toggleLike(String postId) => _post.toggleLike(postId);

  /// Whether the given post is currently liked (server-driven).
  bool isLiked(String postId) {
    for (final p in _post.posts) {
      if (p.id == postId) return p.isLiked;
    }
    return false;
  }
}
