import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/Transport/driver_details_controller.dart';
import '../../../utils/constants.dart';
import '../../../utils/call_utils.dart';
import '../../../widgets/custom_loader.dart';
import '../trip/assign_trip_screen.dart';

class ViewDriverScreen extends StatefulWidget {
  final String driverId;
  final String? tripId;
  final String? bidId;
  final bool isProfessional;

  const ViewDriverScreen({
    super.key,
    required this.driverId,
    this.tripId,
    this.bidId,
    this.isProfessional = false,
  });

  @override
  State<ViewDriverScreen> createState() => _ViewDriverScreenState();
}

class _ViewDriverScreenState extends State<ViewDriverScreen> {
  final DriverDetailsController controller = Get.put(DriverDetailsController());

  @override
  void initState() {
    super.initState();
    if (widget.isProfessional) {
      controller.fetchProfessionalDetails(widget.driverId);
    } else {
      controller.fetchDriverDetails(widget.driverId);
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    await CallUtils.makeCall(phoneNumber);
  }

  Future<void> _sendEmail(String driverName, String contactNumber) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        queryParameters: {
          'subject': 'Contact regarding driver: $driverName',
          'body':
              'Hello,\n\nI would like to get in touch regarding driver $driverName.\nContact Number: $contactNumber\n\nThank you.',
        },
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open email client.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Driver Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CustomLoader.small());
        }

        final driver = controller.driverDetails.value;
        if (driver == null) {
          return const Center(
            child: Text(
              "Driver details not found",
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          );
        }

        // Get driver image URL
        String? driverImageUrl;
        if (driver.driverImagePath != null &&
            driver.driverImagePath!.isNotEmpty) {
          final imagePath = driver.driverImagePath!.trim();
          if (imagePath.isNotEmpty && imagePath != ApiConstants.baseUrl) {
            driverImageUrl = imagePath.startsWith('http')
                ? imagePath
                : ApiConstants.baseUrl + imagePath;
          }
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile Picture and Basic Info
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: driverImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: driverImageUrl,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: const CustomLoader.small(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                        AppImages.driver,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                )
                              : Image.asset(
                                  AppImages.driver,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        if (driver.isVerified || driver.isKYCCompleted)
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B894),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      driver.fullName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (driver.vehicleType.isNotEmpty)
                      Text(
                        driver.vehicleType,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (driver.driverType != null &&
                        driver.driverType!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF36969).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          driver.driverType!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color(0xFFF36969),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Contact Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00B894,
                                  ).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.phone,
                                  color: Color(0xFF00B894),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Phone Number',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    Text(
                                      driver.contactNumber,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                        color: Color(0xFF2D3436),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00B894,
                                  ).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.directions_car,
                                  color: Color(0xFF00B894),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vehicle Number',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    Text(
                                      driver.vehicleNumber.isNotEmpty
                                          ? driver.vehicleNumber
                                          : 'N/A',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                        color: Color(0xFF2D3436),
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

                    const SizedBox(height: 24),

                    // Contact Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00B894),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.phone, color: Colors.white),
                            onPressed: () =>
                                _makePhoneCall(driver.contactNumber),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.email, color: Colors.grey[600]),
                            onPressed: () => _sendEmail(
                              driver.fullName,
                              driver.contactNumber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    if (driver.description.isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'About Driver',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        driver.description,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    if (widget.tripId != null && widget.tripId!.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(
                              () => AssignTripScreen(
                                tripId: widget.tripId!,
                                bidId: widget.bidId,
                              ),
                            );
                          },
                          icon: const Icon(Icons.directions_car, size: 20),
                          label: const Text(
                            'Assign to Trip',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF36969),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}
