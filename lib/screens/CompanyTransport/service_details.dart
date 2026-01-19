import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/service_controller.dart';
import '../../models/service_model.dart';
import 'service_detail_popup.dart';
import '../../widgets/custom_loader.dart';
import '../../utils/share_service.dart';
import '../../widgets/custom_snackbar.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late final ServiceController serviceController;

  @override
  void initState() {
    super.initState();
    serviceController = Get.find<ServiceController>();

    // Load cached list entry if available
    final cached = serviceController.getServiceById(widget.serviceId);
    if (cached != null) {
      serviceController.selectedService.value = cached;
    }

    // Fetch full detail from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      serviceController.fetchServiceDetail(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Service Detail",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              final service = serviceController.selectedService.value;
              if (service != null) {
                ShareService.shareGeneric(
                  title: service.serviceTitle,
                  content:
                      '${service.description ?? "Check out this service"}\n\nBusiness: ${service.businessName}\nLocation: ${service.city}',
                  url: ShareService.wheelboardWebsiteUrl,
                );
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        final isLoading = serviceController.isDetailLoading.value;
        final service = serviceController.selectedService.value;

        if (isLoading && service == null) {
          return const CustomLoader(message: "Loading service details...");
        }

        if (service == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 56,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Service detail not found',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      serviceController.fetchServiceDetail(widget.serviceId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeaderImage(),
                  const SizedBox(height: 10),
                  _buildSummaryCard(service),
                  const SizedBox(height: 8),
                  _buildAboutSection(service),
                  const SizedBox(height: 8),
                  _buildPricingSection(service),
                  const SizedBox(height: 8),
                  _buildContactSection(service),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.05),
                child: const CustomLoader.small(),
              ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final service = serviceController.selectedService.value;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: service == null
                ? null
                : () {
                    Get.dialog(
                      ServiceDetailsPopup(service: service),
                      barrierDismissible: true,
                      transitionDuration: Duration.zero,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF36969),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Assign Service",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeaderImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        "assets/tripImage.png",
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildSummaryCard(ServiceModel service) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  service.serviceTitle.isNotEmpty
                      ? service.serviceTitle
                      : 'Service',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (service.isAvailable)
                const Icon(Icons.verified, color: Color(0xFF00B894), size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B894).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  service.businessType.isNotEmpty
                      ? service.businessType
                      : 'Service',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00B894),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _buildAddressLabel(service),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(ServiceModel service) {
    final description = service.description?.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF36969).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFFF36969),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "About this Service",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFF36969).withOpacity(0.2),
              ),
            ),
            child: Text(
              (description != null && description.isNotEmpty)
                  ? description
                  : "Description not provided.",
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(ServiceModel service) {
    final amount = service.amount;
    final rawPricingOption = service.pricingOption ?? '';
    final hoursFrom = service.businessHoursFrom ?? '';
    final hoursTo = service.businessHoursTo ?? '';
    final daysOpen = service.daysOpen ?? '';

    // Convert pricingOption to readable text (handle boolean strings)
    String pricingOption = '';
    if (rawPricingOption.isNotEmpty) {
      final optionLower = rawPricingOption.toLowerCase();
      if (optionLower == 'true' ||
          optionLower == 'flat price' ||
          optionLower == 'flat') {
        pricingOption = 'Flat Price';
      } else if (optionLower == 'false' ||
          optionLower == 'per hour' ||
          optionLower == 'hourly') {
        pricingOption = 'Per Hour';
      } else {
        // Use as is if it's already readable (not true/false)
        pricingOption = rawPricingOption;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pricing & Availability",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.currency_rupee,
                size: 18,
                color: Color(0xFF00B894),
              ),
              const SizedBox(width: 4),
              Text(
                (amount != null && amount > 0)
                    ? '₹$amount'
                    : 'Contact for pricing',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              if (pricingOption.isNotEmpty) ...[
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Color(0xFF00B894),
                ),
                const SizedBox(width: 4),
                Text(pricingOption),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                size: 18,
                color: Color(0xFF00B894),
              ),
              const SizedBox(width: 4),
              Text(daysOpen.isNotEmpty ? daysOpen : 'Days not specified'),
              const Spacer(),
              const Icon(Icons.access_time, size: 18, color: Color(0xFF00B894)),
              const SizedBox(width: 4),
              Text(_formatHours(hoursFrom, hoursTo)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(ServiceModel service) {
    final contact = service.contactNumber ?? '';
    final whatsapp = service.whatsappNumber ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Location & Contact",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Color(0xFF00B894)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  service.fullAddress.isNotEmpty
                      ? service.fullAddress
                      : (service.city.isNotEmpty
                            ? service.city
                            : 'Address N/A'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text("Map Placeholder")),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: contact.isNotEmpty
                      ? () async {
                          final phoneNumber = contact.replaceAll(
                            RegExp(r'[^0-9+]'),
                            '',
                          );
                          final Uri callUri = Uri(
                            scheme: 'tel',
                            path: phoneNumber,
                          );
                          try {
                            if (await canLaunchUrl(callUri)) {
                              await launchUrl(callUri);
                            } else {
                              SnackBarHelper.error(
                                'Could not launch phone dialer',
                              );
                            }
                          } catch (e) {
                            SnackBarHelper.error('Error: ${e.toString()}');
                          }
                        }
                      : null,
                  icon: const Icon(Icons.call, color: Colors.white),
                  label: Text(
                    contact.isNotEmpty ? "Call Now" : "No contact",
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF36969),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: whatsapp.isNotEmpty
                      ? () async {
                          final phoneNumber = whatsapp.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          final whatsappUrl = 'https://wa.me/$phoneNumber';
                          final Uri uri = Uri.parse(whatsappUrl);
                          try {
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              SnackBarHelper.error(
                                'WhatsApp not installed or could not open',
                              );
                            }
                          } catch (e) {
                            SnackBarHelper.error('Error: ${e.toString()}');
                          }
                        }
                      : null,
                  icon: const Icon(
                    Icons.chat,
                    color: Color(0xFF25D366),
                    size: 22,
                  ),
                  label: Text(
                    whatsapp.isNotEmpty ? "WhatsApp" : "No WhatsApp",
                    style: TextStyle(
                      color: whatsapp.isNotEmpty
                          ? const Color(0xFF25D366)
                          : Colors.grey,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: whatsapp.isNotEmpty
                          ? const Color(0xFF25D366)
                          : Colors.grey,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _buildAddressLabel(ServiceModel service) {
    if (service.businessName.isNotEmpty) {
      return '${service.businessName} · ${service.city}';
    }
    if (service.city.isNotEmpty) {
      return service.city;
    }
    return service.fullAddress.isNotEmpty ? service.fullAddress : 'Address N/A';
  }

  static String _formatHours(String from, String to) {
    if (from.isEmpty && to.isEmpty) return 'Time not specified';
    if (from.isEmpty) return 'Till $to';
    if (to.isEmpty) return 'From $from';
    return '$from – $to';
  }
}
