import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/vehicle_lease_application_model.dart';
import '../../models/get_vehicle_model.dart';

/// Applications Screen for Vehicle Lease Applications
/// Shows applications for a specific vehicle with filtering by status
class ApplicationsScreen extends StatefulWidget {
  final Vehicle? vehicle; // Optional vehicle data

  const ApplicationsScreen({
    super.key,
    this.vehicle,
  });

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  String _selectedStatus = 'Pending'; // Pending, Approved, Rejected

  // Mock data - Replace with actual API calls
  final List<VehicleLeaseApplicationModel> _allApplications = [
    VehicleLeaseApplicationModel(
      applicationId: '1',
      applicantId: 'a1',
      applicantName: 'Rajesh Kumar',
      profileImage: '',
      role: 'Driver',
      appliedDate: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      leasePeriodStart: '2024-01-15',
      leasePeriodEnd: '2024-07-15',
      proposedPrice: 25000,
      description: 'Need vehicle for daily office commute, experienced driver with clean record.',
      status: 'Pending',
      vehicleId: 'v1',
      vehicleName: 'Toyota Camry 2022',
      vehicleNumber: 'TN-07-AB-1234',
    ),
    VehicleLeaseApplicationModel(
      applicationId: '2',
      applicantId: 'a2',
      applicantName: 'Priya Sharma',
      profileImage: '',
      role: 'Fleet Owner',
      appliedDate: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      leasePeriodStart: '2024-02-01',
      leasePeriodEnd: '2024-07-31',
      proposedPrice: 28000,
      description: 'Looking to expand my fleet for corporate contracts. Willing to pay premium for well-maintained vehicle.',
      status: 'Pending',
      vehicleId: 'v1',
      vehicleName: 'Toyota Camry 2022',
      vehicleNumber: 'TN-07-AB-1234',
    ),
    VehicleLeaseApplicationModel(
      applicationId: '3',
      applicantId: 'a3',
      applicantName: 'Amit Patel',
      profileImage: '',
      role: 'Agent',
      appliedDate: DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      leasePeriodStart: '2024-01-20',
      leasePeriodEnd: '2024-06-20',
      proposedPrice: 24500,
      description: 'Representing multiple clients who need reliable vehicles for business travel.',
      status: 'Pending',
      vehicleId: 'v1',
      vehicleName: 'Toyota Camry 2022',
      vehicleNumber: 'TN-07-AB-1234',
    ),
    VehicleLeaseApplicationModel(
      applicationId: '4',
      applicantId: 'a4',
      applicantName: 'Suresh Reddy',
      profileImage: '',
      role: 'Driver',
      appliedDate: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      leasePeriodStart: '2024-02-10',
      leasePeriodEnd: '2024-08-10',
      proposedPrice: 26000,
      description: 'Experienced driver with 10+ years experience.',
      status: 'Approved',
      vehicleId: 'v1',
      vehicleName: 'Toyota Camry 2022',
      vehicleNumber: 'TN-07-AB-1234',
    ),
    VehicleLeaseApplicationModel(
      applicationId: '5',
      applicantId: 'a5',
      applicantName: 'Kavita Singh',
      profileImage: '',
      role: 'Fleet Owner',
      appliedDate: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
      leasePeriodStart: '2024-01-25',
      leasePeriodEnd: '2024-07-25',
      proposedPrice: 27000,
      description: 'Fleet owner looking for reliable vehicles.',
      status: 'Approved',
      vehicleId: 'v1',
      vehicleName: 'Toyota Camry 2022',
      vehicleNumber: 'TN-07-AB-1234',
    ),
    VehicleLeaseApplicationModel(
      applicationId: '6',
      applicantId: 'a6',
      applicantName: 'Ravi Verma',
      profileImage: '',
      role: 'Driver',
      appliedDate: DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
      leasePeriodStart: '2024-02-05',
      leasePeriodEnd: '2024-08-05',
      proposedPrice: 23000,
      description: 'New driver looking for vehicle lease.',
      status: 'Rejected',
      vehicleId: 'v1',
      vehicleName: 'Toyota Camry 2022',
      vehicleNumber: 'TN-07-AB-1234',
    ),
  ];

  List<VehicleLeaseApplicationModel> get _filteredApplications {
    return _allApplications.where((app) => app.status == _selectedStatus).toList();
  }

  int get _pendingCount => _allApplications.where((app) => app.status == 'Pending').length;
  int get _approvedCount => _allApplications.where((app) => app.status == 'Approved').length;
  int get _rejectedCount => _allApplications.where((app) => app.status == 'Rejected').length;

