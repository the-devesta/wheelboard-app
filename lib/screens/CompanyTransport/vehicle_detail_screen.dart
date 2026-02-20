import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/get_vehicle_model.dart';
import '../../models/vehicle_detail_response_model.dart';
import '../../controllers/Transport/main_wrapper_controller.dart';
import '../../controllers/Transport/fleet_controller.dart';
import '../../utils/session_manager.dart';
import '../../widgets/custom_loader.dart';
import '../../utils/call_utils.dart';
import 'Lease/add_vehicle_lease_screen.dart';
import 'schedulescreen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final DriverController _fleetController = Get.find<DriverController>();
  String _selectedStatus = 'Available';

  @override
  void initState() {
    super.initState();
    _loadVehicleDetails();
    // Set initial status based on vehicle status, default to Assigned if available
    final status = widget.vehicle.status.toLowerCase();
    if (status == 'assigned' ||
        status == 'in-transit' ||
        status == 'available') {
      _selectedStatus = widget.vehicle.status;
    } else {
      _selectedStatus =
          'Assigned'; // Default to Assigned as shown in screenshot
    }
  }

  Future<void> _loadVehicleDetails() async {
    final sessionManager = SessionManager();
    final token = await sessionManager.getString("authToken");

    if (token != null && token.isNotEmpty) {
      await _fleetController.fetchVehicleDetails(
        widget.vehicle.vehicleId,
        token,
      );
    }
  }

  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Get vehicle info from API or fallback to widget.vehicle
      final vehicleDetails = _fleetController.vehicleDetails.value;
      final vehicleInfo =
          vehicleDetails?.data.vehicleInfo ??
          VehicleInfo(
            vehicleId: widget.vehicle.vehicleId,
            vehicleModel: widget.vehicle.vehicleModel,
            vehicleNumber: widget.vehicle.vehicleNumber,
            manufacturingYear: widget.vehicle.manufacturingYear,
            status: widget.vehicle.status,
            ownershipType: widget.vehicle.ownershipType,
          );

      // Get current status from API or use selected status
      final currentStatus = vehicleInfo.status.isNotEmpty
          ? vehicleInfo.status
          : _selectedStatus;

      // Get vehicle image
      final vehicleImage = widget.vehicle.imageUrls.isNotEmpty
          ? widget.vehicle.imageUrls.first
          : 'assets/truckImg.png';

      // Get driver info
      final driverInfo = vehicleDetails?.data.driverInfo;
      final hasDriver =
          driverInfo != null &&
          driverInfo.driverId != null &&
          driverInfo.driverName.isNotEmpty;

      // Get recent trips
      final recentTrips = vehicleDetails?.data.recentTrips ?? [];

      return Scaffold(
        backgroundColor: const Color(0xFFF4E3E3),
        body: Stack(
          children: [
            // Vehicle Image Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 404,
              child: Stack(
                children: [
                  // Background Image
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color(0xFFDFE6E9),
                    child: vehicleImage.startsWith('http')
                        ? Image.network(
                            vehicleImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.local_shipping,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const CustomLoader.small();
                            },
                          )
                        : vehicleImage.isNotEmpty &&
                              vehicleImage != 'assets/truckImg.png'
                        ? Image.asset(
                            vehicleImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.local_shipping,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.local_shipping,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  // Vehicle Info Badge (positioned at 91px AppBar + 133.5px = 224.5px from top)
                  Positioned(
                    left: 16,
                    top: 224.5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.87),
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            vehicleInfo.vehicleModel,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '|',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFF636E72),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            vehicleInfo.vehicleNumber,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 13,
                              color: Color(0xFF636E72),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10E445),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Owned Badge
                  Positioned(
                    top: 103,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5E5E),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        vehicleInfo.ownershipType,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Positioned(
              top: 278,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 38.952,
                      offset: Offset(0, 24.484),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Year of Manufacture and Delete Vehicle in same row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Year of Manufacture
                            Padding(
                              padding: const EdgeInsets.only(left: 19),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Color(0xFF636E72),
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Year of Manufacture: ',
                                    ),
                                    TextSpan(
                                      text: vehicleInfo.manufacturingYear
                                          .toString(),
                                      style: const TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF636E72),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Delete Vehicle Button
                            GestureDetector(
                              onTap: () async {
                                final sessionManager = SessionManager();
                                final userId = await sessionManager.getString(
                                  "userId",
                                );
                                final token = await sessionManager.getString(
                                  "authToken",
                                );

                                if (userId == null ||
                                    token == null ||
                                    userId.isEmpty) {
                                  Get.snackbar(
                                    "Error",
                                    "User not found, please login again",
                                  );
                                  return;
                                }

                                Get.dialog(
                                  AlertDialog(
                                    title: const Text('Delete Vehicle'),
                                    content: const Text(
                                      'Are you sure you want to delete this vehicle?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Get.back(); // close confirmation dialog
                                          // show loading
                                          Get.dialog(
                                            const Center(
                                              child: CustomLoader.small(),
                                            ),
                                            barrierDismissible: false,
                                          );

                                          try {
                                            final success =
                                                await _fleetController
                                                    .deleteVehicle(
                                                      widget.vehicle.vehicleId,
                                                      userId,
                                                      token,
                                                    );

                                            // Close loading dialog
                                            if (Get.isDialogOpen ?? false) {
                                              Get.back();
                                            }

                                            if (success) {
                                              Get.back(); // close screen
                                              _fleetController.fetchVehicles(
                                                userId,
                                                token,
                                              ); // refresh list
                                              Get.snackbar(
                                                "Success",
                                                "Vehicle deleted successfully",
                                                backgroundColor: Colors.green,
                                                colorText: Colors.white,
                                              );
                                            } else {
                                              Get.snackbar(
                                                "Error",
                                                "Failed to delete vehicle",
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                              );
                                            }
                                          } catch (e) {
                                            // Close loading dialog if open
                                            if (Get.isDialogOpen ?? false) {
                                              Get.back();
                                            }
                                            Get.snackbar(
                                              "Error",
                                              "An error occurred: $e",
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Delete Vehicle',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 14,
                                      color: Color(0xFF636E72),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Image.asset(
                                    'assets/icons/delete.png',
                                    width: 14,
                                    height: 14,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.delete_outline,
                                              size: 14,
                                              color: Color(0xFF636E72),
                                            ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Driver Assigned Section (if driver is assigned) or Available/Off Lease Toggle
                      if (hasDriver)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 45),
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC7DCDA),
                              borderRadius: BorderRadius.circular(72),
                            ),
                            child: Row(
                              children: [
                                // Driver Info Section (Left side)
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child:
                                              driverInfo.driverImage != null &&
                                                  driverInfo
                                                      .driverImage!
                                                      .isNotEmpty
                                              ? Image.network(
                                                  driverInfo.driverImage!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const Icon(
                                                        Icons.person,
                                                        size: 24,
                                                      ),
                                                )
                                              : Image.asset(
                                                  'assets/google.png',
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const Icon(
                                                        Icons.person,
                                                        size: 24,
                                                      ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Driver Assigned',
                                              style: TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 13,
                                                color: Color(0xFF636E72),
                                                height: 1.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              driverInfo.driverName,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                                color: Color(0xFF2D3436),
                                                height: 1.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Contact Driver Button
                                InkWell(
                                  onTap: () {
                                    CallUtils.makeCall(driverInfo.driverMobile);
                                  },
                                  child: Container(
                                    height: 28,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00B894),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.5),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Contact Driver',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 45,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC7DCDA),
                              borderRadius: BorderRadius.circular(72),
                            ),
                            child: Row(
                              children: [
                                // Available Button (Left side)
                                Expanded(
                                  child: Container(
                                    height: 37,
                                    decoration: BoxDecoration(
                                      color:
                                          currentStatus.toLowerCase() ==
                                              'assigned'
                                          ? const Color(0xFF0984E3)
                                          : currentStatus.toLowerCase() ==
                                                'in-transit'
                                          ? const Color(0xFF00B894)
                                          : const Color(0xFF10E445),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.5),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        currentStatus,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // OFF Lease Toggle (Right side)
                                if (currentStatus.toLowerCase() == 'available')
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        // Navigate to Add Vehicle Lease Screen
                                        Get.to(
                                          () => AddVehicleLeaseScreen(
                                            preselectedVehicle: widget.vehicle,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 37,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'OFF Lease',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: Color(0xFFF26868),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Toggle Switch
                                            Container(
                                              width: 40,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE0E0E0),
                                                borderRadius:
                                                    BorderRadius.circular(11),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: 2,
                                                    top: 2,
                                                    child: Container(
                                                      width: 18,
                                                      height: 18,
                                                      decoration:
                                                          const BoxDecoration(
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Color(
                                                                  0x29000000,
                                                                ),
                                                                blurRadius: 2,
                                                                offset: Offset(
                                                                  0,
                                                                  1,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Status Toggle Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 9),
                              child: Text(
                                'Status',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  color: Color(0xFF535353),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 34,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6FA),
                                borderRadius: BorderRadius.circular(9999),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  _buildStatusButton(
                                    'In-Transit',
                                    const Color(0xFF00B894),
                                    0,
                                    currentStatus,
                                  ),
                                  _buildStatusButton(
                                    'Assigned',
                                    const Color(0xFF0984E3),
                                    1,
                                    currentStatus,
                                  ),
                                  _buildStatusButton(
                                    'Available',
                                    const Color(0xFF10E445),
                                    2,
                                    currentStatus,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Stats Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Avg. Run',
                                // '${(vehicleDetails?.data.monthlyUsageKM ?? 0).round()} KM',
                                '${(vehicleDetails?.data.monthlyUsageKM ?? 0).toStringAsFixed(2)} KM',
                                const Color(0xFF00B894),
                                Icons.speed,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Trip Efficiency',
                                // 'Rs. ${(vehicleDetails?.data.costPerKM ?? 0).round()} / KM',
                                'Rs. ${(vehicleDetails?.data.costPerKM ?? 0).toStringAsFixed(2)} / KM',
                                const Color(0xFFFF6B6B),
                                Icons.trending_up,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 39),
                                child: const Text(
                                  'Monthly Usage',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Color(0xFF2D3436),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 47),
                                child: const Text(
                                  'Cost per KM',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Color(0xFF2D3436),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Recent Trips Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Recent Trips:',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: Color(0xFF2D3436),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _fleetController.isVehicleDetailsLoading.value
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CustomLoader.small(),
                                    ),
                                  )
                                : recentTrips.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Center(
                                      child: Text(
                                        'No recent trips found',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color: Color(0xFF636E72),
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: recentTrips.take(3).map((trip) {
                                      return _buildRecentTripCard(
                                        trip.tripCode,
                                        trip.getRoute(),
                                        driverInfo?.driverImage ??
                                            'assets/truckImg.png',
                                      );
                                    }).toList(),
                                  ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 100,
                      ), // Space for bottom nav and schedule button
                    ],
                  ),
                ),
              ),
            ),

            // App Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 91,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFFFCD2D2),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Vehicle Number - Centered
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 63),
                        child: Text(
                          vehicleInfo.vehicleNumber,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Color(0xFF636E72),
                          ),
                        ),
                      ),
                    ),
                    // Back Button
                    Positioned(
                      left: 27,
                      top: 55,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                    // Close Button
                    Positioned(
                      right: 16,
                      top: 51,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: const Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Schedule Trip Floating Action Button
            Positioned(
              bottom: 15,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () {
                  // Navigate to schedule screen
                  Get.to(() => const ScheduleTripScreen());
                },
                backgroundColor: const Color(0xFFF26868),
                elevation: 25,
                icon: const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Schedule Trip',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      );
    });
  }

  Widget _buildStatusButton(
    String label,
    Color color,
    int index,
    String currentStatus,
  ) {
    final isSelected = currentStatus.toLowerCase() == label.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (mounted) {
            setState(() {
              _selectedStatus = label;
            });
          }
        },
        child: Container(
          height: 26,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? (index == 1
                      ? color.withOpacity(0.1)
                      : index == 0
                      ? Colors.transparent
                      : color.withOpacity(0.1))
                : Colors.transparent,
            border: isSelected && index == 1
                ? Border.all(color: color, width: 1)
                : null,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon for In-Transit (green dot when selected)
              if (index == 0)
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              // Icon for Assigned (blue flag icon)
              if (index == 1)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.flag,
                    size: 12,
                    color: isSelected ? color : Colors.transparent,
                  ),
                ),
              // Dot for Available (empty circle when not selected)
              if (index == 2)
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: isSelected ? color : const Color(0xFFB2BEC3),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: Color(0xFF636E72),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTripCard(String tripId, String route, String image) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: ClipOval(
              child: image.startsWith('http')
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.local_shipping, size: 24),
                    )
                  : Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.local_shipping, size: 24),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip Id:  $tripId',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  route,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    color: Color(0xFF636E72),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF636E72)),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        border: Border.all(color: const Color(0xFFE4E8EB), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', 0, false),
          _buildNavItem(Icons.local_shipping, 'Fleet', 1, true),
          _buildNavItem(Icons.alt_route, 'Trips', 2, false),
          _buildNavItem(Icons.article_outlined, 'Feeds', 3, false),
          _buildNavItem(Icons.work_outline, 'Jobs', 4, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isActive) {
    final wrapperController = Get.find<MainWrapperController>();
    return GestureDetector(
      onTap: () {
        wrapperController.currentTabIndex.value = index;
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? const Color(0xFFFF5E5E) : const Color(0xFF535353),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: isActive ? 11 : 12,
              color: isActive
                  ? const Color(0xFFFF5E5E)
                  : const Color(0xFF535353),
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 28,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5E5E),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        ],
      ),
    );
  }
}
