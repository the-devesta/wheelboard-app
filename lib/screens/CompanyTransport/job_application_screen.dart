import 'package:flutter/material.dart';

class JobApplicationsScreen extends StatelessWidget {
  const JobApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Job Applications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Technician Job Card
            JobPostCard(
              jobTitle: 'Technician',
              location: 'Pune',
              postedDate: '8 June 2025',
            ),
            const SizedBox(height: 16.0),

            // Application Card 1: Rajesh Kumar (Pending)
            ApplicationCard(
              imageUrl:
                  'https://placehold.co/100x100/A020F0/ffffff?text=RK', // Placeholder image
              applicantName: 'Rajesh Kumar',
              appliedDate: '7 June 2025',
              status: 'Pending',
              jobType: 'Helper',
              location: 'Nagpur',
              salary: '₹5,000',
              onAccept: () {
                // Handle accept
              },
              onReject: () {
                // Handle reject
              },
            ),
            const SizedBox(height: 16.0),

            // Application Card 2: Priya Sharma (Pending)
            ApplicationCard(
              imageUrl:
                  'https://placehold.co/100x100/FFC0CB/000000?text=PS', // Placeholder image
              applicantName: 'Priya Sharma',
              appliedDate: '6 June 2025',
              status: 'Pending',
              jobType: 'Technician',
              location: 'Pune',
              salary: '₹22,000',
              onAccept: () {
                // Handle accept
              },
              onReject: () {
                // Handle reject
              },
            ),
            const SizedBox(height: 16.0),

            // Application Card 3: Amit Patel (Accepted)
            ApplicationCard(
              imageUrl:
                  'https://placehold.co/100x100/008080/ffffff?text=AP', // Placeholder image
              applicantName: 'Amit Patel',
              appliedDate: '5 June 2025',
              status: 'Accepted',
              jobType: 'Helper',
              location: 'Mumbai',
              salary: '₹12,000',
              onAccept: () {
                // Handle accept (though it's accepted, keeping for consistency)
              },
              onReject: () {
                // Handle reject (though it's accepted, keeping for consistency)
              },
              isAcceptedCard: true, // Special styling for accepted card
            ),
          ],
        ),
      ),
    );
  }
}

class JobPostCard extends StatelessWidget {
  final String jobTitle;
  final String location;
  final String postedDate;

  const JobPostCard({
    super.key,
    required this.jobTitle,
    required this.location,
    required this.postedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),

      margin: EdgeInsets.zero,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              jobTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: <Widget>[
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4.0),
                Text(
                  location,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4.0),
                Text(
                  'Posted on $postedDate',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ApplicationCard extends StatelessWidget {
  final String imageUrl;
  final String applicantName;
  final String appliedDate;
  final String status;
  final String jobType;
  final String location;
  final String salary;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isAcceptedCard;

  const ApplicationCard({
    super.key,
    required this.imageUrl,
    required this.applicantName,
    required this.appliedDate,
    required this.status,
    required this.jobType,
    required this.location,
    required this.salary,
    required this.onAccept,
    required this.onReject,
    this.isAcceptedCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: EdgeInsets.zero,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            applicantName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isAcceptedCard
                                  ? Colors.green[100]
                                  : Colors.yellow[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                color: isAcceptedCard
                                    ? Color(0xFF166534)
                                    : Colors.orange[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Applied on $appliedDate',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.5, color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Type of Job',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      jobType,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Location',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      'Salary',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      salary,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextButton(
                      onPressed: () {
                        // Handle view profile
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View Profile',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            if (!isAcceptedCard)
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF10B981), // Background color
                        foregroundColor: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEF4444), // Background color
                        foregroundColor: Colors.white, // Text color
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
                  color: Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[400]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Application Accepted',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
