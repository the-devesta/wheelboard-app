import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/session_manager.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_snackbar.dart';
import 'dart:convert';

class BookingDetailsScreen extends StatefulWidget {
  final String serviceId;
  
  const BookingDetailsScreen({super.key, required this.serviceId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  bool _isLoading = true;
  bool _isUpdating = false;
  Map<String, dynamic>? _bookingData;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("🔍 BookingDetailsScreen initialized");
    print("🔍 Received Service ID: ${widget.serviceId}");
    _fetchBookingDetails();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookingDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");

      print("==========================================");
      print("🔍 FETCHING BOOKING DETAILS");
      print("==========================================");
      print("🔍 Service ID: ${widget.serviceId}");
      print("🔍 Service ID Type: ${widget.serviceId.runtimeType}");
      print("🔍 Service ID Length: ${widget.serviceId.length}");
      
      final endpoint = '${API.serviceAssignList}?serviceId=${widget.serviceId}';
      print("🔍 Endpoint: $endpoint");
      
      final baseUrl = HttpHelper.baseUrl;
      final fullUrl = '$baseUrl$endpoint';
      print("🔍 Base URL: $baseUrl");
      print("🔍 Full URL: $fullUrl");
      print("==========================================");

      // Fetch assigned service list for this serviceId
      final response = await HttpHelper.getData(
        endpoint: endpoint,
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      print("🔍 Response Status Code: ${response.statusCode}");
      print("🔍 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>? ?? [];
        
        print("🔍 Parsed Data Count: ${data.length}");
        print("🔍 Parsed Data: $data");
        
        if (data.isNotEmpty) {
          // Use the first assignment (or you can show a list if multiple)
          final bookingData = data[0] as Map<String, dynamic>;
          print("✅ Booking Data Found:");
          print("   - Assignment ID: ${bookingData['assignmentId']}");
          print("   - Service Title: ${bookingData['serviceTitle']}");
          print("   - Customer Name: ${bookingData['customerName']}");
          print("   - Status: ${bookingData['status']}");
          print("   - Scheduled Date: ${bookingData['scheduledDate']}");
          print("   - Scheduled Time: ${bookingData['scheduledTime']}");
          print("   - Vehicle Number: ${bookingData['vehicleNumber']}");
          print("   - Amount: ${bookingData['amount']}");
          print("   - Pricing Option: ${bookingData['pricingOption']}");
          print("   - Description: ${bookingData['description']}");
          print("   - Full Data: $bookingData");
          
          setState(() {
            _bookingData = bookingData;
          });
        } else {
          print("⚠️ No assignments found in response");
          SnackBarHelper.error("No assignments found for this service");
          setState(() {
            _bookingData = null;
          });
        }
      } else {
        print("❌ Failed to fetch booking details. Status: ${response.statusCode}");
        print("❌ Response: ${response.body}");
        SnackBarHelper.error("Failed to load booking details");
        setState(() {
          _bookingData = null;
        });
      }
    } catch (e, stackTrace) {
      print("❌ Error fetching booking details: $e");
      print("❌ Stack Trace: $stackTrace");
      SnackBarHelper.error("Error: ${e.toString()}");
      setState(() {
        _bookingData = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      print("🔍 Fetch completed. Loading: false");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3436)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF2D3436),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF2D3436)),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookingData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Booking details not found',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Service ID: ${widget.serviceId}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _fetchBookingDetails();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Booking Summary Card
                            _buildBookingSummaryCard(),
                            const SizedBox(height: 16),
                            // Customer Details Card
                            _buildCustomerDetailsCard(),
                            const SizedBox(height: 16),
                            // Service Details Card
                            _buildServiceDetailsCard(),
                            const SizedBox(height: 16),
                            // Scheduling Details Card
                            _buildSchedulingCard(),
                            const SizedBox(height: 16),
                            // Internal Notes Card
                            _buildInternalNotesCard(),
                            const SizedBox(height: 100), // Space for bottom buttons
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildBookingSummaryCard() {
    final assignment = _bookingData!;
    final serviceTitle = assignment['serviceTitle'] ?? 'Service';
    final status = assignment['status'] ?? 'Pending';
    final scheduledDate = assignment['scheduledDate'] ?? '';
    final scheduledTime = assignment['scheduledTime'] ?? '';
    final assignmentId = assignment['assignmentId'] ?? '';
    
    // Format date
    String formattedDate = 'Date not available';
    if (scheduledDate.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(scheduledDate);
        formattedDate = '${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}';
      } catch (e) {
        formattedDate = scheduledDate;
      }
    }
    
    // Format time
    String formattedTime = '';
    if (scheduledTime.isNotEmpty) {
      try {
        final parts = scheduledTime.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = parts[1];
          final period = hour >= 12 ? 'PM' : 'AM';
          final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          formattedTime = ' – $displayHour:$minute $period';
        }
      } catch (e) {
        formattedTime = ' – $scheduledTime';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  serviceTitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9FDF4),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Color(0xFF00B894),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Color(0xFF828282)),
              const SizedBox(width: 8),
              Text(
                '$formattedDate$formattedTime',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF828282),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.help_outline, size: 16, color: Color(0xFF828282)),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF828282),
                  ),
                  children: [
                    const TextSpan(text: 'Assignment ID: '),
                    TextSpan(
                      text: '#${assignmentId.substring(0, 8)}...',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildCustomerDetailsCard() {
    final assignment = _bookingData!;
    final customerName = assignment['customerName'] ?? 'Customer';
    final vehicleNumber = assignment['vehicleNumber'] ?? '';
    final description = assignment['description'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (vehicleNumber.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.directions_car, size: 14, color: Color(0xFF828282)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  vehicleNumber,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Color(0xFF828282),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Start Service Button - Full width below customer info
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUpdating ? null : () {
                    final assignmentId = assignment['assignmentId'] ?? '';
                    if (assignmentId.isNotEmpty) {
                      _startService(assignmentId);
                    }
                  },
                  icon: const Icon(Icons.play_arrow, size: 18, color: Colors.white),
                  label: const Text(
                    'Start Service',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.note, size: 16, color: Color(0xFFFF9800)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF828282),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard() {
    final assignment = _bookingData!;
    final serviceTitle = assignment['serviceTitle'] ?? 'Service';
    
    // Handle pricing option - convert boolean/string to readable text
    String pricingType = 'Per Hour'; // Default
    if (assignment['pricingOption'] != null) {
      final option = assignment['pricingOption'];
      if (option is bool) {
        pricingType = option ? 'Flat Rate' : 'Per Hour';
      } else if (option is String) {
        final optionLower = option.toLowerCase();
        if (optionLower == 'true' || optionLower == 'flat rate' || optionLower == 'flat') {
          pricingType = 'Flat Rate';
        } else if (optionLower == 'false' || optionLower == 'per hour' || optionLower == 'hourly') {
          pricingType = 'Per Hour';
        } else {
          pricingType = option; // Use as is if it's already readable
        }
      }
    }
    
    // Handle price - ensure it's a number
    dynamic priceValue = assignment['amount'] ?? 0;
    if (priceValue is bool) {
      priceValue = 0;
    }
    final price = (priceValue is num) ? priceValue : (double.tryParse(priceValue.toString()) ?? 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow('Service Title', serviceTitle),
          const SizedBox(height: 16),
          _buildDetailRow('Pricing Type', pricingType),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF828282),
                ),
              ),
              Text(
                '₹${price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Booked By', 'Customer'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF828282),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }

  Widget _buildSchedulingCard() {
    final assignment = _bookingData!;
    final scheduledDate = assignment['scheduledDate'] ?? '';
    final scheduledTime = assignment['scheduledTime'] ?? '';
    final status = assignment['status'] ?? 'Pending';
    
    // Format scheduled date and time
    String formattedDateTime = 'Not scheduled';
    if (scheduledDate.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(scheduledDate);
        final monthName = _getMonthName(dateTime.month);
        formattedDateTime = '$monthName ${dateTime.day}, ${dateTime.year}';
        
        if (scheduledTime.isNotEmpty) {
          try {
            final parts = scheduledTime.split(':');
            if (parts.length >= 2) {
              final hour = int.parse(parts[0]);
              final minute = parts[1];
              final period = hour >= 12 ? 'PM' : 'AM';
              final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
              formattedDateTime += ' – $displayHour:$minute $period';
            }
          } catch (e) {
            formattedDateTime += ' – $scheduledTime';
          }
        }
      } catch (e) {
        formattedDateTime = scheduledDate;
      }
    }
    
    // Calculate duration estimate (you can adjust this logic)
    final duration = '1 Hour'; // Default or calculate from scheduled time

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow('Scheduled Time', formattedDateTime),
          const SizedBox(height: 16),
          _buildDetailRow('Duration Estimate', duration),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF828282),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: status.toLowerCase() == 'confirmed' || status.toLowerCase() == 'completed'
                      ? const Color(0xFFE9FDF4)
                      : status.toLowerCase() == 'pending'
                          ? const Color(0xFFFFF4E6)
                          : Colors.grey[200],
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: status.toLowerCase() == 'confirmed' || status.toLowerCase() == 'completed'
                        ? const Color(0xFF00B894)
                        : status.toLowerCase() == 'pending'
                            ? const Color(0xFFFF9800)
                            : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInternalNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Internal Notes',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF828282),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '(Visible to You Only)',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF828282),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(
              minHeight: 120,
              maxHeight: 200,
            ),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.transparent),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: null,
              minLines: 4,
              decoration: const InputDecoration(
                hintText: 'Add notes about this service...',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFFADAEBC),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF2D3436),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    final assignmentId = _bookingData?['assignmentId'] ?? '';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUpdating ? null : () {
                _completeService(assignmentId);
              },
              icon: const Icon(Icons.check, size: 16, color: Colors.white),
              label: const Text(
                'Complete Service',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isUpdating ? null : () {
                _showCancelDialog();
              },
              icon: const Icon(Icons.close, size: 16, color: Color(0xFFFF4D4F)),
              label: const Text(
                'Cancel Appointment',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFFFF4D4F),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF4D4F)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startService(String assignmentId) async {
    if (assignmentId.isEmpty) {
      SnackBarHelper.error("Assignment ID not found");
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");

      // Call update-service-status API with status=start
      final response = await HttpHelper.postData(
        endpoint: '${API.updateServiceStatus}?assignmentId=$assignmentId&status=start',
        data: {},
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarHelper.success('Service started successfully');
        // Refresh booking details to update status
        await _fetchBookingDetails();
      } else {
        String errorMessage = "Failed to start service";
        try {
          final body = json.decode(response.body);
          errorMessage = body['message'] ?? body['error'] ?? errorMessage;
        } catch (_) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        SnackBarHelper.error(errorMessage);
      }
    } catch (e) {
      SnackBarHelper.error("Something went wrong: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _completeService(String assignmentId) async {
    if (assignmentId.isEmpty) {
      SnackBarHelper.error("Assignment ID not found");
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");

      // Call complete-service API
      final response = await HttpHelper.postData(
        endpoint: '${API.completeService}?assignmentId=$assignmentId',
        data: {},
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarHelper.success('Service completed successfully');
        // Refresh booking details to update status
        await _fetchBookingDetails();
      } else {
        String errorMessage = "Failed to complete service";
        try {
          final body = json.decode(response.body);
          errorMessage = body['message'] ?? body['error'] ?? errorMessage;
        } catch (_) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        SnackBarHelper.error(errorMessage);
      }
    } catch (e) {
      SnackBarHelper.error("Something went wrong: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showCancelDialog() {
    final assignmentId = _bookingData?['assignmentId'] ?? '';
    
    if (assignmentId.isEmpty) {
      SnackBarHelper.error("Assignment ID not found");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              await _cancelService(assignmentId);
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelService(String assignmentId) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");

      // Call cancel-service API
      final response = await HttpHelper.postData(
        endpoint: '${API.cancelService}?assignmentId=$assignmentId',
        data: {},
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarHelper.success('Appointment cancelled successfully');
        // Refresh booking details to update status
        await _fetchBookingDetails();
        // Optionally navigate back
        if (mounted) {
          Get.back();
        }
      } else {
        String errorMessage = "Failed to cancel appointment";
        try {
          final body = json.decode(response.body);
          errorMessage = body['message'] ?? body['error'] ?? errorMessage;
        } catch (_) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        SnackBarHelper.error(errorMessage);
      }
    } catch (e) {
      SnackBarHelper.error("Something went wrong: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}

