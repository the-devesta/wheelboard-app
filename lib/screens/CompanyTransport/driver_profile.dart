import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/driver_details_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_loader.dart';
import '../../utils/app_logger.dart';
import '../../utils/session_manager.dart';

class DriverProfileScreen extends StatefulWidget {
  final String driverId;

  const DriverProfileScreen({super.key, required this.driverId});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final DriverDetailsController controller = Get.put(DriverDetailsController());

  @override
  void initState() {
    super.initState();
    controller.fetchDriverDetails(widget.driverId);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background SVG
        Positioned.fill(
          child: SvgPicture.asset('assets/bgDesign.svg', fit: BoxFit.cover),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CustomLoader.small());
            }

            final driver = controller.driverDetails.value;
            if (driver == null) {
              return const Center(
                child: Text(
                  "Driver details not found",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            }

            // Get driver image URL - only if available
            String? driverImageUrl;
            if (driver.driverImagePath != null &&
                driver.driverImagePath!.isNotEmpty) {
              final imagePath = driver.driverImagePath!.trim();
              if (imagePath.isNotEmpty &&
                  imagePath != 'https://wheelboardapi.addonshareware.com/') {
                driverImageUrl = imagePath.startsWith('http')
                    ? imagePath
                    : ApiConstants.baseUrl + imagePath;
              }
            }

            return SafeArea(
              top: true,
              bottom: false,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 60,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Center(
                              child: Text(
                                "Driver Profile",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Left side: Logo + Back Button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Logo
                                  Container(
                                    width: 37,
                                    height: 37,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: Image.asset(
                                      'assets/logobg.png',
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.image,
                                                size: 20,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Back Button
                                  GestureDetector(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.black87,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Right side: Calendar Icon
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                onPressed: () =>
                                    _showTripCalendar(driver.fullName),
                                icon: const Icon(
                                  Icons.calendar_month,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),

                    // Main Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 24, bottom: 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Top row with avatar + buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _actionButton(
                                Icons.call,
                                "Call",
                                onTap: () async {
                                  await _makePhoneCall(driver.contactNumber);
                                },
                              ),

                              // Profile Avatar - always show, with or without image
                              driverImageUrl != null
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.grey[300],
                                      backgroundImage: NetworkImage(
                                        driverImageUrl,
                                      ),
                                      onBackgroundImageError:
                                          (exception, stackTrace) {
                                            // Image failed to load - will show empty circle
                                          },
                                    )
                                  : CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.grey[300],
                                      child: const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),

                              _actionButton(
                                Icons.email,
                                "Email",
                                onTap: () async {
                                  await _sendEmail(
                                    driver.fullName,
                                    driver.contactNumber,
                                  );
                                },
                              ),
                            ],
                          ),
                          // Status Chip
                          Chip(
                            avatar: const Icon(
                              Icons.work,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(driver.vehicleType.toUpperCase()),
                            backgroundColor: Colors.green,
                            labelStyle: const TextStyle(color: Colors.white),
                          ),

                          const SizedBox(height: 12),

                          // Name + Icons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  // Delete Driver Logic
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
                                      title: const Text('Delete Driver'),
                                      content: const Text(
                                        'Are you sure you want to delete this driver?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Get.back(); // close dialog
                                            // show loading
                                            Get.dialog(
                                              const Center(
                                                child: CustomLoader.small(),
                                              ),
                                              barrierDismissible: false,
                                            );
                                            // Use FleetController (DriverController) for delete as it has the list
                                            // Or use HttpHelper directly here if controller not available
                                            // But best practice is controller.
                                            // I'll assume we can use the same delete logic. A clean way is to put delete logic in DriverDetailsController too or use FleetController.
                                            // Let's see if I can instantiate FleetController (DriverController).
                                            // It might not be in context.
                                            // I'll add deleteDriver to DriverDetailsController.

                                            final success = await controller
                                                .deleteDriver(
                                                  widget.driverId,
                                                  userId,
                                                  token,
                                                );

                                            Get.back(); // close loading

                                            if (success) {
                                              Get.back(); // close profile screen
                                              // Ideally refresh previous screen (Fleet Screen)
                                              // But since we are going back, Fleet Screen might need to refresh on appear or use Get.find<DriverController>().fetchDrivers(...)
                                              // I'll try to refresh FleetController if it exists
                                              try {
                                                // refresh fleet list
                                                // Get.find<DriverController>().fetchDrivers(userId, token); // DriverController from fleet_controller.dart
                                                // The import conflicts might occur if I import fleet_controller.dart here.
                                                // I'll let the onBack logic handle refresh if any, or just pop.
                                                // The user asked to just put the API.
                                              } catch (e) {
                                                // Fleet controller might not be found
                                              }
                                              Get.snackbar(
                                                "Success",
                                                "Driver deleted successfully",
                                                backgroundColor: Colors.green,
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
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  driver.fullName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.favorite_border,
                                color: Colors.redAccent,
                              ),
                            ],
                          ),
                          Text(
                            "Plate: ${driver.vehicleNumber}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Contact: ${driver.contactNumber}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Driver Information Card
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8F8),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Driver Information",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _infoRow("Full Name", driver.fullName),
                                _infoRow("Contact", driver.contactNumber),
                                _infoRow("Vehicle Type", driver.vehicleType),
                                _infoRow(
                                  "Vehicle Number",
                                  driver.vehicleNumber,
                                ),
                                _infoRow(
                                  "DL No.",
                                  driver.dlNumber?.isNotEmpty == true
                                      ? driver.dlNumber!
                                      : "Not provided",
                                ),
                                _infoRow(
                                  "Description",
                                  driver.description.isNotEmpty
                                      ? driver.description
                                      : "No description available",
                                ),
                                _infoRow(
                                  "Status",
                                  driver.isDeclarationAccepted
                                      ? "Verified ✓"
                                      : "Pending",
                                ),

                                const SizedBox(height: 16),

                                // Performance Overview
                                const Text(
                                  "Performance Overview",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _performanceRow(
                                  "Timely Delivery",
                                  0.92,
                                  Colors.green,
                                  "92%",
                                ),
                                _performanceRow(
                                  "Trip Efficiency",
                                  0.85,
                                  Colors.green,
                                  "85%",
                                ),
                                _performanceRow(
                                  "Safety",
                                  0.80,
                                  Colors.orange,
                                  "80%",
                                ),

                                const SizedBox(height: 16),

                                // Rating
                                Row(
                                  children: [
                                    const Text(
                                      "Enter rating : ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return const Icon(
                                          Icons.star,
                                          color: Colors.orange,
                                          size: 20,
                                        );
                                      }),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "5.0",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Feedback
                                const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Feedback: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Skilled Driver with good response time",
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Recent Reviews
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text(
                              "Recent Reviews",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "No Reviews yet!",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  Widget _performanceRow(
    String label,
    double value,
    Color color,
    String percent,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Color(0xFFFFF8F8),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            percent,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.redAccent, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  /// Make a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Remove any spaces, dashes, or special characters
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Ensure the number starts with tel: protocol
      final Uri phoneUri = Uri.parse('tel:$cleanNumber');

      // Use launchUrl with mode: LaunchMode.externalApplication for better compatibility
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try to launch directly without checking
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to make phone call. Please check if your device supports phone calls.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      AppLogger.d('Phone call error: $e');
    }
  }

  /// Send an email
  Future<void> _sendEmail(String driverName, String contactNumber) async {
    try {
      // Create email URI with subject and body
      final Uri emailUri = Uri(
        scheme: 'mailto',
        queryParameters: {
          'subject': 'Contact regarding driver: $driverName',
          'body':
              'Hello,\n\nI would like to get in touch regarding driver $driverName.\nContact Number: $contactNumber\n\nThank you.',
        },
      );

      // Use launchUrl with mode: LaunchMode.externalApplication for better compatibility
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try to launch directly without checking
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open email. Please check if you have an email app installed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      AppLogger.d('Email error: $e');
    }
  }

  /// Show trip calendar for scheduling
  void _showTripCalendar(String driverName) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Schedule trip for $driverName',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF36969),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    ).then((selectedDate) {
      if (selectedDate != null) {
        Get.snackbar(
          'Date Selected',
          'Trip scheduled for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF00B894),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }
}
