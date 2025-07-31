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
      backgroundColor: Colors.pink.shade50,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search name, location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.filter_alt_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['ONBOARDED', 'HIRED', 'FAVOURITE'].map((status) {
                final isSelected = selectedFilter == status;
                return ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (_) => setState(() => selectedFilter = status),
                  selectedColor: Colors.redAccent,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.redAccent,
                  ),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.redAccent),
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
