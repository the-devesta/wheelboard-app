import 'package:flutter/material.dart';
import '../widgets/feed_card_widget.dart';
import '../../../utils/responsive_utils.dart';

/// Feeds Professional Screen
/// Pixel-perfect implementation matching Figma design
class FeedsProfessionalScreen extends StatefulWidget {
  const FeedsProfessionalScreen({super.key});

  @override
  State<FeedsProfessionalScreen> createState() => _FeedsProfessionalScreenState();
}

class _FeedsProfessionalScreenState extends State<FeedsProfessionalScreen> {
  // Sample feed data - replace with actual data from API/controller
  final List<Map<String, dynamic>> feedData = [
    {
      'profileImageUrl': 'https://www.figma.com/api/mcp/asset/82bf7986-c512-4e0e-9a8d-9d00c76530b3',
      'profileName': 'Delhi Transport',
      'imageUrl': 'https://www.figma.com/api/mcp/asset/00395b7c-6f38-4505-abac-5be69909cf73',
      'title': 'Tips for fleet management',
      'description': 'Learn how to optimize your fleet operations and reduce costs',
      'postedTime': '2 days Ago',
      'isLiked': false,
    },
    {
      'profileImageUrl': 'https://www.figma.com/api/mcp/asset/82bf7986-c512-4e0e-9a8d-9d00c76530b3',
      'profileName': 'Delhi Transport',
      'imageUrl': 'https://www.figma.com/api/mcp/asset/00395b7c-6f38-4505-abac-5be69909cf73',
      'title': 'Tips for fleet management',
      'description': 'Learn how to optimize your fleet operations and reduce costs',
      'postedTime': '2 days Ago',
      'isLiked': false,
    },
    {
      'profileImageUrl': 'https://www.figma.com/api/mcp/asset/82bf7986-c512-4e0e-9a8d-9d00c76530b3',
      'profileName': 'Delhi Transport',
      'imageUrl': 'https://www.figma.com/api/mcp/asset/00395b7c-6f38-4505-abac-5be69909cf73',
      'title': 'Tips for fleet management',
      'description': 'Learn how to optimize your fleet operations and reduce costs',
      'postedTime': '2 days Ago',
      'isLiked': false,
    },
    {
      'profileImageUrl': 'https://www.figma.com/api/mcp/asset/82bf7986-c512-4e0e-9a8d-9d00c76530b3',
      'profileName': 'Delhi Transport',
      'imageUrl': 'https://www.figma.com/api/mcp/asset/00395b7c-6f38-4505-abac-5be69909cf73',
      'title': 'Tips for fleet management',
      'description': 'Learn how to optimize your fleet operations and reduce costs',
      'postedTime': '2 days Ago',
      'isLiked': false,
    },
    {
      'profileImageUrl': 'https://www.figma.com/api/mcp/asset/82bf7986-c512-4e0e-9a8d-9d00c76530b3',
      'profileName': 'Delhi Transport',
      'imageUrl': 'https://www.figma.com/api/mcp/asset/00395b7c-6f38-4505-abac-5be69909cf73',
      'title': 'Tips for fleet management',
      'description': 'Learn how to optimize your fleet operations and reduce costs',
      'postedTime': '2 days Ago',
      'isLiked': false,
    },
  ];

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
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: ResponsiveUtils.getResponsiveSpacing(context, small: 10, medium: 12, large: 14),
                      bottom: ResponsiveUtils.getResponsiveSpacing(context, small: 100, medium: 110, large: 120),
                    ),
                    child: Column(
                      children: feedData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final feed = entry.value;
                        return FeedCardWidget(
                          profileImageUrl: feed['profileImageUrl'] ?? '',
                          profileName: feed['profileName'] ?? '',
                          imageUrl: feed['imageUrl'] ?? '',
                          title: feed['title'] ?? '',
                          description: feed['description'] ?? '',
                          postedTime: feed['postedTime'] ?? '',
                          isLiked: feed['isLiked'] ?? false,
                          onProfileTap: () {
                            // Navigate to profile
                          },
                          onHeartTap: () {
                            setState(() {
                              feedData[index]['isLiked'] = !(feedData[index]['isLiked'] ?? false);
                            });
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

