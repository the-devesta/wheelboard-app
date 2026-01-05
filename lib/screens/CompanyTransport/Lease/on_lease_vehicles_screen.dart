import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/apps_colors.dart';
import '../../../controllers/Transport/lease_controller.dart';
import '../../../models/transport/lease_models.dart';

import '../../../utils/constants.dart';
import 'applications_screen.dart';

/// ON Lease Vehicles Screen - Shows vehicles that are currently on lease
/// Based on Figma Design with tabs: ON Lease, Paused, OFF Lease
class OnLeaseVehiclesScreen extends StatefulWidget {
  const OnLeaseVehiclesScreen({super.key});

  @override
  State<OnLeaseVehiclesScreen> createState() => _OnLeaseVehiclesScreenState();
}

class _OnLeaseVehiclesScreenState extends State<OnLeaseVehiclesScreen> {
  final LeaseController _leaseController = Get.find<LeaseController>();
  String _selectedTab = 'ON Lease';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tabs = ['ON Lease', 'Paused', 'OFF Lease'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeases();
    });
  }

  Future<void> _loadLeases() async {
    await _leaseController.fetchMyLeases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LeaseListItem> get _filteredLeases {
    final allLeases = _leaseController.leaseList;

    // Filter logic based on tab and status
    // Assuming status strings from API
    return allLeases.where((lease) {
      if (_selectedTab == 'ON Lease') {
        // Show Booked or Active leases.
        // Adjust based on actual API status values. 'Booked' is likely one.
        return lease.status == 'Booked' || lease.status == 'Active';
      } else if (_selectedTab == 'Paused') {
        return lease.leaseStatus == 'Paused' || lease.status == 'Paused';
      } else if (_selectedTab == 'OFF Lease') {
        // Leases that are terminated? Or maybe 'Closed'?
        // Or maybe just filter by some other property.
        // For now assuming a status 'Off' or 'Completed' exists.
        // Or simply "Available" leases are "OFF Lease" (ready for new lease)?
        // User prompt mentioned "off-leases" API.
        return lease.status == 'Off' || lease.status == 'Available';
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
              if (_leaseController.isLoading.value) {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B7280),
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

  Widget _buildVehicleCard(LeaseListItem lease) {
    final vehicleImage = lease.imageUrl != null && lease.imageUrl!.isNotEmpty
        ? (lease.imageUrl!.startsWith('http') ||
                  lease.imageUrl!.contains('uploads/')
              ? (lease.imageUrl!.startsWith('http')
                    ? lease.imageUrl!
                    : '${ApiConstants.baseUrl}${lease.imageUrl}')
              : lease.imageUrl!)
        : 'assets/truckImg.png';

    final isPending = lease.status == 'Pending';

    return GestureDetector(
      onTap: () {
        if (lease.leaseId != null) {
          Get.to(
            () => ApplicationsScreen(
              leaseId: lease.leaseId!,
              vehicleTitle: lease.vehicleTitle ?? "",
            ),
          );
        }
      },
      child: Container(
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
                              return const Icon(
                                Icons.local_shipping,
                                size: 40,
                                color: Colors.grey,
                              );
                            },
                          )
                        : Image.asset(
                            vehicleImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.local_shipping,
                                size: 40,
                                color: Colors.grey,
                              );
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
                              lease.vehicleTitle ?? 'Unknown Vehicle',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2A2A2A),
                              ),
                            ),
                          ),
                          if (isPending)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
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

                      // Lessee Info (If booked)
                      // API doesn't seem to return Lessee name in list item directly,
                      // but if it did it would be mapped here.
                      // For now, placeholder or maybe check API again.
                      // "ownerName" is in details. List item has minimal info.
                      // I'll skip lessee name if not available
                      const SizedBox(height: 6),

                      // Lease Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          lease.leaseStatus ?? lease.status ?? 'Unknown',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            if (_selectedTab != 'OFF Lease') // Don't show if already off
              Row(
                children: [
                  // Pause/Resume Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handlePauseResume(lease),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (lease.leaseStatus == 'Paused' ||
                                lease.status == 'Paused')
                            ? Colors.green
                            : AppColors.buttonBg,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        (lease.leaseStatus == 'Paused' ||
                                lease.status == 'Paused')
                            ? 'Resume'
                            : 'Pause',
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
                      onPressed: () => _handleOffLease(lease),
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
      ),
    );
  }

  void _handlePauseResume(LeaseListItem lease) {
    if (lease.leaseId == null) return;
    String action = (lease.leaseStatus == 'Paused' || lease.status == 'Paused')
        ? 'Resume'
        : 'Pause';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action Lease'),
        content: Text(
          'Are you sure you want to $action the lease for ${lease.vehicleTitle}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _leaseController.togglePauseResume(lease.leaseId!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBg,
            ),
            child: Text(action, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleOffLease(LeaseListItem lease) {
    if (lease.leaseId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OFF Lease'),
        content: Text(
          'Are you sure you want to mark ${lease.vehicleTitle} as OFF Lease?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _leaseController.offLease(lease.leaseId!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
            ),
            child: const Text(
              'OFF Lease',
              style: TextStyle(color: Colors.white),
            ),
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
