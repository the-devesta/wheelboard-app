import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/feed_card_widget.dart';
import '../../../utils/responsive_utils.dart';
import '../../../controllers/Professional/feeds_controller.dart';

/// Feeds Professional Screen
/// Pixel-perfect implementation matching Figma design
class FeedsProfessionalScreen extends StatefulWidget {
  const FeedsProfessionalScreen({super.key});

  @override
  State<FeedsProfessionalScreen> createState() => _FeedsProfessionalScreenState();
}

class _FeedsProfessionalScreenState extends State<FeedsProfessionalScreen> {
  // Initialize controller
  final FeedsController controller = Get.put(FeedsController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            // Main Content
            Column(
              children: [
                // White Header with Logo
                Container(
                  width: double.infinity,
                  height: 91,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFFCD2D2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: ResponsiveUtils.getResponsiveSpacing(context, small: 0, medium: 12, large: 16),
                        top: ResponsiveUtils.getResponsiveSpacing(context, small: 38, medium: 40, large: 42),
                      ),
                      child: Image.asset(
                        'assets/logo-bg 3.png',
                        width: ResponsiveUtils.isMobile(context) ? screenWidth * 0.72 : 282,
                        height: ResponsiveUtils.isMobile(context) ? 53 : 53,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Feeds List
                Expanded(
                  child: Obx(
                    () {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFFF36969),
                            ),
                          ),
                        );
                      }

                      if (controller.feeds.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.feed_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No feeds available",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Check back later for new posts",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () => controller.refreshFeeds(),
                        color: const Color(0xFFF36969),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            top: ResponsiveUtils.getResponsiveSpacing(context, small: 10, medium: 12, large: 14),
                            bottom: ResponsiveUtils.getResponsiveSpacing(context, small: 100, medium: 110, large: 120),
                          ),
                          child: Column(
                            children: controller.feeds.map((post) {
                              // Get first image if available
                              final imageUrl = post.imageUrls.isNotEmpty
                                  ? post.imageUrls[0]
                                  : '';
                              
                              // Extract title from content (first line or first 50 chars)
                              final contentLines = post.content.split('\n');
                              final title = contentLines.isNotEmpty && contentLines[0].isNotEmpty
                                  ? (contentLines[0].length > 50
                                      ? '${contentLines[0].substring(0, 50)}...'
                                      : contentLines[0])
                                  : post.category.isNotEmpty
                                      ? post.category
                                      : 'Post';
                              
                              // Extract description (rest of content or second line)
                              final description = contentLines.length > 1 && contentLines[1].isNotEmpty
                                  ? contentLines[1]
                                  : contentLines.length > 1
                                      ? (contentLines.length > 2 && contentLines[2].isNotEmpty
                                          ? contentLines[2]
                                          : '')
                                      : contentLines.isNotEmpty && contentLines[0].length > 50
                                          ? contentLines[0].substring(50)
                                          : '';

                              return FeedCardWidget(
                                profileImageUrl: '', // TODO: Add profile image when available in API
                                profileName: post.category.isNotEmpty ? post.category : 'User',
                                imageUrl: imageUrl,
                                title: title,
                                description: description.isNotEmpty
                                    ? (description.length > 100
                                        ? '${description.substring(0, 100)}...'
                                        : description)
                                    : post.content.isNotEmpty
                                        ? (post.content.length > 100
                                            ? '${post.content.substring(0, 100)}...'
                                            : post.content)
                                        : '',
                                postedTime: post.timeAgo,
                                isLiked: controller.isLiked(post.postId),
                                onProfileTap: () {
                                  // Navigate to profile
                                },
                                onHeartTap: () {
                                  controller.toggleLike(post.postId);
                                },
                                onShareTap: () {
                                  // Handle share
                                },
                                onEyeTap: () {
                                  // Handle view
                                },
                                onReadMoreTap: () {
                                  // Navigate to full post
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

