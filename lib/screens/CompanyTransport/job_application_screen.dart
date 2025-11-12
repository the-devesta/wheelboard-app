import 'package:flutter/material.dart';

class JobApplicationsScreen extends StatelessWidget {
  const JobApplicationsScreen({super.key});

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
        title: const Text(
          'Job Applications',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Job Post Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Technician',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pune',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Posted on 8 June 2025',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Application Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Rajesh Kumar - Pending
                  _buildApplicationCard(
                    imageUrl: 'https://i.pravatar.cc/150?img=1',
                    applicantName: 'Rajesh Kumar',
                    appliedDate: '7 June 2025',
                    status: 'Pending',
                    statusColor: const Color(0xFFFEF3C7),
                    statusTextColor: const Color(0xFF92400E),
                    jobType: 'Helper',
                    location: 'Nagpur',
                    salary: '₹5,000',
                    isAccepted: false,
                  ),
                  const SizedBox(height: 16),

                  // Priya Sharma - Pending
                  _buildApplicationCard(
                    imageUrl: 'https://i.pravatar.cc/150?img=3',
                    applicantName: 'Priya Sharma',
                    appliedDate: '6 June 2025',
                    status: 'Pending',
                    statusColor: const Color(0xFFFEF3C7),
                    statusTextColor: const Color(0xFF92400E),
                    jobType: 'Technician',
                    location: 'Pune',
                    salary: '₹22,000',
                    isAccepted: false,
                  ),
                  const SizedBox(height: 16),

                  // Amit Patel - Accepted
                  _buildApplicationCard(
                    imageUrl: 'https://i.pravatar.cc/150?img=5',
                    applicantName: 'Amit Patel',
                    appliedDate: '5 June 2025',
                    status: 'Accepted',
                    statusColor: const Color(0xFFD1FAE5),
                    statusTextColor: const Color(0xFF065F46),
                    jobType: 'Helper',
                    location: 'Mumbai',
                    salary: '₹12,000',
                    isAccepted: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard({
    required String imageUrl,
    required String applicantName,
    required String appliedDate,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    required String jobType,
    required String location,
    required String salary,
    required bool isAccepted,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            applicantName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              color: const Color(0xFF1E1E1E),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                              color: statusTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Applied on $appliedDate',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Job Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type of Job',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    jobType,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Right Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Salary',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    salary,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      // Handle view profile
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'View Profile',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: const Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons
          if (!isAccepted)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Handle accept
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Handle reject
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF86EFAC), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Application Accepted',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
