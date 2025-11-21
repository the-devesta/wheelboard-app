import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wheelboard/screens/CompanyTransport/driver_profile.dart';

import 'add_vehicle.dart';
import 'add_new_driver.dart';
import '../../controllers/fleet_controller.dart'; // adjust the path
import '../../utils/session_manager.dart';
import '../../models/get_driver_model.dart';
import '../../models/get_vehicle_model.dart';
import '../../models/add_drivermodel.dart';
import '../../models/add_new_vehicle_model.dart';
import 'dart:io';

class FleetVehiclesScreen extends StatefulWidget {
  @override
  State<FleetVehiclesScreen> createState() => _FleetVehiclesScreenState();
}

class _FleetVehiclesScreenState extends State<FleetVehiclesScreen> {
  bool isVehicleSelected = false;
  final driverController = Get.put(DriverController());

  @override
  void initState() {
    super.initState();
    _loadSessionAndFetchDrivers();
  }

  Future<void> _loadSessionAndFetchDrivers() async {
    final sessionManager = SessionManager();
    final token = await sessionManager.getString("authToken");
    final userId = await sessionManager.getString("userId");

    // print(userId);
    // print(token);

    if (token != null && userId != null) {
      driverController.fetchDrivers(userId, token);
    } else {
      debugPrint("Token or UserId is null");
    }
  }

  Future<void> _FetchVehicles() async {
    final sessionManager = SessionManager();
    final token = await sessionManager.getString("authToken");
    final userId = await sessionManager.getString("userId");

    // print(userId);
    // print(token);

    if (token != null && userId != null) {
      driverController.fetchVehicles(userId, token);
    } else {
      debugPrint("Token or UserId is null");
    }
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

        // Header
        Positioned(
          top: screenHeight * 0.08,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 60,
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
                    child: Container(
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
                      onPressed: () {},
                      icon: const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                          if (driverController.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (driverController.vehicles.isEmpty) {
                            return const Center(
                              child: Text("No vehicles found"),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: driverController.vehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle = driverController.vehicles[index];
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
                                  statusColor = const Color(0xFFFDBE4D); // Yellow
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
                                type: vehicle.ownershipType,
                                driver: '',
                                plate: vehicle.vehicleNumber,
                                rating: 4.2,
                                borderColor: borderColor,
                                vehicleData: vehicle,
                              );
                            },
                          );
                        })
                      : Obx(() {
                          if (driverController.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (driverController.drivers.isEmpty) {
                            return const Center(
                              child: Text("No drivers found"),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: driverController.drivers.length,
                            itemBuilder: (context, index) {
                              final driver = driverController.drivers[index];
                              final imageUrl = driver.driverImagePath;
                              
                              // Randomly assign status for demo (you can implement actual logic)
                              final statuses = [
                                {'name': 'Hired', 'color': const Color(0xFF00B894), 'border': const Color(0xFF00B894)},
                                {'name': 'Wheelboard', 'color': const Color(0xFF0984E3), 'border': const Color(0xFF0984E3)},
                              ];
                              final statusInfo = statuses[index % statuses.length];
                              
                              return _vehicleCard(
                                status: statusInfo['name'] as String,
                                statusColor: statusInfo['color'] as Color,
                                image: imageUrl.isNotEmpty
                                    ? imageUrl
                                    : "assets/google.png",
                                title: driver.fullName,
                                type: '',
                                driver: driver.description.isNotEmpty 
                                    ? driver.description 
                                    : "Vehicle no.",
                                plate: driver.vehicleNumber,
                                rating: 4.7,
                                borderColor: statusInfo['border'] as Color,
                                driverData: driver,
                                onTap: () {
                                  Get.to(() => DriverProfileScreen(driverId: driver.driverId));
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
      ],
    );
  }

  // --- Widgets ---
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
              _FetchVehicles();
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
              color: selected ? const Color(0xFFF4E3E3) : const Color(0xFFF36767),
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
          GestureDetector(
            onTap: () {
              // Handle filter action
              print("Filter button tapped");
              // You can show a filter dialog or navigate to filter screen
            },
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
                  Icon(
                    Icons.tune,
                    size: 16,
                    color: Color(0xFF00B894),
                  ),
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
    required double rating,
    required Color borderColor,
    VoidCallback? onTap,
    Driver? driverData,
    Vehicle? vehicleData,
  }) {
    final isNetwork = image.startsWith("http");

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: borderColor,
              width: 4,
            ),
          ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                      driverData != null ? Icons.person : Icons.local_shipping,
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
                                      driverData != null ? Icons.person : Icons.local_shipping,
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
                    const SizedBox(height: 28), // Align with image after status badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3436),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (type.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            type,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF535353),
                            ),
                          ),
                        ],
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B894).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Shipment",
                            style: TextStyle(
                              color: Color(0xFF00B894),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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
                    ),
                  ],
                ),
              ),
              
              // Right: Heart + Edit + Arrow
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 28), // Align with content after status badge
                  GestureDetector(
                    onTap: () {
                      // Toggle favorite
                      print("Favorite tapped for $title");
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.favorite_border,
                        color: Color(0xFFF36969),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                              isDeclarationAccepted: driverData.isDeclarationAccepted,
                              modifiedUserId: userId,
                            );
                            
                            Get.to(AddNewDriverScreen(
                              isEditMode: true,
                              driverData: editDriverModel,
                            ));
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
                              isDeclarationAccepted: vehicleData.isDeclarationAccepted,
                              images: imageFiles,
                            );
                            
                            Get.to(AddVehicleScreen(
                              isEditMode: true,
                              vehicleData: editVehicleModel,
                            ));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFFF36969),
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: onTap,
                        child: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF535353),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
