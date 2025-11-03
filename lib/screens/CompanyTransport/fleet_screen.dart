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
                              final imageUrl = vehicle.imageUrls.first;

                              return _vehicleCard(
                                status: vehicle.status,
                                statusColor: Colors.blue,
                                image: imageUrl.isNotEmpty
                                    ? imageUrl
                                    : 'assets/truckImg.png',
                                title: vehicle.vehicleModel,
                                type: vehicle.vehicleType,
                                driver: vehicle.ownershipType,
                                plate: vehicle.vehicleModel,
                                rating: 0,
                                borderColor: Colors.blue,
                                vehicleData: vehicle, // ✅ Pass vehicle data for editing
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
                              return _vehicleCard(
                                status: "Available",
                                statusColor: Color(0xFF00B894),
                                image: imageUrl.isNotEmpty
                                    ? imageUrl
                                    : "assets/google.png",
                                title: driver.fullName,
                                type: "Driver",
                                driver: "Assigned: ${driver.description}",
                                plate: driver.vehicleNumber,
                                rating: 0,
                                borderColor: Colors.green,
                                driverData: driver, // ✅ Pass driver data for editing
                                onTap: () => {Get.to(DriverProfileScreen())},
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
                  backgroundColor: Colors.redAccent,
                  onPressed: () => Get.to(AddVehicleScreen()),
                  label: const Text(
                    '+ Add Vehicle',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : FloatingActionButton.extended(
                  backgroundColor: Colors.redAccent,
                  onPressed: () => Get.to(AddNewDriverScreen()),
                  label: const Text(
                    '+ Add Driver',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.grey.shade300),
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
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? Colors.redAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : Colors.redAccent,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterButton() {
    return Row(
      children: [
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.tune, color: Colors.teal),
          label: const Text("Filter", style: TextStyle(color: Colors.teal)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 0,
            side: const BorderSide(color: Colors.teal),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
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
    VoidCallback? onTap, // 👈 Add onTap
    Driver? driverData, // ✅ For driver editing
    Vehicle? vehicleData, // ✅ For vehicle editing
  }) {
    final isNetwork = image.startsWith("http");

    return GestureDetector(
      onTap: onTap, // 👈 Trigger tap
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFFF4F4F4),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Status + Image
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.work, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: isNetwork
                        ? Image.network(
                            image,
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, size: 50),
                          )
                        : Image.asset(
                            image,
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
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
                    Text(
                      "$title $type",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Plate: $plate",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Shipment",
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right: action icons
              Column(
                children: [
                  SvgPicture.asset('assets/heart.svg', width: 32, height: 32),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      // ✅ Handle edit based on data type
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
                        
                        // Convert image URLs to Files (if needed)
                        List<File> imageFiles = [];
                        // Note: For editing, we might not have the actual files
                        // The user can select new images if needed
                        
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
                    child: const Icon(Icons.edit, color: Colors.red, size: 18),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
