import 'package:flutter/material.dart';

class ProfessionalListScreen extends StatefulWidget {
  const ProfessionalListScreen({super.key});

  @override
  State<ProfessionalListScreen> createState() => _ProfessionalListScreenState();
}

class _ProfessionalListScreenState extends State<ProfessionalListScreen> {
  String selectedFilter = 'ONBOARDED';

  final List<Map<String, dynamic>> users = [
    {
      'name': 'Rakesh Kumar',
      'role': 'Driver',
      'rating': 4.9,
      'location': 'Khuarwas',
      'experience': '4 yrs',
      'verified': true,
      'status': ['ONBOARDED', 'FAVOURITE'],
      'image': 'https://i.pravatar.cc/150?img=1',
    },
    {
      'name': 'Manoj Singh',
      'role': 'Driver',
      'rating': 4.7,
      'location': 'Gurgaon',
      'experience': '2 yrs',
      'verified': false,
      'status': ['HIRED'],
      'image': 'https://i.pravatar.cc/150?img=2',
    },
    {
      'name': 'Priya Sharma',
      'role': 'Helper',
      'rating': 4.8,
      'location': 'Faridabad',
      'experience': '5 yrs',
      'verified': true,
      'status': ['ONBOARDED'],
      'image': 'https://i.pravatar.cc/150?img=3',
    },
    {
      'name': 'Rakesh Kumar',
      'role': 'Technician',
      'rating': 4.9,
      'location': 'Khuarwas',
      'experience': '4 yrs',
      'verified': true,
      'status': ['ONBOARDED', 'FAVOURITE'],
      'image': 'https://i.pravatar.cc/150?img=1',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4E3E3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(
              context,
            ); // This will pop the current screen from the navigation stack (go back)
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/headingImg.png',
              width: MediaQuery.of(context).size.width * 0.50,
              height: 50,
              // Replace with your image path
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
            child: Row(
              children: [
                // 🔍 Search Bar
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search name, location...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // ⚙️ Filter Button
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2, // subtle shadow
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.redAccent),
                    onPressed: () {
                      // open filter bottom sheet or dialog
                    },
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['ONBOARD', 'HIRED', 'FAVOURITE'].map((status) {
                final isSelected = selectedFilter == status;
                final isLast = status == 'FAVOURITE'; // last item check

                return Padding(
                  padding: EdgeInsets.only(
                    right: isLast ? 0 : 12,
                  ), // space only on right
                  child: GestureDetector(
                    onTap: () => setState(() => selectedFilter = status),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.redAccent : Colors.white,
                        borderRadius: BorderRadius.circular(30), // pill shape
                        border: Border.all(color: Colors.redAccent),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(user['image']),
                            radius: 25,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user['name']}  •  ${user['role']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                    Text('${user['rating']}'),
                                    const SizedBox(width: 8),
                                    Text(user['location']),
                                    const SizedBox(width: 8),
                                    Text(user['experience']),
                                  ],
                                ),
                                Wrap(
                                  spacing: 6,
                                  children: user['status'].map<Widget>((s) {
                                    Color color = s == 'HIRED'
                                        ? Colors.pink.shade200
                                        : Colors.redAccent;
                                    return Chip(
                                      label: Text(s),
                                      backgroundColor: color.withOpacity(0.2),
                                      labelStyle: TextStyle(color: color),
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.all(0),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              if (user['verified'])
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    Text(
                                      'Verified',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 6),
                              const Icon(
                                Icons.favorite_border,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
