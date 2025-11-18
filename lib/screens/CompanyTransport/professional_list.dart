import 'package:flutter/material.dart';

class ProfessionalListScreen extends StatefulWidget {
  const ProfessionalListScreen({super.key});

  @override
  State<ProfessionalListScreen> createState() => _ProfessionalListScreenState();
}

class _ProfessionalListScreenState extends State<ProfessionalListScreen> {
  String selectedFilter = 'ONBOARD';
  final TextEditingController _searchController = TextEditingController();
  Map<String, bool> favoriteStatus = {};

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
  void initState() {
    super.initState();
    // Initialize favorite status based on user data
    for (var user in users) {
      final userId = '${user['name']}_${user['role']}';
      favoriteStatus[userId] = user['status'].contains('FAVOURITE');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredUsers {
    return users.where((user) {
      if (selectedFilter == 'ONBOARD') {
        return user['status'].contains('ONBOARDED');
      } else if (selectedFilter == 'HIRED') {
        return user['status'].contains('HIRED');
      } else if (selectedFilter == 'FAVOURITE') {
        return user['status'].contains('FAVOURITE');
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF25C5C),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'WB',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'WHEELBOARD',
              style: TextStyle(
                color: Color(0xFF1E1E1E),
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar with Filter Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search name, location...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune, color: Color(0xFFF25C5C)),
                    onPressed: () {
                      // Open filter dialog
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),

          // Filter Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['ONBOARD', 'HIRED', 'FAVOURITE'].map((status) {
                final isSelected = selectedFilter == status;
                final isLast = status == 'FAVOURITE';

                return Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 12),
                  child: GestureDetector(
                    onTap: () => setState(() => selectedFilter = status),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF25C5C) : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFFF25C5C),
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFF25C5C).withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFFF25C5C),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Professional List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                final userId = '${user['name']}_${user['role']}';
                final isFavorite = favoriteStatus[userId] ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Picture
                        CircleAvatar(
                          backgroundImage: NetworkImage(user['image']),
                          radius: 30,
                        ),
                        const SizedBox(width: 12),
                        // Name, Role, Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name and Role
                              Text(
                                user['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user['role'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Rating, Location, Experience
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Color(0xFFF25C5C),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${user['rating']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF1E1E1E),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '• ${user['location']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    '• ${user['experience']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Status Tags
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: user['status'].map<Widget>((s) {
                                  final isOnboarded = s == 'ONBOARDED';

                                  Color bgColor;
                                  Color textColor;
                                  Color borderColor;

                                  if (isOnboarded) {
                                    bgColor = const Color(0xFFF25C5C);
                                    textColor = Colors.white;
                                    borderColor = const Color(0xFFF25C5C);
                                  } else {
                                    bgColor = Colors.white;
                                    textColor = const Color(0xFFF25C5C);
                                    borderColor = const Color(0xFFF25C5C);
                                  }

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: borderColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      s,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        // Verified and Favorite
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (user['verified'])
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF27AE60),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  favoriteStatus[userId] = !isFavorite;
                                });
                              },
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: const Color(0xFFF25C5C),
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
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
