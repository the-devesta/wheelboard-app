import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../controllers/Professional/feeds_controller.dart';
import '../../../controllers/post_controller.dart';
import '../../../widgets/custom_loader.dart';

/// Feeds Professional Screen
/// Same design as CompanyTransport feed_screen.dart
class FeedsProfessionalScreen extends StatelessWidget {
  final String profileImage = 'https://i.pravatar.cc/100';

  const FeedsProfessionalScreen({super.key});

  Widget buildPostCard(Post post) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () {
              // Navigate to profile if needed
            },
            borderRadius: BorderRadius.circular(50),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(profileImage)),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName.isNotEmpty ? post.userName : "User",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        post.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          // Post Content
          if (post.content.isNotEmpty)
            Text(
              post.content,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),

          // Post Images
          if (post.imageUrls.isNotEmpty) ...[
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: post.imageUrls.length == 1
                  ? Container(
                      width: double.infinity,
                      height: 200,
                      child: Image.network(
                        post.imageUrls[0],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: Center(
                              child: const CustomLoader.small(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          // Show default placeholder image when network image fails
                          return Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              "assets/truck.png",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // If truck.png also fails, show icon with text
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Image not available",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: post.imageUrls.length > 1 ? 2 : 1,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: post.imageUrls.length > 4 ? 4 : post.imageUrls.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            child: Image.network(
                              post.imageUrls[index],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: const CustomLoader.small(),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                // Show default placeholder for grid images
                                return Container(
                                  color: Colors.grey[200],
                                  child: Image.asset(
                                    "assets/truck.png",
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // If truck.png also fails, show icon
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 32,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],

          // If no content and no images, show placeholder image
          if (post.content.isEmpty && post.imageUrls.isEmpty) ...[
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset("assets/truck.png"),
            ),
          ],

          SizedBox(height: 10),

          // Reactions
          Row(
            children: [
              SvgPicture.asset(
                'assets/heart.svg',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 10),
              SvgPicture.asset(
                'assets/share.svg',
                width: 26,
                height: 26,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 10),
              SvgPicture.asset(
                'assets/eye.svg',
                width: 26,
                height: 26,
                fit: BoxFit.contain,
              ),
              Spacer(),
              // Status badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: post.status == 'Pending'
                      ? Colors.orange[100]
                      : Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  post.status,
                  style: TextStyle(
                    fontSize: 10,
                    color: post.status == 'Pending'
                        ? Colors.orange[800]
                        : Colors.green[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                post.timeAgo,
                style: TextStyle(color: Colors.grey),
              ),
              if (post.content.length > 100)
                Text(
                  "Read More",
                  style: TextStyle(color: Colors.blueAccent),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FeedsController controller = Get.put(FeedsController());

    return Scaffold(
      backgroundColor: Color(0xFFFCECEC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset('assets/headingImg.png', width: 210, height: 30),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              controller.refreshFeeds();
            },
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const CustomLoader(message: "Loading feeds...");
          }

          if (controller.feeds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.feed, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No posts yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Create your first post!",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.refreshFeeds();
            },
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 100),
              itemCount: controller.feeds.length,
              itemBuilder: (context, index) {
                return buildPostCard(controller.feeds[index]);
              },
            ),
          );
        },
      ),
      
    );
  }
}

