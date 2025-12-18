import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/session_manager.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_snackbar.dart';
import '../../models/service_model.dart';
import 'add_service_screen.dart';
import 'booking_details_screen.dart';
import 'dart:convert';
import '../../widgets/custom_loader.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailsScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _serviceData;

  @override
  void initState() {
    super.initState();
    _fetchServiceDetails();
  }

  Future<void> _fetchServiceDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");

      final response = await HttpHelper.getData(
        endpoint: '${API.serviceDetail}${widget.serviceId}',
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          setState(() {
            _serviceData = body['data'] as Map<String, dynamic>;
          });
        } else {
          SnackBarHelper.error("Failed to load service details");
        }
      } else {
        SnackBarHelper.error("Failed to load service details");
      }
    } catch (e) {
      SnackBarHelper.error("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF4F4),
        body: const CustomLoader(message: "Loading service details..."),
      );
    }

    if (_serviceData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF4F4),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF36969),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(child: Text('Service details not found')),
      );
    }

    final service = _serviceData!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F4),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, service),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildServiceInfoCard(service),
                    const SizedBox(height: 24),
                    _buildPricingAndHoursCard(service),
                    const SizedBox(height: 24),
                    _buildAboutServiceCard(service),
                    const SizedBox(height: 24),
                    _buildGalleryCard(service),
                    const SizedBox(height: 24),
                    _buildStatsCard(),
                    const SizedBox(height: 24),
                    _buildActionButtons(service),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  SliverAppBar _buildSliverAppBar(
    BuildContext context,
    Map<String, dynamic> service,
  ) {
    final serviceTitle =
        service['serviceTitle'] ?? service['title'] ?? 'Service';
    final businessName = service['businessName'] ?? '';
    final images = service['images'] as List<dynamic>? ?? [];
    final firstImage = images.isNotEmpty ? images[0] as String : null;

    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFF36969),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          'Service Detail',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            firstImage != null
                ? Image.network(
                    firstImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF36969),
                      child: const Icon(
                        Icons.image,
                        size: 64,
                        color: Colors.white70,
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFFF36969),
                    child: const Icon(
                      Icons.image,
                      size: 64,
                      color: Colors.white70,
                    ),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (businessName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      businessName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF36969),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      service['isAvailable'] == true ? 'Published' : 'Draft',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfoCard(Map<String, dynamic> service) {
    final serviceTitle =
        service['serviceTitle'] ?? service['title'] ?? 'Service';
    final businessType = service['businessType'] ?? '';
    final fullAddress = service['fullAddress'] ?? '';
    final city = service['city'] ?? '';
    final address = fullAddress.isNotEmpty ? '$fullAddress, $city' : city;

    return _buildCard(
      children: [
        Text(
          serviceTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (businessType.isNotEmpty) ...[
          const SizedBox(height: 8),
          Chip(
            label: Text(businessType),
            backgroundColor: const Color(0xFFF36969).withOpacity(0.1),
            labelStyle: const TextStyle(color: Color(0xFFF36969)),
          ),
        ],
        if (address.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildInfoRow(Icons.location_on, address),
        ],
      ],
    );
  }

  Widget _buildPricingAndHoursCard(Map<String, dynamic> service) {
    // Handle price - ensure it's a number, not boolean
    dynamic priceValue = service['amount'] ?? service['price'] ?? 0;
    if (priceValue is bool) {
      priceValue = 0;
    }
    final price = (priceValue is num)
        ? priceValue
        : (double.tryParse(priceValue.toString()) ?? 0);

    // Handle pricing option - convert boolean/string to readable text
    String pricingOption = 'Per Hour'; // Default
    if (service['pricingOption'] != null) {
      final option = service['pricingOption'];
      if (option is bool) {
        pricingOption = option ? 'Flat Price' : 'Per Hour';
      } else if (option is String) {
        // Handle string values like "True", "true", "Flat Price", etc.
        final optionLower = option.toLowerCase();
        if (optionLower == 'true' ||
            optionLower == 'flat price' ||
            optionLower == 'flat') {
          pricingOption = 'Flat Price';
        } else if (optionLower == 'false' ||
            optionLower == 'per hour' ||
            optionLower == 'hourly') {
          pricingOption = 'Per Hour';
        } else {
          pricingOption = option; // Use as is if it's already readable
        }
      }
    } else if (service['isFlatPrice'] != null) {
      // Fallback to isFlatPrice boolean
      final isFlat = service['isFlatPrice'];
      if (isFlat is bool) {
        pricingOption = isFlat ? 'Flat Price' : 'Per Hour';
      } else if (isFlat is String) {
        pricingOption = (isFlat.toLowerCase() == 'true')
            ? 'Flat Price'
            : 'Per Hour';
      }
    }

    final daysOpen = service['daysOpen'] ?? '';
    final businessFrom =
        service['businessHoursFrom'] ?? service['businessFrom'] ?? '';
    final businessTo =
        service['businessHoursTo'] ?? service['businessTo'] ?? '';

    String formatTime(String? time) {
      if (time == null || time.isEmpty) return '';
      try {
        final parts = time.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = parts[1];
          final period = hour >= 12 ? 'PM' : 'AM';
          final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          return '$displayHour:$minute $period';
        }
        return time;
      } catch (e) {
        return time;
      }
    }

    return _buildCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildDetailItem(
                Icons.currency_rupee,
                price > 0 ? '₹${price.toStringAsFixed(0)}' : 'N/A',
                pricingOption,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDetailItem(
                Icons.build,
                'On-premise',
                'Service Location',
              ),
            ),
          ],
        ),
        if (daysOpen.isNotEmpty || businessFrom.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (daysOpen.isNotEmpty)
                Expanded(
                  child: _buildDetailItem(
                    Icons.date_range,
                    daysOpen,
                    'Available Days',
                  ),
                ),
              if (daysOpen.isNotEmpty && businessFrom.isNotEmpty)
                const SizedBox(width: 8),
              if (businessFrom.isNotEmpty && businessTo.isNotEmpty)
                Expanded(
                  child: _buildDetailItem(
                    Icons.access_time,
                    '${formatTime(businessFrom)} – ${formatTime(businessTo)}',
                    'Working Hours',
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAboutServiceCard(Map<String, dynamic> service) {
    final description = service['description'] ?? 'No description available';

    return _buildCard(
      children: [
        const Text(
          'About this Service',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF36969).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            description,
            style: const TextStyle(color: Colors.black54, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryCard(Map<String, dynamic> service) {
    final images = service['images'] as List<dynamic>? ?? [];
    final imageUrls = images.map((e) => e.toString()).toList();

    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildCard(
      children: [
        const Text(
          'Gallery',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 48, color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return _buildCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(Icons.lightbulb, '12', 'Leads'),
            _buildStatItem(Icons.visibility, '120', 'Views'),
            _buildStatItem(Icons.assignment, '5', 'Assigns'),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> service) {
    // Create ServiceModel for edit
    final serviceModel = ServiceModel(
      serviceId: service['serviceId'] ?? '',
      serviceTitle: service['serviceTitle'] ?? service['title'] ?? '',
      city: service['city'] ?? '',
      fullAddress: service['fullAddress'] ?? '',
      isAvailable: service['isAvailable'] ?? false,
      businessName: service['businessName'] ?? '',
      businessType: service['businessType'] ?? '',
      contactNumber: service['contactNumber'],
      whatsappNumber: service['whatsappNumber'],
      description: service['description'],
      pricingOption: service['pricingOption'],
      amount: service['amount'],
      businessHoursFrom:
          service['businessHoursFrom'] ?? service['businessFrom'],
      businessHoursTo: service['businessHoursTo'] ?? service['businessTo'],
      daysOpen: service['daysOpen'],
    );

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: () {
              Get.to(() => AddServiceScreen(service: serviceModel));
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFF36969)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Edit Service',
              style: TextStyle(color: Color(0xFFF36969)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: () {
              _showDeleteDialog(serviceModel);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFF36969)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFF36969)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF36969).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Color(0xFFF36969)),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text(
          'Are you sure you want to delete "${service.serviceTitle}"?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // Implement delete functionality
              Get.back();
              SnackBarHelper.success('Service deleted');
              Get.back(); // Go back to listings
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          print("🔍 Navigating to BookingDetailsScreen...");
          print("🔍 Service ID being passed: ${widget.serviceId}");
          Get.to(() => BookingDetailsScreen(serviceId: widget.serviceId));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF36969),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'View Assigns',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFF36969).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFFF36969)),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
