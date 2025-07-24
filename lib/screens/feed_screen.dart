import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:get/get.dart';
import 'package:wheelboard/screens/fleet_userprofile.dart';

class FeedScreen extends StatelessWidget {
  final String postImage =
      'https://images.unsplash.com/photo-1618675529403-69e751c17746'; // Truck image
  final String profileImage = 'https://i.pravatar.cc/100';

  Widget buildPostCard() {
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

  @override
  Widget build(BuildContext context) {
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
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 100),
        children: [buildPostCard(), buildPostCard()],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFD6C6C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          child: Text("New Post", style: TextStyle(color: AppColors.white)),
        ),
      ),
    );
  }
}
