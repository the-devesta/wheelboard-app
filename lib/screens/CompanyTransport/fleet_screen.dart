import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wheelboard/screens/CompanyTransport/driver_profile.dart';

import 'package:wheelboard/screens/CompanyTransport/Lease/leased_vehicles_screen.dart';
import 'add_vehicle.dart';
import 'add_new_driver.dart';
import 'vehicle_detail_screen.dart';
import '../../controllers/Transport/fleet_controller.dart'; // adjust the path
import '../../utils/session_manager.dart';
import '../../models/get_driver_model.dart';
import '../../models/get_vehicle_model.dart';
import '../../models/add_drivermodel.dart';
import '../../models/add_new_vehicle_model.dart';
import '../../widgets/custom_loader.dart';
import 'dart:io';
import '../../utils/app_logger.dart';

class FleetVehiclesScreen extends StatefulWidget {
  const FleetVehiclesScreen({super.key});

  @override
  State<FleetVehiclesScreen> createState() => _FleetVehiclesScreenState();
}

class _FleetVehiclesScreenState extends State<FleetVehiclesScreen> {
  bool isVehicleSelected = false;
  final driverController = Get.put(DriverController());

  // Search and filter state
  String _searchQuery = '';
  String _selectedVehicleFilter = 'All Vehicles';
  String _selectedDriverFilter = 'All Drivers';
  final Set<String> _likedDrivers = {};
  final Set<String> _likedVehicles = {};

  @override
  void initState() {
    super.initState();
    _loadSessionAndFetchDrivers();
  }

  Future<void> _loadSessionAndFetchDrivers() async {
    final sessionManager = SessionManager();
    final token = await sessionManager.getString("authToken");
    final userId = await sessionManager.getString("userId");

    // AppLogger.d(userId);
    // AppLogger.d(token);

    if (token != null && userId != null) {
      driverController.fetchDrivers(userId, token);
    } else {
      AppLogger.d("Token or UserId is null");
    }
  }

  Future<void> _fetchVehicles() async {
    final sessionManager = SessionManager();
    final token = await sessionManager.getString("authToken");
    final userId = await sessionManager.getString("userId");

    // AppLogger.d(userId);
    // AppLogger.d(token);

    if (token != null && userId != null) {
      await driverController.fetchVehicles(userId, token);
    } else {
      AppLogger.d("Token or UserId is null");
    }
  }

  // Filter lists based on search query
  List<Vehicle> get _filteredVehicles {
    var vehicles = List<Vehicle>.from(driverController.vehicles);

    // 1. Filter by Status/Ownership
    if (_selectedVehicleFilter != 'All Vehicles') {
      vehicles = vehicles.where((v) {
        final status = v.status.toLowerCase();
        final ownership = v.ownershipType.toLowerCase();

        switch (_selectedVehicleFilter) {
          case 'Available':
            return status == 'available';
          case 'In-Transit':
            return status == 'in-transit' || status == 'in transit';
          case 'Assigned':
            return status == 'assigned';
          case 'Owned':
            return ownership == 'owned';
          case 'Leased':
            return ownership == 'leased';
          default:
            return true;
        }
      }).toList();
    }

    // 2. Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      vehicles = vehicles.where((vehicle) {
        return vehicle.vehicleNumber.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            vehicle.vehicleModel.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }

