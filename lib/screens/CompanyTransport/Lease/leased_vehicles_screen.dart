import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/apps_colors.dart';
import '../../../models/get_vehicle_model.dart';
import '../../../controllers/fleet_controller.dart';
import '../../../services/auth_service.dart';
import 'lease_details_screen.dart';

/// Leased Vehicles Screen - Shows list of vehicles available for lease or currently leased
/// Based on Figma Design
class LeasedVehiclesScreen extends StatefulWidget {
  const LeasedVehiclesScreen({super.key});

  @override
  State<LeasedVehiclesScreen> createState() => _LeasedVehiclesScreenState();
}

class _LeasedVehiclesScreenState extends State<LeasedVehiclesScreen> {
  final DriverController _fleetController = Get.find<DriverController>();
  String _selectedTab = 'All';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _favoriteVehicles = {};

  final List<String> _tabs = ['All', 'Available', 'bookings', 'Leased'];

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

  List<Vehicle> get _filteredVehicles {
    final allVehicles = _fleetController.vehicles;
    
    // Filter by search
    final searchFiltered = _searchController.text.isEmpty
        ? allVehicles
        : allVehicles.where((vehicle) {
            final query = _searchController.text.toLowerCase();
            return vehicle.vehicleModel.toLowerCase().contains(query) ||
                vehicle.vehicleNumber.toLowerCase().contains(query);
          }).toList();

    // Filter by tab
    if (_selectedTab == 'All') {
      return searchFiltered;
    } else if (_selectedTab == 'Available') {
      return searchFiltered.where((v) => v.status == 'Available').toList();
    } else if (_selectedTab == 'bookings') {
      return searchFiltered.where((v) => v.status == 'Booked').toList();
    } else if (_selectedTab == 'Leased') {
      return searchFiltered.where((v) => v.ownershipType == 'Leased' || v.status == 'Leased').toList();
    }
    
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
              if (_fleetController.isVehicleLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final vehicles = _filteredVehicles;

              if (vehicles.isEmpty) {
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
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  return _buildVehicleCard(vehicles[index]);
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
              setState(() {
                _selectedTab = tab;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE5E5E5) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  tab,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? const Color(0xFF2A2A2A) : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    final isFavorite = _favoriteVehicles.contains(vehicle.vehicleId);
    final vehicleImage = vehicle.imageUrls.isNotEmpty
        ? vehicle.imageUrls.first
        : 'assets/truckImg.png';
    
    // Determine status and color
    final status = _getVehicleStatus(vehicle);
    final statusColor = status == 'Available' 
        ? const Color(0xFF28C76F) 
        : const Color(0xFFFFB020);

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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vehicle.vehicleModel,
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
                              if (isFavorite) {
                                _favoriteVehicles.remove(vehicle.vehicleId);
                              } else {
                                _favoriteVehicles.add(vehicle.vehicleId);
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
                      vehicle.vehicleNumber,
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
                      'Jan 15 → Jun 15, 2024', // Mock data - replace with actual lease period
                    ),
                    const SizedBox(height: 8),
                    
                    // Monthly KM Limit
                    _buildLeaseInfo(
                      Icons.directions_car_outlined,
                      '2,500 km/month', // Mock data
                    ),
                    const SizedBox(height: 8),
                    
                    // Current Total KM
                    _buildLeaseInfo(
                      Icons.speed_outlined,
                      '45,230 km', // Mock data - use actual odometer reading
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  Get.to(() => LeaseDetailsScreen());
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
        ],
      ),
    );
  }

  Widget _buildLeaseInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  String _getVehicleStatus(Vehicle vehicle) {
    if (vehicle.status == 'Available') {
      return 'Available';
    } else if (vehicle.status == 'Booked' || vehicle.status == 'On Trip') {
      return 'Booked';
    } else {
      return vehicle.status;
    }
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
