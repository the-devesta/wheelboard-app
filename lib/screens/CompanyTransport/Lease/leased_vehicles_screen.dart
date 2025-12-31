import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/apps_colors.dart';
import '../../../controllers/Transport/lease_controller.dart';
import '../../../models/transport/lease_models.dart';
import '../../../utils/constants.dart';
import 'lease_details_screen.dart';
import 'add_vehicle_lease_screen.dart';
import 'on_lease_vehicles_screen.dart';

/// Leased Vehicles Screen - Shows list of vehicles available for lease or currently leased
/// Based on Figma Design
class LeasedVehiclesScreen extends StatefulWidget {
  const LeasedVehiclesScreen({super.key});

  @override
  State<LeasedVehiclesScreen> createState() => _LeasedVehiclesScreenState();
}

class _LeasedVehiclesScreenState extends State<LeasedVehiclesScreen> {
  final LeaseController _leaseController = Get.put(LeaseController());
  String _selectedTab = 'All';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _favoriteLeases = {};

  final List<String> _tabs = ['All', 'Available', 'Booked', 'On Lease'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeases();
    });
  }

  Future<void> _loadLeases() async {
    // Assuming this screen shows "My Leases" (Leases created by me, the transport company)
    await _leaseController.fetchMyLeases();
    // Also fetch booked leases if needed for the booked tab?
    // User response for booked leases is separate API: my-booked-lease-list-by-userId
    // But this screen might combine them or mostly focus on 'My Posted Leases'.
    // If 'Booked' tab means "Leases I booked", then I should fetch that too.
    await _leaseController.fetchMyBookedLeases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LeaseListItem> get _filteredLeases {
    List<LeaseListItem> allLeases;
    if (_selectedTab == 'Booked') {
      allLeases = _leaseController.myBookedLeases;
    } else {
      allLeases = _leaseController.leaseList;
    }

    // Filter by search
    final searchFiltered = _searchController.text.isEmpty
        ? allLeases
        : allLeases.where((lease) {
            final query = _searchController.text.toLowerCase();
            return (lease.vehicleTitle?.toLowerCase().contains(query) ??
                    false) ||
                (lease.vehicleNumber?.toLowerCase().contains(query) ?? false);
          }).toList();

    // Filter by tab status
    if (_selectedTab == 'Available') {
      return searchFiltered.where((l) => l.status == 'Available').toList();
    } else if (_selectedTab == 'On Lease') {
      // Show leases that are Active, Booked (by others), or Paused
      // Adjust logic based on exact API status values
      return searchFiltered
          .where(
            (l) =>
                l.status == 'Booked' ||
                l.status == 'Active' ||
                l.status == 'Paused' ||
                l.leaseStatus == 'Paused',
          )
          .toList();
    }

    // For 'All' and 'Booked', return as is (Booked logic handled by different list source above)
    return searchFiltered;
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
                        'No leases found',
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
                  return _buildLeaseCard(leases[index]);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(
            () => const AddVehicleLeaseScreen(),
          )?.then((_) => _loadLeases());
        },
        backgroundColor: AppColors.buttonBg,
        child: const Icon(Icons.add, color: Colors.white),
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
                  'Leased Vehicles',
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

              // Filter Icon
              InkWell(
                onTap: () => _showFilterDialog(),
                child: Container(
                  width: 32,
                  height: 44,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.filter_list,
                    color: Color(0xFF2A2A2A),
                    size: 24,
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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = _selectedTab == tab;

          return GestureDetector(
            onTap: () {
              if (tab == 'On Lease') {
                Get.to(() => const OnLeaseVehiclesScreen());
              } else {
                setState(() {
                  _selectedTab = tab;
                });
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE5E5E5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  tab,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeaseCard(LeaseListItem lease) {
    final isFavorite = _favoriteLeases.contains(lease.leaseId);
    final vehicleImage = lease.imageUrl != null && lease.imageUrl!.isNotEmpty
        ? lease.imageUrl!
        : 'assets/truckImg.png';

    // Determine status and color
    final status = lease.status ?? 'Unknown';
    final statusColor = status == 'Available'
        ? const Color(0xFF28C76F)
        : const Color(0xFFFFB020);

    // Parse dates
    String dateRange = "";
    if (lease.startDate != null) {
      dateRange += _formatDate(lease.startDate!);
    }
    if (lease.endDate != null) {
      dateRange += " → ${_formatDate(lease.endDate!)}";
    }

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
                  child:
                      vehicleImage.startsWith('http') ||
                          vehicleImage.contains('uploads/')
                      ? Image.network(
                          vehicleImage.startsWith('http')
                              ? vehicleImage
                              : '${ApiConstants.baseUrl}$vehicleImage',
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
                        // Favorite Icon
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (lease.leaseId != null) {
                                if (isFavorite) {
                                  _favoriteLeases.remove(lease.leaseId!);
                                } else {
                                  _favoriteLeases.add(lease.leaseId!);
                                }
                              }
                            });
                          },
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey[400],
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lease.vehicleNumber ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Lease Period
                    _buildLeaseInfo(
                      Icons.calendar_today_outlined,
                      dateRange.isNotEmpty ? dateRange : 'N/A',
                    ),
                    const SizedBox(height: 8),

                    // Flat Price
                    _buildLeaseInfo(
                      Icons.currency_rupee,
                      '${lease.flatPrice ?? 0}/day',
                    ),
                    const SizedBox(height: 8),

                    // Odometer
                    _buildLeaseInfo(
                      Icons.speed_outlined,
                      '${lease.odometerStartReading ?? 0} km',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status and View Details
          Row(
            children: [
              // Status Button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),

              // View Details Link
              InkWell(
                onTap: () {
                  if (lease.leaseId != null) {
                    Get.to(() => LeaseDetailsScreen(leaseId: lease.leaseId!));
                  }
                },
                child: Row(
                  children: [
                    Text(
                      'View Details',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.buttonBg,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.buttonBg,
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildActionButtons(lease),
        ],
      ),
    );
  }

  Widget _buildActionButtons(LeaseListItem lease) {
    if (_selectedTab != 'On Lease') return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 16),
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
                  (lease.leaseStatus == 'Paused' || lease.status == 'Paused')
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
    );
  }

  Future<void> _handlePauseResume(LeaseListItem lease) async {
    if (lease.leaseId == null) return;
    String action = (lease.leaseStatus == 'Paused' || lease.status == 'Paused')
        ? 'Resume'
        : 'Pause';

    await showDialog(
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
              _loadLeases(); // Refresh list
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

  Future<void> _handleOffLease(LeaseListItem lease) async {
    if (lease.leaseId == null) return;

    await showDialog(
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
              _loadLeases(); // Refresh list
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

  Widget _buildLeaseInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4B5563),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
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
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Vehicles'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by model or number...',
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
