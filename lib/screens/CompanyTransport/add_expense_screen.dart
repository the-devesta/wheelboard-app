import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controllers/Professional/expense_controller.dart';
import '../../controllers/Transport/add_trip_controller.dart';
import '../../controllers/Professional/assigned_trip_controller.dart';
import '../../models/expense_purpose_model.dart';
import '../../models/add_new_trip_model.dart';
import '../../models/assigned_trip_model.dart';
import '../../utils/session_manager.dart';
import '../../widgets/custom_loader.dart';
import '../../services/auth_service.dart';
import '../../utils/app_logger.dart';

class AddExpenseScreen extends StatefulWidget {
  final bool isProfessional;

  const AddExpenseScreen({super.key, this.isProfessional = false});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final ExpenseController expenseController = Get.put(ExpenseController());
  late dynamic tripController;

  // 🔍 TRUBLESHOOT: Force professional check here as well if needed
  bool get isProfessional => _localIsProfessional;

  ExpensePurpose? _selectedExpensePurpose;
  dynamic _selectedTrip; // Can be Trip or AssignedTrip
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  File? _uploadedFile;
  bool _isSaving = false; // Local flag to prevent duplicate calls
  bool _localIsProfessional =
      false; // State-based source of truth ensuring API consistency

  // Color mapping for expense types
  final Map<String, Color> _expenseColors = {
    'Advance': const Color(0xFFE74C3C), // Red
    'Fuel': const Color(0xFF3498DB), // Light Blue
    'Challan': const Color(0xFF9B59B6), // Purple
    'Food': const Color(0xFFE67E22), // Orange
    'Salary': const Color(0xFFF1C40F), // Yellow
    'Enroute': const Color(0xFF95A5A6), // Light Grey
    'Other': const Color(0xFF34495E), // Dark Grey
  };

  // Icon mapping for expense types
  final Map<String, IconData> _expenseIcons = {
    'Advance': Icons.account_balance_wallet,
    'Fuel': Icons.local_gas_station,
    'Challan': Icons.receipt_long,
    'Food': Icons.restaurant,
    'Salary': Icons.payments,
    'Enroute': Icons.directions_car,
    'Other': Icons.category,
  };

