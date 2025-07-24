import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'banner_carousel.dart';
import 'fleet_userprofile.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.local_shipping, 'label': 'Vehicles'},
    {'icon': Icons.person, 'label': 'Professional'},
    {'icon': Icons.money, 'label': 'Expenses'},
  ];

  final List<Map<String, dynamic>> stats = [
    {
      'label': 'Services',
      'value': 5,
      'icon': Icons.work_outline,
      'bgColor': Color(0xFFFFF1D6),
      'iconColor': Color(0xFFFBAE4B),
    },
    {
      'label': 'Leads',
      'value': 12,
      'icon': Icons.show_chart,
      'bgColor': Color(0xFFE1FFF3),
      'iconColor': Color(0xFFFB4B74),
    },
  ];
  final String profileImage = 'https://i.pravatar.cc/100';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=4',
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Delhi Transport.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Red square with rounded corners and white bell
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                AppColors.buttonBg, // AppColors.buttonBg (red)
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),

                        // Small teal-green badge
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Color(
                                0xFF317873,
                              ), // Example: AppColors.badge (teal green)
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),

                /// Banner Image
                BannerCarousel(),
                SizedBox(height: 20),

                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: stats.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.8,
                  ),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item['icon'], size: 30, color: Colors.teal),
                          SizedBox(height: 8),
                          Text(
                            item['label'],
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 20),

                /// Menu Grid
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: menuItems.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item['icon'], size: 30, color: Colors.teal),
                          SizedBox(height: 8),
                          Text(
                            item['label'],
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Services",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                /// Job Card
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Title + Call Now
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Concor Bangalore",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal[100],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Call Now",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      /// Likes + Applicants
                      Row(
                        children: [
                          Icon(Icons.thumb_up_alt_outlined, size: 16),
                          SizedBox(width: 4),
                          Text("35 Likes"),
                          SizedBox(width: 12),
                          Icon(Icons.person_outline, size: 16),
                          SizedBox(width: 4),
                          Text("0 Applicants"),
                        ],
                      ),
                      SizedBox(height: 12),

                      /// Share + Services
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: StadiumBorder(),
                              ),
                              icon: Icon(Icons.share),
                              label: Text("Share"),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: StadiumBorder(),
                            ),
                            child: Text("Services"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Popular Feeds",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // handle navigation or callback
                      },
                      child: Text(
                        "View More",
                        style: TextStyle(
                          color: Colors.blue, // customize color
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                buildPostCard(),

                /// Delhi Transport Footer
                SizedBox(height: 100), // space for nav bar
              ],
            ),
          ),
        ),
      ),

      /// Bottom Nav Bar
    );
  }

  Widget buildPostCard() {
    return Container(
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
              // handle tap here
              Get.to(FleetUserprofile());
            },
            borderRadius: BorderRadius.circular(50), // optional ripple radius
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(profileImage)),
                SizedBox(width: 10),
                Text(
                  "Delhi Transport",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset("assets/truck.png"),
          ),
          SizedBox(height: 10),

          // Reactions
          Row(
            children: [
              Icon(Icons.favorite_border, color: AppColors.buttonBg),
              SizedBox(width: 10),
              Icon(Icons.chat_bubble_outline, color: AppColors.buttonBg),
              SizedBox(width: 10),
              Icon(Icons.share, color: AppColors.buttonBg),
            ],
          ),
          SizedBox(height: 10),

          // Title + Description
          Text(
            "Tips For Fleet Management",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            "Learn how to optimize your fleet operations and reduce costs",
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 8),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Posted 2 days ago", style: TextStyle(color: Colors.grey)),
              Text("Read More", style: TextStyle(color: Colors.blueAccent)),
            ],
          ),
        ],
      ),
    );
  }
}
