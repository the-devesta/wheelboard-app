import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import '../../../controllers/Transport/vehicle_lease_controller.dart';
import '../../../controllers/Transport/fleet_controller.dart';
import '../../../models/vehicle_lease_model.dart';
import '../../../models/get_vehicle_model.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import '../../../widgets/custom_snackbar.dart';

/// Add Vehicle Lease Screen for Transport side
/// Allows users to post a vehicle for lease
class AddVehicleLeaseScreen extends StatefulWidget {
  final Vehicle? preselectedVehicle;

  const AddVehicleLeaseScreen({super.key, this.preselectedVehicle});

  @override
  State<AddVehicleLeaseScreen> createState() => _AddVehicleLeaseScreenState();
}

class _AddVehicleLeaseScreenState extends State<AddVehicleLeaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final VehicleLeaseController _leaseController = Get.put(
    VehicleLeaseController(),
  );
  final DriverController _fleetController = Get.find<DriverController>();

  // Form Controllers
  final TextEditingController _vehicleTitleController = TextEditingController();
  final TextEditingController _vehicleNumberController =
      TextEditingController();
  final TextEditingController _odometerController = TextEditingController();
  final TextEditingController _flatPriceController = TextEditingController();
  final TextEditingController _avgMonthlyRunController =
      TextEditingController();
  final TextEditingController _tripEfficiencyController =
      TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  // Selected Values
  String? _selectedVehicleId;
  int _selectedPricingType = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _selectedBusinessDays = [];

  final List<String> _businessDayOptions = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<Map<String, dynamic>> _pricingTypes = [
    {'value': 0, 'label': 'Flat Price'},
    {'value': 1, 'label': 'Per KM'},
    {'value': 2, 'label': 'Per Trip'},
  ];

  @override
  void initState() {
    super.initState();
    // Defer loading vehicles until after the first frame is built
    // This prevents snackbar errors during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicles();
    });
    if (widget.preselectedVehicle != null) {
      _selectedVehicleId = widget.preselectedVehicle!.vehicleId;
      _vehicleTitleController.text = widget.preselectedVehicle!.vehicleModel;
      _vehicleNumberController.text = widget.preselectedVehicle!.vehicleNumber;
    }
  }

  Future<void> _loadVehicles() async {
    final authService = AuthService.to;
    final userId = authService.currentUserId;
    final token = authService.currentToken;

    if (userId.isNotEmpty && token.isNotEmpty) {
      await _fleetController.fetchVehicles();
    }
  }

  @override
  void dispose() {
    _vehicleTitleController.dispose();
    _vehicleNumberController.dispose();
    _odometerController.dispose();
    _flatPriceController.dispose();
    _avgMonthlyRunController.dispose();
    _tripEfficiencyController.dispose();
    _instructionsController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  /// Format date as "DD Mon YYYY" without intl package
  String _formatDate(DateTime date) {
    const months = [
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
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          'Add Vehicle Lease',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (_leaseController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Selection Section
                _buildSectionCard(
                  title: 'Vehicle Information',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle Dropdown
                      _buildLabel('Select Vehicle'),
                      const SizedBox(height: 8),
                      Obx(() => _buildVehicleDropdown()),
                      const SizedBox(height: 16),

                      // Vehicle Title
                      _buildLabel('Vehicle Title'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _vehicleTitleController,
                        hint: 'Enter vehicle title (e.g., Tata Prima 4925)',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter vehicle title'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Vehicle Number
                      _buildLabel('Vehicle Number'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _vehicleNumberController,
                        hint: 'Enter vehicle number (e.g., MH 12 AB 3456)',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter vehicle number'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Odometer Reading
                      _buildLabel('Odometer Start Reading (KM)'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _odometerController,
                        hint: 'Enter current odometer reading',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Pricing Section
                _buildSectionCard(
                  title: 'Pricing Details',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pricing Type
                      _buildLabel('Pricing Type'),
                      const SizedBox(height: 8),
                      _buildPricingTypeSelector(),
                      const SizedBox(height: 16),

                      // Flat Price
                      _buildLabel('Flat Price (₹)'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _flatPriceController,
                        hint: 'Enter flat price amount',
                        keyboardType: TextInputType.number,
                        prefix: '₹ ',
                      ),
                      const SizedBox(height: 16),

                      // Average Monthly Run
                      _buildLabel('Avg Monthly Run (KM)'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _avgMonthlyRunController,
                        hint: 'Enter average monthly run',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Trip Efficiency Rate
                      _buildLabel('Trip Efficiency Rate (%)'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _tripEfficiencyController,
                        hint: 'Enter trip efficiency rate',
                        keyboardType: TextInputType.number,
                        suffix: '%',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Duration Section
                _buildSectionCard(
                  title: 'Lease Duration',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Start Date'),
                                const SizedBox(height: 8),
                                _buildDatePicker(
                                  date: _startDate,
                                  hint: 'Select start date',
                                  onTap: () => _selectDate(isStartDate: true),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('End Date'),
                                const SizedBox(height: 8),
                                _buildDatePicker(
                                  date: _endDate,
                                  hint: 'Select end date',
                                  onTap: () => _selectDate(isStartDate: false),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Business Days
                      _buildLabel('Business Days'),
                      const SizedBox(height: 8),
                      _buildBusinessDaysSelector(),
                      const SizedBox(height: 16),

                      // Time Range
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Start Time'),
                                const SizedBox(height: 8),
                                _buildTimePicker(
                                  controller: _startTimeController,
                                  hint: '09:00 AM',
                                  onTap: () => _selectTime(isStartTime: true),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('End Time'),
                                const SizedBox(height: 8),
                                _buildTimePicker(
                                  controller: _endTimeController,
                                  hint: '06:00 PM',
                                  onTap: () => _selectTime(isStartTime: false),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Instructions Section
                _buildSectionCard(
                  title: 'Additional Information',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Special Instructions'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _instructionsController,
                        hint: 'Enter any special instructions or terms...',
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submitLease,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Post Vehicle Lease',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? prefix,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
        prefixText: prefix,
        suffixText: suffix,
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.buttonBg),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    final vehicles = _fleetController.vehicles;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVehicleId,
          hint: Text(
            'Select a vehicle',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          items: vehicles.map((vehicle) {
            return DropdownMenuItem<String>(
              value: vehicle.vehicleId,
              child: Text(
                '${vehicle.vehicleModel} - ${vehicle.vehicleNumber}',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: (vehicleId) {
            setState(() {
              _selectedVehicleId = vehicleId;
              if (vehicleId != null) {
                final vehicle = vehicles.firstWhere(
                  (v) => v.vehicleId == vehicleId,
                );
                _vehicleTitleController.text = vehicle.vehicleModel;
                _vehicleNumberController.text = vehicle.vehicleNumber;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildPricingTypeSelector() {
    return Row(
      children: _pricingTypes.map((type) {
        final isSelected = _selectedPricingType == type['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedPricingType = type['value'];
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: type['value'] < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.buttonBg
                    : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.buttonBg : Colors.grey.shade200,
                ),
              ),
              child: Center(
                child: Text(
                  type['label'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker({
    DateTime? date,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null ? _formatDate(date) : hint,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: date != null ? Colors.black87 : Colors.grey[400],
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                controller.text.isNotEmpty ? controller.text : hint,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: controller.text.isNotEmpty
                      ? Colors.black87
                      : Colors.grey[400],
                ),
              ),
            ),
            Icon(Icons.access_time_outlined, size: 18, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessDaysSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _businessDayOptions.map((day) {
        final isSelected = _selectedBusinessDays.contains(day);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedBusinessDays.remove(day);
              } else {
                _selectedBusinessDays.add(day);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.buttonBg : const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.buttonBg : Colors.grey.shade200,
              ),
            ),
            child: Text(
              day.substring(0, 3),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now().add(const Duration(days: 30)));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.buttonBg),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _selectTime({required bool isStartTime}) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.buttonBg),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final formattedTime = pickedTime.format(context);
      setState(() {
        if (isStartTime) {
          _startTimeController.text = formattedTime;
        } else {
          _endTimeController.text = formattedTime;
        }
      });
    }
  }

  Future<void> _submitLease() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      SnackBarHelper.error("Please select start and end dates");
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      SnackBarHelper.error("End date must be after start date");
      return;
    }

    final authService = AuthService.to;
    final userId = authService.currentUserId;
    final token = authService.currentToken;

    if (userId.isEmpty || token.isEmpty) {
      SnackBarHelper.error("Please login again");
      return;
    }

    // Find selected vehicle
    final selectedVehicle = _selectedVehicleId != null
        ? _fleetController.vehicles.firstWhereOrNull(
            (v) => v.vehicleId == _selectedVehicleId,
          )
        : null;

    final leaseModel = VehicleLeaseModel(
      userId: userId,
      vehicleId: _selectedVehicleId,
      vehicleTitle: _vehicleTitleController.text.trim(),
      vehicleNumber: _vehicleNumberController.text.trim(),
      model:
          selectedVehicle?.vehicleModel ??
          _vehicleTitleController.text.trim(), // Required by API
      odometerStartReading: int.tryParse(_odometerController.text.trim()) ?? 0,
      pricingType: _selectedPricingType,
      flatPrice: int.tryParse(_flatPriceController.text.trim()) ?? 0,
      avgMonthlyRun: int.tryParse(_avgMonthlyRunController.text.trim()) ?? 0,
      tripEfficiencyRate:
          int.tryParse(_tripEfficiencyController.text.trim()) ?? 0,
      startDate: _startDate,
      endDate: _endDate,
      businessDays: _selectedBusinessDays.join(', '),
      startTime: _startTimeController.text.trim(),
      endTime: _endTimeController.text.trim(),
      instructions: _instructionsController.text.trim(),
    );

    final success = await _leaseController.addVehicleLease(leaseModel, token);

    if (success) {
      // Add small delay to allow snackbar to initialize properly before navigating back
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back();
    }
  }
}