  @override
  void initState() {
    super.initState();

    // 🔍 DEBUG: Check user type and controller selection
    AppLogger.d("🔍 ========================================");
    AppLogger.d("🔍 ADD EXPENSE SCREEN INITIALIZATION");
    AppLogger.d("🔍 ========================================");
    AppLogger.d("🔍 isProfessional flag: $isProfessional");
    AppLogger.d(
      "🔍 User Type: ${isProfessional ? 'Professional/Driver' : 'Transport Company'}",
    );

    AppLogger.d("🔍 ========================================");

    // 📋 DEBUG: Dump all session data to see what is actually stored
    SessionManager.logAllSessionData();

    // Verify user type directly from AuthService to prevent stale router arguments
    final authUserType = Get.find<AuthService>().userType.value;

    // Default to widget passed value
    _localIsProfessional = widget.isProfessional;

    bool effectiveIsProfessional = _localIsProfessional;

    // Double check: if AuthService says Professional, we MUST treat as Professional
    if (authUserType.toLowerCase().trim() == 'professional' ||
        authUserType.toLowerCase().trim() == 'driver') {
      effectiveIsProfessional = true;
    }

    // Store for build usage
    _localIsProfessional = effectiveIsProfessional;

    if (_localIsProfessional) {
      AppLogger.d("🔍 Using: AssignedTripController (Access: Professional)");
      AppLogger.d("🔍 API: api/Trip/assign-trip-list/{userId}");
      tripController = Get.put(AssignedTripController());

      // Ensure we fetch data specifically for this controller
      WidgetsBinding.instance.addPostFrameCallback((_) {
        (tripController as AssignedTripController).fetchAssignedTrips();
      });
    } else {
      AppLogger.d("🔍 Using: TripController (Access: Transport/Company)");
      AppLogger.d("🔍 API: api/Trip/trip-list/{userId}");
      tripController = Get.put(TripController());
    }
    AppLogger.d("🔍 ========================================");

    _selectedDate = DateTime.now();
    _dateController.text = _formatDate(_selectedDate!);
    _amountController.text = '0.00';
    _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    if (_localIsProfessional) {
      if (tripController is AssignedTripController) {
        (tripController as AssignedTripController).fetchAssignedTrips();
      } else {
        // Should not happen, but safe fallback
        tripController = Get.put(AssignedTripController());
        (tripController as AssignedTripController).fetchAssignedTrips();
      }
    } else {
      final sessionManager = SessionManager();
      final userId = await sessionManager.getString("userId");

      if (userId != null && userId.isNotEmpty) {
        // Try Transport flow first
        if (tripController is! TripController) {
          tripController = Get.put(TripController());
        }
        await (tripController as TripController).fetchTrips(userId);

        // SELF-HEALING LOGIC:
        // If Transport returns 0 trips, check if they are actually a Professional
        if ((tripController as TripController).trips.isEmpty) {
          AppLogger.d(
            "⚠️ No transport trips found. Checking if user is secretly a Professional...",
          );

          // Create a temporary controller to check
          final tempAssignedController = Get.put(
            AssignedTripController(),
            tag: 'temp_check',
          );
          await tempAssignedController.fetchAssignedTrips();

          if (tempAssignedController.assignedTrips.isNotEmpty) {
            AppLogger.d(
              "🚨 SELF-HEAL TRIGGERED: Found assigned trips! Switching mode to Professional.",
            );

            setState(() {
              _localIsProfessional = true;

              // Promote temp controller to main controller
              tripController = Get.put(AssignedTripController());
              // Copy data over if needed or just refetch (refetch is cleaner)
              (tripController as AssignedTripController).assignedTrips
                  .assignAll(tempAssignedController.assignedTrips);
            });
          }
          // Cleanup temp
          Get.delete<AssignedTripController>(tag: 'temp_check');
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')}-${months[date.month - 1]}-${date.year}';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = _formatDate(pickedDate);
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _uploadedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _showExpensePurposeModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Obx(() {
        if (expenseController.isLoadingPurposes.value) {
          return const CustomLoader.small(message: "Loading...");
        }

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF2196F3),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select expense type',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE74C3C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Expense Purpose List
              ...expenseController.expensePurposes.map((purpose) {
                final color =
                    _expenseColors[purpose.purposeName] ?? Colors.grey;
                final icon =
                    _expenseIcons[purpose.purposeName] ?? Icons.category;
                final isSelected =
                    _selectedExpensePurpose?.expensePurposeId ==
                    purpose.expensePurposeId;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedExpensePurpose = purpose;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(icon, size: 20, color: color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            purpose.purposeName,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check, color: Color(0xFF2196F3)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  void _showTripSelectionModal() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: MediaQuery.of(context).size.width * 0.95,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            minHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: Color(0xFF2196F3),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Select Trip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Content
              Expanded(
                child: Obx(() {
                  if (isProfessional) {
                    final assignedTripController =
                        tripController as AssignedTripController;

                    if (assignedTripController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final allTrips = assignedTripController.assignedTrips;

                    if (allTrips.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.no_transfer,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No trips found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: allTrips.length,
                      separatorBuilder: (context, index) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        height: 1,
                        color: Colors.grey.shade200,
                      ),
                      itemBuilder: (context, index) {
                        final trip = allTrips[index];
                        final isSelected =
                            _selectedTrip != null &&
                            (_selectedTrip as AssignedTrip).bidId == trip.bidId;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTrip = trip;
                            });
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(
                                      0xFF2196F3,
                                    ).withValues(alpha: 0.1)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2196F3)
                                    : Colors.grey.shade200,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Trip Index Badge
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF2196F3)
                                        : const Color(0xFFF36969),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Trip Details - Full text visible
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Pickup Location
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.radio_button_checked,
                                            size: 14,
                                            color: Colors.green.shade600,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              trip.pickupLocation,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      // Delivery Location
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Colors.red.shade600,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              trip.deliveryLocation,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      // Date
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 12,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${trip.pickupDate.day}/${trip.pickupDate.month}/${trip.pickupDate.year}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Check Icon
                                if (isSelected)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF2196F3),
                                      size: 22,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    final tripControllerTyped =
                        tripController as TripController;
                    final allTrips = tripControllerTyped.trips;

                    if (tripControllerTyped.isTripsLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (allTrips.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.no_transfer,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No trips available',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: allTrips.length,
                      separatorBuilder: (context, index) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        height: 1,
                        color: Colors.grey.shade200,
                      ),
                      itemBuilder: (context, index) {
                        final trip = allTrips[index];
                        final isSelected =
                            _selectedTrip != null &&
                            (_selectedTrip as Trip).tripId == trip.tripId;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTrip = trip;
                            });
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(
                                      0xFF2196F3,
                                    ).withValues(alpha: 0.1)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2196F3)
                                    : Colors.grey.shade200,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Trip Index Badge
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF2196F3)
                                        : const Color(0xFFF36969),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Trip Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${trip.pickupLocation} → ${trip.deliveryLocation}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Trip #${trip.tripId.substring(0, 8)}...',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Check Icon
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF2196F3),
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveExpense() async {
    // Prevent multiple simultaneous calls
    if (_isSaving || expenseController.isSaving.value) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    if (_selectedExpensePurpose == null) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expense purpose'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    if (_selectedTrip == null) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a trip'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    final amount = double.parse(_amountController.text);
    final description = _descriptionController.text.isEmpty
        ? 'No description'
        : _descriptionController.text;

    // Get tripId based on trip type
    String tripId;
    if (isProfessional && _selectedTrip is AssignedTrip) {
      tripId =
          (_selectedTrip as AssignedTrip).bidId ??
          (_selectedTrip as AssignedTrip).tripId;
    } else if (_selectedTrip is Trip) {
      tripId = (_selectedTrip as Trip).tripId;
    } else {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid trip selected'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    final success = await expenseController.saveExpense(
      tripId: tripId,
      expensePurposeId: _selectedExpensePurpose!.expensePurposeId,
      expenseDate: _selectedDate!,
      amount: amount,
      description: description,
      receiptFile: _uploadedFile,
    );

    setState(() {
      _isSaving = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          "ADD New Expense",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: const Color(0xFF1E1E1E),
            letterSpacing: -0.16,
          ),
        ),
        centerTitle: true,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFFCD2D2), width: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.only(top: 24),
            width: 384,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expense Purpose
                _buildLabel("Expense Purpose", required: true),
                const SizedBox(height: 8),
                _buildExpensePurposeField(),
                const SizedBox(height: 24),

                // Amount
                _buildLabel("Amount", required: true),
                const SizedBox(height: 8),
                _buildAmountField(),
                const SizedBox(height: 24),

                // Date
                _buildLabel("Date", required: true),
                const SizedBox(height: 8),
                _buildDateField(),
                const SizedBox(height: 24),

                // Expense Description
                _buildLabel("Expense Description"),
                const SizedBox(height: 8),
                _buildDescriptionField(),
                const SizedBox(height: 24),

                // Choose Trip
                _buildLabel("Choose Trip"),
                const SizedBox(height: 8),
                _buildTripField(),
                const SizedBox(height: 24),

                // Upload Receipt
                _buildLabel("Upload Receipt"),
                const SizedBox(height: 12),
                _buildUploadReceipt(),

                const SizedBox(height: 40),

                // Hired Warning (for professionals only)
                if (isProfessional && AuthService.to.isUserHired)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "You are currently hired. Adding expenses is not available.",
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Save Button
                Center(
                  child: Obx(() {
                    final isSaving =
                        _isSaving || expenseController.isSaving.value;
                    final isHired =
                        isProfessional && AuthService.to.isUserHired;
                    final isDisabled = isSaving || isHired;

                    return Container(
                      width: 312,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: isDisabled
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFFFF5E5E), Color(0xFFF36969)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                        color: isDisabled ? Colors.grey : null,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isDisabled ? null : _saveExpense,
                          borderRadius: BorderRadius.circular(14),
                          child: Center(
                            child: isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CustomLoader.small(
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isHired ? "DISABLED (HIRED)" : "SAVE NOW",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: const Color(0xFF1E1E1E),
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          Text(
            "*",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.red[500],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpensePurposeField() {
    final color = _selectedExpensePurpose != null
        ? _expenseColors[_selectedExpensePurpose!.purposeName] ?? Colors.grey
        : Colors.grey;
    final icon = _selectedExpensePurpose != null
        ? _expenseIcons[_selectedExpensePurpose!.purposeName] ?? Icons.category
        : null;

    return GestureDetector(
      onTap: _showExpensePurposeModal,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            if (_selectedExpensePurpose != null) ...[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              if (icon != null) ...[
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
              ],
            ],
            Expanded(
              child: Text(
                _selectedExpensePurpose?.purposeName ??
                    'Select expense purpose...',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: _selectedExpensePurpose != null
                      ? const Color(0xFF424242)
                      : const Color(0xFFADAEBC),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.arrow_drop_down, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripField() {
    return GestureDetector(
      onTap: _showTripSelectionModal,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _selectedTrip != null
                    ? (isProfessional && _selectedTrip is AssignedTrip
                          ? '${(_selectedTrip as AssignedTrip).pickupLocation} → ${(_selectedTrip as AssignedTrip).deliveryLocation}'
                          : (_selectedTrip is Trip
                                ? '${(_selectedTrip as Trip).pickupLocation} → ${(_selectedTrip as Trip).deliveryLocation}'
                                : 'Select a trip...'))
                    : 'Select a trip...',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: _selectedTrip != null
                      ? const Color(0xFF424242)
                      : const Color(0xFFADAEBC),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.arrow_drop_down, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              '₹',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: const Color(0xFFADAEBC),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onTap: () {
                // Clear "0.00" when user taps to enter amount
                if (_amountController.text == '0.00' ||
                    _amountController.text == '0') {
                  _amountController.clear();
                }
              },
              onChanged: (value) {
                // Clear "0.00" when user starts typing
                if (value == '0.00' || value == '0') {
                  _amountController.clear();
                }
              },
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFADAEBC),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 15,
                ),
              ),
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: const Color(0xFF424242),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  _dateController.text.isEmpty
                      ? 'Select date'
                      : _dateController.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: _dateController.text.isEmpty
                        ? const Color(0xFFADAEBC)
                        : const Color(0xFF424242),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _selectDate,
                child: const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: Color(0xFF424242),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      height: 98,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: null,
        minLines: 3,
        decoration: InputDecoration(
          hintText: 'Enter additional details (optional)',
          hintStyle: TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: const Color(0xFFADAEBC),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          color: const Color(0xFF424242),
        ),
      ),
    );
  }

  Widget _buildUploadReceipt() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.attach_file, size: 16, color: Color(0xFF424242)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _uploadedFile != null
                    ? _uploadedFile!.path.split('/').last
                    : 'Upload receipt',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: _uploadedFile != null
                      ? const Color(0xFF424242)
                      : const Color(0xFFADAEBC),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
