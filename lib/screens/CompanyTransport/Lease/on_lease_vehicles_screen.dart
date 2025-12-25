import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/apps_colors.dart';
import '../../../controllers/fleet_controller.dart';
import '../../../services/auth_service.dart';

/// ON Lease Vehicles Screen - Shows vehicles that are currently on lease
/// Based on Figma Design with tabs: ON Lease, Paused, OFF Lease
class OnLeaseVehiclesScreen extends StatefulWidget {
  const OnLeaseVehiclesScreen({super.key});

  @override
  State<OnLeaseVehiclesScreen> createState() => _OnLeaseVehiclesScreenState();
}

class _OnLeaseVehiclesScreenState extends State<OnLeaseVehiclesScreen> {
  final DriverController _fleetController = Get.find<DriverController>();
  String _selectedTab = 'ON Lease';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tabs = ['ON Lease', 'Paused', 'OFF Lease'];

  // Mock lease data - Replace with actual API data
  final List<Map<String, dynamic>> _leaseData = [
    {
      'vehicle': {
        'id': 'v1',
        'model': 'Toyota Camry 2022',
        'number': 'DL-01-AB-1234',
        'image': 'assets/truckImg.png',
      },
      'lessee': 'Michael Rodriguez',
      'applicationDate': 'Dec 8, 2024',
      'leaseDuration': '6 months',
      'mileage': '32,500 km',
      'status': 'Pending',
    },
    {
      'vehicle': {
        'id': 'v2',
        'model': 'Honda CR-V 2023',
        'number': 'MH-12-CD-5678',
        'image': 'assets/truckImg.png',
      },
      'lessee': 'Sarah Johnson',
      'applicationDate': 'Dec 5, 2024',
      'leaseDuration': '12 months',
      'mileage': '28,000 km',
      'status': 'Active',
    },
    {
      'vehicle': {
        'id': 'v3',
        'model': 'Hyundai i20 2022',
        'number': 'TN-07-EF-9012',
        'image': 'assets/truckImg.png',
      },
      'lessee': 'David Chen',
      'applicationDate': 'Dec 10, 2024',
      'leaseDuration': '3 months',
      'mileage': '15,000 km',
      'status': 'Pending',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final authService = AuthService.to;
    final userId = authService.currentUserId;
    final token = authService.currentToken;

    if (userId.isNotEmpty && token.isNotEmpty) {
      await _fleetController.fetchVehicles(userId, token);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredLeases {
    return _leaseData.where((lease) {
      if (_selectedTab == 'ON Lease') {
        return lease['status'] == 'Pending' || lease['status'] == 'Active';
      } else if (_selectedTab == 'Paused') {
        return lease['status'] == 'Paused';
      } else if (_selectedTab == 'OFF Lease') {
        return lease['status'] == 'OFF Lease';
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(),
          // Tab Navigation
          _buildTabNavigation(),
          
          // Vehicle List
          Expanded(
            child: Obx(() {
              if (_fleetController.isVehicleLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final leases = _filteredLeases;

              if (leases.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No vehicles found',
                        style: GoogleFonts.inter(
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
                padding: const EdgeInsets.all(16),
                itemCount: leases.length,
                itemBuilder: (context, index) {
                  return _buildVehicleCard(leases[index]);
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 77,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(width: 1, color: Color(0xFFE0E0E0))),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Back Button
              InkWell(
                onTap: () => Get.back(),
                child: Container(
                  width: 32,
                  height: 44,
                  alignment: Alignment.centerLeft,
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF2A2A2A),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Title
              Expanded(
                child: Text(
                  'Lease Vehicles',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2A2A2A),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Search Icon
              InkWell(
                onTap: () => _showSearchDialog(),
                child: Container(
                  width: 32,
                  height: 44,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.search,
                    color: Color(0xFF2A2A2A),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Filter Icon with notification dot
              InkWell(
                onTap: () => _showFilterDialog(),
                child: Container(
                  width: 32,
                  height: 44,
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      const Icon(
                        Icons.filter_list,
                        color: Color(0xFF2A2A2A),
                        size: 24,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.buttonBg,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = tab;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.buttonBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> leaseData) {
    final vehicle = leaseData['vehicle'] as Map<String, dynamic>;
    final lessee = leaseData['lessee'] as String;
    final applicationDate = leaseData['applicationDate'] as String;
    final leaseDuration = leaseData['leaseDuration'] as String;
    final mileage = leaseData['mileage'] as String;
    final status = leaseData['status'] as String;
    
    final vehicleImage = vehicle['image'] as String;
    final isPending = status == 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1, color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Image
              Container(
                width: 100,
                height: 100,
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
              const SizedBox(width: 12),
              
              // Vehicle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Model and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vehicle['model'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2A2A2A),
                            ),
                          ),
                        ),
                        if (isPending)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4E6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFFB020),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Pending',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFFFB020),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Lessee/Driver
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          lessee,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Application Date
                    Text(
                      'Applied: $applicationDate',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Lease Duration
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          leaseDuration,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Mileage
                    Row(
                      children: [
                        const Icon(
                          Icons.speed_outlined,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          mileage,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              // Pause Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handlePause(leaseData),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBg,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Pause',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // OFF Lease Button
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleOffLease(leaseData),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF44336),
                    side: const BorderSide(color: Color(0xFFF44336)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'OFF Lease',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(width: 1, color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', false, () {}),
          _buildNavItem(Icons.local_shipping, 'Fleet', true, () {}),
          _buildNavItem(Icons.alt_route_outlined, 'Trips', false, () {}),
          _buildNavItem(Icons.article_outlined, 'Feeds', false, () {}),
          _buildNavItem(Icons.work_outline, 'Jobs', false, () {}),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.buttonBg : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.buttonBg : Colors.grey[600],
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.buttonBg,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  void _handlePause(Map<String, dynamic> leaseData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pause Lease'),
        content: Text('Are you sure you want to pause the lease for ${leaseData['vehicle']['model']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement pause lease API call
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Lease paused successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBg,
            ),
            child: const Text('Pause', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleOffLease(Map<String, dynamic> leaseData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OFF Lease'),
        content: Text('Are you sure you want to mark ${leaseData['vehicle']['model']} as OFF Lease?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement OFF lease API call
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Vehicle marked as OFF Lease',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
            ),
            child: const Text('OFF Lease', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Vehicles'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by model or lessee...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Vehicles'),
        content: const Text('Filter options will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
