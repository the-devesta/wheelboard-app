// import 'package:flutter/material.dart';

// class MyLearningScreen extends StatelessWidget {
//   const MyLearningScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Learning'),
//       ),
//       body: const Center(
//         child: Text('My Learning Screen'),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {
        "title": "How to Save Fuel",
        "type": "Video",
        "typeColor": Colors.blue,
        "status": "Completed",
        "statusColor": Colors.green,
        "desc": "Learn best practices to reduce fuel costs",
        "time": "3 min",
        "date": "12 Apr 2024",
        "action": "Play Video",
        "actionColor": Colors.blue,
        "icon": Icons.play_arrow_rounded,
      },
      {
        "title": "Tyre Fitting Animation",
        "type": "Animation",
        "typeColor": Colors.purple,
        "status": "Pending",
        "statusColor": Colors.amber,
        "desc": "Step-by-step tyre fitting procedures and safety",
        "time": "4 min",
        "date": "10 Apr 2024",
        "action": "Watch Animation",
        "actionColor": Colors.purple,
        "icon": Icons.play_arrow_rounded,
      },
      {
        "title": "Safe Lifting Techniques",
        "type": "Article",
        "typeColor": Colors.orange,
        "status": "Pending",
        "statusColor": Colors.amber,
        "desc": "Essential tips to avoid injuries when lifting",
        "time": "2 min",
        "date": "8 Apr 2024",
        "action": "Read Article",
        "actionColor": Colors.orange,
        "icon": Icons.menu_book_rounded,
      },
      {
        "title": "Eco-Driving Animation",
        "type": "Animation",
        "typeColor": Colors.purple,
        "status": "Completed",
        "statusColor": Colors.green,
        "desc": "Techniques to improve fuel efficiency while driving",
        "time": "5 min",
        "date": "5 Apr 2024",
        "action": "Watch Animation",
        "actionColor": Colors.purple,
        "icon": Icons.play_arrow_rounded,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0.4,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "My Learning",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.redAccent),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.more_vert, color: Colors.grey),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            _buildProgressCard(),
            const SizedBox(height: 16),
            ...modules.map((m) => _buildModuleCard(m)),
            const SizedBox(height: 40),
          ],
        ),
      ),
      // bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// ------------------------ Progress Header ------------------------
  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 6),
              Text(
                "5 Modules Completed",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Spacer(),
              Icon(Icons.hourglass_bottom, color: Colors.amber, size: 18),
              SizedBox(width: 4),
              Text(
                "3 Pending",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 5 / 8, // 5 completed out of 8
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  /// ------------------------ Module Card ------------------------
  Widget _buildModuleCard(Map<String, dynamic> m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title + Tags
          Row(
            children: [
              Expanded(
                child: Text(
                  m["title"],
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _buildTag(m["type"], m["typeColor"]),
              const SizedBox(width: 6),
              _buildTag(m["status"], m["statusColor"]),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            m["desc"],
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 12),

          /// Time + Date
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text(m["time"], style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 16),
              const Icon(Iconsax.calendar_1, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text(m["date"], style: const TextStyle(color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 14),

          /// Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(m["icon"], size: 18),
              label: Text(
                m["action"],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: m["actionColor"],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ------------------------ Tag Chip ------------------------
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          if (text == "Video")
            const Icon(Icons.play_circle_filled, size: 12, color: Colors.blue),
          if (text == "Animation")
            const Icon(
              Icons.movie_creation_outlined,
              size: 12,
              color: Colors.purple,
            ),
          if (text == "Article")
            const Icon(Icons.menu_book, size: 12, color: Colors.orange),
          if (text == "Completed")
            const Icon(Icons.check, size: 12, color: Colors.green),
          if (text == "Pending")
            const Icon(Icons.hourglass_empty, size: 12, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
