import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/transport/lease_models.dart';
import '../../../controllers/Transport/lease_controller.dart';
import '../../../utils/constants.dart';

/// Applications Screen for Vehicle Lease Applications
/// Shows applications for a specific vehicle with filtering by status
class ApplicationsScreen extends StatefulWidget {
  final String leaseId;
  final String vehicleTitle; // For display

  const ApplicationsScreen({
    super.key,
    required this.leaseId,
    this.vehicleTitle = "Lease Applications",
  });

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final LeaseController _leaseController = Get.find<LeaseController>();
  String _selectedStatus = 'Pending'; // Pending, Approved, Rejected

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchApplications();
    });
  }

  void _fetchApplications() {
    _leaseController.fetchLeaseApplications(
      widget.leaseId,
      status: _selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.vehicleTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Segmented Control
          const SizedBox(height: 16),
          _buildSegmentedControl(),

          const SizedBox(height: 16),

          // Applications List
          Expanded(
            child: Obx(() {
              if (_leaseController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final applications = _leaseController.applications;

              if (applications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No $_selectedStatus applications',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  return _buildApplicationCard(applications[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusButton(
              'Pending',
              _selectedStatus == 'Pending',
              () {
                setState(() => _selectedStatus = 'Pending');
                _fetchApplications();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatusButton(
              'Approved',
              _selectedStatus == 'Approved',
              () {
                setState(() => _selectedStatus = 'Approved');
                _fetchApplications();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatusButton(
              'Rejected',
              _selectedStatus == 'Rejected',
              () {
                setState(() => _selectedStatus = 'Rejected');
                _fetchApplications();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationCard(LeaseApplication application) {
    final imageUrl =
        application.imageUrl != null && application.imageUrl!.isNotEmpty
        ? (application.imageUrl!.startsWith('http') ||
                  application.imageUrl!.contains('uploads/')
              ? (application.imageUrl!.startsWith('http')
                    ? application.imageUrl!
                    : '${ApiConstants.baseUrl}${application.imageUrl}')
              : application.imageUrl!)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Applicant Header
          Row(
            children: [
              // Profile Picture or Vehicle Image
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl == null
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),

              // Name and Role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.fullName ?? 'Unknown User',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Distance: ${application.distanceKm ?? 0} km',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Date
              Text(
                _formatDate(application.appliedDate),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            application.vehicleTitle ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          if (application.status == 'Pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleApprove(application),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleReject(application),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF44336),
                      side: const BorderSide(color: Color(0xFFF44336)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return "";
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _handleApprove(LeaseApplication application) async {
    if (application.applicationId == null) return;

    final success = await _leaseController.updateLeaseApplicationStatus(
      application.applicationId!,
      'approved',
    );

    if (success) {
      _fetchApplications();
    }
  }

  Future<void> _handleReject(LeaseApplication application) async {
    if (application.applicationId == null) return;

    final success = await _leaseController.updateLeaseApplicationStatus(
      application.applicationId!,
      'rejected',
    );

    if (success) {
      _fetchApplications();
    }
  }
}