  @override
  Widget build(BuildContext context) {
    // Use provided vehicle or default mock data
    final vehicle = widget.vehicle ?? Vehicle(
      vehicleId: 'v1',
      userId: 'user1',
      vehicleModel: 'Toyota Camry 2022',
      vehicleNumber: 'TN-07-AB-1234',
      manufacturingYear: 2022,
      vehicleType: 'Sedan',
      status: 'Available',
      ownershipType: 'Owned',
      description: '',
      imageUrls: [],
      isDeclarationAccepted: true,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Applications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Vehicle Information Card
          _buildVehicleCard(vehicle),
          
          const SizedBox(height: 16),
          
          // Segmented Control
          _buildSegmentedControl(),
          
          const SizedBox(height: 16),
          
          // Applications List
          Expanded(
            child: _filteredApplications.isEmpty
                ? Center(
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
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredApplications.length,
                    itemBuilder: (context, index) {
                      return _buildApplicationCard(_filteredApplications[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    final vehicleImage = vehicle.imageUrls.isNotEmpty
        ? vehicle.imageUrls.first
        : 'assets/truckImg.png';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Vehicle Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: vehicleImage.startsWith('http')
                  ? Image.network(
                      vehicleImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.local_shipping, size: 40, color: Colors.grey);
                      },
                    )
                  : Image.asset(
                      vehicleImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.local_shipping, size: 40, color: Colors.grey);
                      },
                    ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Vehicle Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        vehicle.vehicleModel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Available',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  vehicle.vehicleNumber,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildVehicleSpec(Icons.speed, '45,230 km'),
                    const SizedBox(width: 12),
                    _buildVehicleSpec(Icons.directions_car, vehicle.vehicleType),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildVehicleSpec(Icons.calendar_today, '${vehicle.manufacturingYear}'),
                    const SizedBox(width: 12),
                    _buildVehicleSpec(Icons.route, '2,500 km/mo'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSpec(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
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
              _pendingCount,
              _selectedStatus == 'Pending',
              () => setState(() => _selectedStatus = 'Pending'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatusButton(
              'Approved',
              _approvedCount,
              _selectedStatus == 'Approved',
              () => setState(() => _selectedStatus = 'Approved'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatusButton(
              'Rejected',
              _rejectedCount,
              _selectedStatus == 'Rejected',
              () => setState(() => _selectedStatus = 'Rejected'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label, int count, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.3) : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(VehicleLeaseApplicationModel application) {
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
              // Profile Picture
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage: application.profileImage.isNotEmpty
                    ? NetworkImage(application.profileImage)
                    : null,
                child: application.profileImage.isEmpty
                    ? Text(
                        application.applicantName[0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              
              // Name and Role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          application.applicantName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildRoleTag(application.role),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Application Age
              Text(
                application.timeAgo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Lease Details
          _buildLeaseDetail(
            Icons.calendar_today,
            'Lease Period',
            '${_formatDate(application.leasePeriodStart)} → ${_formatDate(application.leasePeriodEnd)}',
          ),
          
          const SizedBox(height: 12),
          
          _buildLeaseDetail(
            Icons.currency_rupee,
            'Proposed Price',
            '₹${application.proposedPrice.toStringAsFixed(0)}/month',
          ),
          
          const SizedBox(height: 12),
          
          // Description
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.description, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  application.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
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

  Widget _buildRoleTag(String role) {
    Color backgroundColor;
    Color textColor;

    switch (role.toLowerCase()) {
      case 'driver':
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        break;
      case 'fleet owner':
        backgroundColor = const Color(0xFFF3E5F5);
        textColor = const Color(0xFF7B1FA2);
        break;
      case 'agent':
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        break;
      default:
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildLeaseDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]}';
    } catch (e) {
      return dateString;
    }
  }

  void _handleApprove(VehicleLeaseApplicationModel application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Application'),
        content: Text('Are you sure you want to approve ${application.applicantName}\'s application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Call API to approve application
              setState(() {
                final index = _allApplications.indexWhere((app) => app.applicationId == application.applicationId);
                if (index != -1) {
                  _allApplications[index] = application.copyWith(status: 'Approved');
                }
              });
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Application approved successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
            ),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleReject(VehicleLeaseApplicationModel application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: Text('Are you sure you want to reject ${application.applicantName}\'s application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Call API to reject application
              setState(() {
                final index = _allApplications.indexWhere((app) => app.applicationId == application.applicationId);
                if (index != -1) {
                  _allApplications[index] = application.copyWith(status: 'Rejected');
                }
              });
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Application rejected',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
            ),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
