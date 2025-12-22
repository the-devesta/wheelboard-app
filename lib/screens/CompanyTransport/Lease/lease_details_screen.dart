import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// Lease Vehicle Form Screen (Transport side) - Figma Design
class LeaseDetailsScreen extends StatefulWidget {
  const LeaseDetailsScreen({super.key});

  @override
  State<LeaseDetailsScreen> createState() => _LeaseDetailsScreenState();
}

class _LeaseDetailsScreenState extends State<LeaseDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _vehicleTitleController = TextEditingController();
  final TextEditingController _vehicleNumberController =
      TextEditingController();
  final TextEditingController _odometerController = TextEditingController(
    text: '63000',
  );
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _monthlyRunController = TextEditingController();
  final TextEditingController _tripEfficiencyController =
      TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  // State variables
  String? _pricingType = 'flat';
  final Set<String> _selectedDays = {'Mon'};
  String _startDate = 'mm/dd/yyyy';
  String _endDate = 'mm/dd/yyyy';
  String _fromTime = '09:00';
  String _toTime = '18:00';

  final List<Map<String, String>> _weekDays = [
    {'short': 'M', 'full': 'Mon'},
    {'short': 'T', 'full': 'Tue'},
    {'short': 'W', 'full': 'Wed'},
    {'short': 'T', 'full': 'Thu'},
    {'short': 'F', 'full': 'Fri'},
    {'short': 'S', 'full': 'Sat'},
    {'short': 'S', 'full': 'Sun'},
  ];

  @override
  void initState() {
    super.initState();
    _instructionsController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _vehicleTitleController.dispose();
    _vehicleNumberController.dispose();
    _odometerController.dispose();
    _priceController.dispose();
    _monthlyRunController.dispose();
    _tripEfficiencyController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle Summary Card
                    _buildVehicleSummaryCard(),
                    const SizedBox(height: 16),
                    // Lease Details Section
                    _buildLeaseDetailsSection(),
                    const SizedBox(height: 16),
                    // Pricing Section
                    _buildPricingSection(),
                    const SizedBox(height: 16),
                    // Lease Period Section
                    _buildLeasePeriodSection(),
                    const SizedBox(height: 16),
                    // Additional Instructions
                    _buildAdditionalInstructionsSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 77,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(width: 1, color: Color(0xFFE0E0E0))),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              InkWell(
                onTap: () => Get.back(),
                child: Container(
                  width: 32,
                  height: 44,
                  alignment: Alignment.centerLeft,
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF2A2A2A),
                    size: 24,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Lease Vehicle',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2A2A2A),
                ),
              ),
              const Spacer(),
              const SizedBox(width: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1, color: const Color(0xFFE0E0E0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Vehicle Header Row
          Row(
            children: [
              // Gradient Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF476F), Color(0xFFFFD166)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              // Vehicle Name & Number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tata',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2B2D42),
                        height: 1.50,
                      ),
                    ),
                    Text(
                      'MH-12-AB-3456',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF4B5563),
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF06D6A0),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Available',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Details Grid
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lease Duration',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jan 15 → Dec 15',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2A2A2A),
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Run',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '15,002 KM',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2A2A2A),
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Odometer Reading',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '63000 KM',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2A2A2A),
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Leased',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF28C76F),
                        height: 1.43,
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

  Widget _buildLeaseDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lease Details',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2A2A2A),
              height: 1.56,
            ),
          ),
          const SizedBox(height: 16),
          // Vehicle Title
          _buildInputField(
            label: 'Vehicle Title',
            controller: _vehicleTitleController,
            hint: 'Enter vehicle title',
          ),
          const SizedBox(height: 16),
          // Vehicle Number
          _buildInputField(
            label: 'Vehicle Number',
            controller: _vehicleNumberController,
            hint: 'Enter vehicle number',
          ),
          const SizedBox(height: 16),
          // Odometer Reading
          _buildOdometerField(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF2A2A2A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 1, color: const Color(0xFFE0E0E0)),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF2A2A2A),
              height: 1.50,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFADAEBC),
                height: 1.50,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOdometerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Odometer Reading (on lease start date)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2A2A2A),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.info_outline, size: 14, color: Color(0xFF6B7280)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(width: 1, color: const Color(0xFFE0E0E0)),
                ),
                child: TextField(
                  controller: _odometerController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFADAEBC),
                    height: 1.50,
                  ),
                  decoration: InputDecoration(
                    hintText: '63000',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFADAEBC),
                      height: 1.50,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 90,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(width: 1, color: const Color(0xFFE0E0E0)),
              ),
              alignment: Alignment.center,
              child: Text(
                'KM',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF535353),
                  height: 1.11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Transport vehicles → KM, Mining/Construction → Hours',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
            height: 1.33,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flat Price Option
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _pricingType = 'flat';
                  });
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 0.5, color: Colors.black),
                    color: _pricingType == 'flat'
                        ? const Color(0xFFFF5E7A)
                        : Colors.transparent,
                  ),
                  child: _pricingType == 'flat'
                      ? const Center(
                          child: CircleAvatar(
                            radius: 3,
                            backgroundColor: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Flat Price per Day',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2A2A2A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 1, color: const Color(0xFFE0E0E0)),
            ),
            child: TextField(
              controller: _priceController,
              enabled: _pricingType == 'flat',
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF2A2A2A),
                height: 1.50,
              ),
              decoration: InputDecoration(
                hintText: '₹ Enter amount',
                hintStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFADAEBC),
                  height: 1.50,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // On Request Option
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _pricingType = 'onRequest';
                  });
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 0.5, color: Colors.black),
                    color: _pricingType == 'onRequest'
                        ? const Color(0xFFFF5E7A)
                        : Colors.transparent,
                  ),
                  child: _pricingType == 'onRequest'
                      ? const Center(
                          child: CircleAvatar(
                            radius: 3,
                            backgroundColor: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'On Request',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2A2A2A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Avg Monthly Run
          _buildInputFieldWithSuffix(
            label: 'Avg. Monthly Run',
            controller: _monthlyRunController,
            hint: 'Enter distance',
            suffix: 'KM',
          ),
          const SizedBox(height: 16),
          // Trip Efficiency
          _buildInputFieldWithSuffix(
            label: 'Trip Efficiency',
            controller: _tripEfficiencyController,
            hint: 'Enter rate',
            suffix: '₹/KM',
          ),
        ],
      ),
    );
  }

  Widget _buildInputFieldWithSuffix({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF2A2A2A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 1, color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF2A2A2A),
                    height: 1.50,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFADAEBC),
                      height: 1.50,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                suffix,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  height: 1.50,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeasePeriodSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lease Period',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2A2A2A),
              height: 1.56,
            ),
          ),
          const SizedBox(height: 16),
          // Start & End Date
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Start Date',
                  value: _startDate,
                  onTap: () => _selectDate(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: 'End Date',
                  value: _endDate,
                  onTap: () => _selectDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Business Days
          Text(
            'Business Days',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 12),
          _buildBusinessDays(),
          const SizedBox(height: 16),
          // Business Hours
          Text(
            'Business Hours',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  label: 'From',
                  value: _fromTime,
                  onTap: () => _selectTime(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(
                  label: 'To',
                  value: _toTime,
                  onTap: () => _selectTime(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF2A2A2A),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 1, color: const Color(0xFFE0E0E0)),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 1.33,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessDays() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _weekDays.map((day) {
        final isSelected = _selectedDays.contains(day['full']);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(day['full']);
              } else {
                _selectedDays.add(day['full']!);
              }
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF5E7A) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                width: 2,
                color: isSelected
                    ? const Color(0xFFFF5E7A)
                    : const Color(0xFFE0E0E0),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              day['short']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF4B5563),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 1, color: const Color(0xFFE0E0E0)),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF2A2A2A),
                height: 1.50,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInstructionsSection() {
    final charCount = _instructionsController.text.length;
    const maxChars = 500;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Instructions (Optional)',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2A2A2A),
              height: 1.56,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 96,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 1, color: const Color(0xFFE0E0E0)),
            ),
            child: TextField(
              controller: _instructionsController,
              maxLines: 3,
              maxLength: maxChars,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF2A2A2A),
                height: 1.50,
              ),
              decoration: InputDecoration(
                hintText: 'Special notes or instructions...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFADAEBC),
                  height: 1.50,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counterText: '',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$charCount/$maxChars characters',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 89,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(width: 1, color: Color(0xFFE0E0E0))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5E7A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            'Post Lease',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      Get.snackbar('Success', 'Lease posted successfully');
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      setState(() {
        final formattedDate =
            '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
        if (isStartDate) {
          _startDate = formattedDate;
        } else {
          _endDate = formattedDate;
        }
      });
    }
  }

  Future<void> _selectTime(bool isFromTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        final formattedTime =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        if (isFromTime) {
          _fromTime = formattedTime;
        } else {
          _toTime = formattedTime;
        }
      });
    }
  }
}