    return vehicles;
  }

  List<Driver> get _filteredDrivers {
    var drivers = List<Driver>.from(driverController.drivers);

    // 1. Filter by Category
    if (_selectedDriverFilter != 'All Drivers') {
      drivers = drivers.where((d) {
        switch (_selectedDriverFilter) {
          case 'Hired':
            // Using isDeclarationAccepted as a proxy for Verified/Hired
            return d.isDeclarationAccepted;
          case 'Wheelboard':
            return d.description.toLowerCase().contains('wheelboard');
          case 'Available':
            return d.vehicleNumber.isEmpty || d.vehicleNumber == 'N/A';
          case 'On Trip':
            return d.vehicleNumber.isNotEmpty && d.vehicleNumber != 'N/A';
          default:
            return true;
        }
      }).toList();
    }

    // 2. Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      drivers = drivers.where((driver) {
        return driver.fullName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            driver.vehicleNumber.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }

    return drivers;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: SvgPicture.asset('assets/bgDesign.svg', fit: BoxFit.cover),
        ),

        // Body
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            padding: const EdgeInsets.only(top: 10),
            margin: EdgeInsets.only(top: screenHeight * 0.18),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                _tabBar(),
                const SizedBox(height: 12),
                _filterButton(),
                const SizedBox(height: 12),
                Expanded(
                  child: isVehicleSelected
                      ? Obx(() {
                          if (driverController.isVehicleLoading.value) {
                            return const CustomLoader(
                              message: "Loading vehicles...",
                            );
                          }
                          final vehicles = _filteredVehicles;
                          if (vehicles.isEmpty) {
                            return Center(
                              child: Text(
                                _searchQuery.isEmpty
                                    ? "No vehicles found"
                                    : "No vehicles match your search",
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: vehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle = vehicles[index];
                              final imageUrl = vehicle.imageUrls.isNotEmpty
                                  ? vehicle.imageUrls.first
                                  : '';

                              // Determine status color and border color
                              Color statusColor;
                              Color borderColor;
                              String displayStatus = vehicle.status;

                              switch (vehicle.status.toLowerCase()) {
                                case 'in-transit':
                                case 'in transit':
                                  statusColor = const Color(0xFF00B894); // Teal
                                  borderColor = const Color(0xFF00B894);
                                  displayStatus = 'In-Transit';
                                  break;
                                case 'assigned':
                                  statusColor = const Color(0xFF0984E3); // Blue
                                  borderColor = const Color(0xFF0984E3);
                                  displayStatus = 'Assigned';
                                  break;
                                case 'available':
                                  statusColor = const Color(
                                    0xFFFDBE4D,
                                  ); // Yellow
                                  borderColor = const Color(0xFFFDBE4D);
                                  displayStatus = 'Available';
                                  break;
                                default:
                                  statusColor = const Color(0xFF00B894);
                                  borderColor = const Color(0xFF00B894);
                              }

                              return _vehicleCard(
                                status: displayStatus,
                                statusColor: statusColor,
                                image: imageUrl.isNotEmpty
                                    ? imageUrl
                                    : 'assets/truckImg.png',
                                title: vehicle.vehicleModel,
                                type: vehicle.vehicleType,
                                driver: '',
                                plate: vehicle.vehicleNumber,
                                showRating: false,
                                borderColor: borderColor,
                                vehicleData: vehicle,
                                isLiked: _likedVehicles.contains(
                                  vehicle.vehicleId,
                                ),
                                onLikeTap: () {
                                  setState(() {
                                    if (_likedVehicles.contains(
                                      vehicle.vehicleId,
                                    )) {
                                      _likedVehicles.remove(vehicle.vehicleId);
                                    } else {
                                      _likedVehicles.add(vehicle.vehicleId);
                                    }
                                  });
                                },
                                onTap: () {
                                  Get.to(
                                    () => VehicleDetailScreen(vehicle: vehicle),
                                  );
                                },
                              );
                            },
                          );
                        })
                      : Obx(() {
                          if (driverController.isLoading.value) {
                            return const CustomLoader(
                              message: "Loading drivers...",
                            );
                          }
                          final drivers = _filteredDrivers;
                          if (drivers.isEmpty) {
                            return Center(
                              child: Text(
                                _searchQuery.isEmpty
                                    ? "No drivers found"
                                    : "No drivers match your search",
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: drivers.length,
                            itemBuilder: (context, index) {
                              final driver = drivers[index];
                              final imageUrl = driver.driverImagePath;

                              return _vehicleCard(
                                status: 'Hired',
                                statusColor: const Color(0xFF00B894),
                                image: imageUrl.isNotEmpty
                                    ? imageUrl
                                    : "assets/google.png",
                                title: driver.fullName,
                                type: driver.vehicleType,
                                driver: driver.description.isNotEmpty
                                    ? driver.description
                                    : "Vehicle no.",
                                plate: driver.vehicleNumber,
                                showRating: true, // Show rating for drivers
                                rating: 4.7,
                                borderColor: const Color(0xFF00B894),
                                driverData: driver,
                                isLiked: _likedDrivers.contains(
                                  driver.driverId,
                                ),
                                onLikeTap: () {
                                  setState(() {
                                    if (_likedDrivers.contains(
                                      driver.driverId,
                                    )) {
                                      _likedDrivers.remove(driver.driverId);
                                    } else {
                                      _likedDrivers.add(driver.driverId);
                                    }
                                  });
                                },
                                onTap: () {
                                  Get.to(
                                    () => DriverProfileScreen(
                                      driverId: driver.driverId,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }),
                ),
              ],
            ),
          ),
          floatingActionButton: isVehicleSelected
              ? FloatingActionButton.extended(
                  backgroundColor: const Color(0xFFF26868),
                  onPressed: () => Get.to(AddVehicleScreen()),
                  elevation: 2,
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    'Add Vehicle',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                )
              : FloatingActionButton.extended(
                  backgroundColor: const Color(0xFFF26868),
                  onPressed: () => Get.to(AddNewDriverScreen()),
                  elevation: 2,
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    'Add Driver',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
        ),
        _buildHeader(screenHeight),
      ],
    );
  }

  // --- Widgets ---

  // Header Widget (Moved out of Stack to be reusable or just method)
  // Actually, we are inserting it into the Stack children list.

  Widget _buildHeader(double screenHeight) {
    // Check if we can pop the current route (i.e., we are not at the root/tab)
    final canPop = Navigator.canPop(context);

    return Positioned(
      top: screenHeight * 0.08,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 60,
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    "Fleet",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: canPop
                      ? GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black87,
                              size: 20,
                            ),
                          ),
                        )
                      : Container(
                          width: 53,
                          height: 53,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Image.asset('assets/logobg.png'),
                        ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => _showSearchDialog(),
                    icon: const Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F6),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: const Color(0xFFD9D9D9)),
        ),
        child: Row(
          children: [
            _segmentedTabItem("Drivers", !isVehicleSelected, () {
              setState(() => isVehicleSelected = false);
              _loadSessionAndFetchDrivers();
            }),
            _segmentedTabItem("Vehicles", isVehicleSelected, () {
              setState(() => isVehicleSelected = true);
              _fetchVehicles();
            }),
          ],
        ),
      ),
    );
  }

  Widget _segmentedTabItem(String title, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF36767) : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: selected
                  ? const Color(0xFFF4E3E3)
                  : const Color(0xFFF36767),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Filter Button (Left)
          GestureDetector(
            onTap: () => _showFilterDialog(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE4E8EB)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune, size: 16, color: Color(0xFF00B894)),
                  SizedBox(width: 6),
                  Text(
                    "Filter",
                    style: TextStyle(
                      color: Color(0xFF636E72),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(), // ✅ Pushes Lease button to the right
          // Lease Button (Right)
          GestureDetector(
            onTap: () => Get.to(() => const LeasedVehiclesScreen()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white, // White background matching filter
                border: Border.all(color: const Color(0xFFE4E8EB)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 16,
                    color: Color(0xFFF36767), // Reddish icon
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Lease",
                    style: TextStyle(
                      color: Color(0xFF636E72), // Grey text
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vehicleCard({
    required String status,
    required Color statusColor,
    required String image,
    required String title,
    required String type,
    required String driver,
    required String plate,
    required bool showRating,
    double rating = 0,
    required Color borderColor,
    VoidCallback? onTap,
    Driver? driverData,
    Vehicle? vehicleData,
    bool isLiked = false,
    VoidCallback? onLikeTap,
  }) {
    final isNetwork = image.startsWith("http");

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: borderColor, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Image with status badge on top
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Image
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: isNetwork
                          ? Image.network(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Icon(
                                      driverData != null
                                          ? Icons.person
                                          : Icons.local_shipping,
                                      size: 32,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                            )
                          : Image.asset(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Icon(
                                      driverData != null
                                          ? Icons.person
                                          : Icons.local_shipping,
                                      size: 32,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Center: Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 28,
                    ), // Align with image after status badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3436),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (driver.isNotEmpty)
                      Text(
                        driver,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF636E72),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),
                    Text(
                      "Plate: $plate",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF636E72),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _shipmentBadge(
                          driverData?.vehicleType ??
                              vehicleData?.vehicleType ??
                              type,
                        ),
                        if (showRating) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Color(0xFFE74C3C),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Color(0xFFE74C3C),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Right: Edit Icon at Top
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () async {
                      // Handle edit based on data type
                      if (driverData != null) {
                        // Edit Driver
                        final sessionManager = SessionManager();
                        final userId = await sessionManager.getString("userId");

                        final editDriverModel = DriverModel(
                          userId: userId,
                          driverId: driverData.driverId,
                          fullName: driverData.fullName,
                          contactNumber: driverData.contactNumber,
                          vehicleType: driverData.vehicleType,
                          vehicleNumber: driverData.vehicleNumber,
                          description: driverData.description,
                          isDeclarationAccepted:
                              driverData.isDeclarationAccepted,
                          modifiedUserId: userId,
                        );

                        Get.to(
                          AddNewDriverScreen(
                            isEditMode: true,
                            driverData: editDriverModel,
                          ),
                        );
                      } else if (vehicleData != null) {
                        // Edit Vehicle
                        final sessionManager = SessionManager();
                        final userId = await sessionManager.getString("userId");

                        List<File> imageFiles = [];

                        final editVehicleModel = VehicleModel(
                          userId: userId,
                          vehicleId: vehicleData.vehicleId,
                          vehicleModel: vehicleData.vehicleModel,
                          vehicleNumber: vehicleData.vehicleNumber,
                          manufacturingYear: vehicleData.manufacturingYear,
                          ownershipType: vehicleData.ownershipType,
                          vehicleType: vehicleData.vehicleType,
                          description: vehicleData.description,
                          isDeclarationAccepted:
                              vehicleData.isDeclarationAccepted,
                          images: imageFiles,
                        );

                        Get.to(
                          AddVehicleScreen(
                            isEditMode: true,
                            vehicleData: editVehicleModel,
                          ),
                        );
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.edit,
                        color: Color(0xFFF36969),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Vehicle Type badge widget
  Widget _shipmentBadge(String vehicleType) {
    final displayType = vehicleType.isNotEmpty ? vehicleType : 'N/A';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF00B894).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayType,
        style: const TextStyle(
          color: Color(0xFF00B894),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Search dialog
  void _showSearchDialog() {
    final searchController = TextEditingController(text: _searchQuery);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isVehicleSelected ? 'Search Vehicles' : 'Search Drivers',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: isVehicleSelected
                ? 'Enter vehicle number or model...'
                : 'Enter driver name or plate...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFFF36969)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF36969)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF36969),
            ),
            onPressed: () {
              setState(() => _searchQuery = searchController.text.trim());
              Navigator.pop(context);
              // Show result snackbar
              if (_searchQuery.isNotEmpty) {
                Get.snackbar(
                  'Searching',
                  'Searching for "$_searchQuery"...',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFFF36969),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              }
            },
            child: const Text('Search', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Filter dialog
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if ((isVehicleSelected &&
                          _selectedVehicleFilter != 'All Vehicles') ||
                      (!isVehicleSelected &&
                          _selectedDriverFilter != 'All Drivers'))
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (isVehicleSelected) {
                            _selectedVehicleFilter = 'All Vehicles';
                          } else {
                            _selectedDriverFilter = 'All Drivers';
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: Color(0xFFF36969)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (isVehicleSelected) ...[
                // Vehicle filters
                _filterOption('All Vehicles', Icons.local_shipping),
                _filterOption(
                  'Available',
                  Icons.check_circle,
                  color: Colors.green,
                ),
                _filterOption(
                  'In-Transit',
                  Icons.directions_car,
                  color: Colors.blue,
                ),
                _filterOption(
                  'Assigned',
                  Icons.assignment,
                  color: Colors.orange,
                ),
                _filterOption('Owned', Icons.home, color: Colors.purple),
                _filterOption('Leased', Icons.handshake, color: Colors.teal),
              ] else ...[
                // Driver filters
                _filterOption('All Drivers', Icons.people),
                _filterOption('Hired', Icons.verified, color: Colors.green),
                _filterOption('Wheelboard', Icons.circle, color: Colors.blue),
                _filterOption(
                  'Available',
                  Icons.check_circle,
                  color: Colors.green,
                ),
                _filterOption(
                  'On Trip',
                  Icons.directions_car,
                  color: Colors.orange,
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterOption(
    String label,
    IconData icon, {
    Color color = Colors.grey,
  }) {
    final isSelected = isVehicleSelected
        ? _selectedVehicleFilter == label
        : _selectedDriverFilter == label;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFFF36969) : Colors.black,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFFF36969))
          : null,
      onTap: () {
        setState(() {
          if (isVehicleSelected) {
            _selectedVehicleFilter = label;
          } else {
            _selectedDriverFilter = label;
          }
        });
        Navigator.pop(context);
        // Get.snackbar(
        //   'Filter Applied',
        //   'Showing: $label',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: const Color(0xFFF36969),
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 2),
        // );
      },
    );
  }
}
