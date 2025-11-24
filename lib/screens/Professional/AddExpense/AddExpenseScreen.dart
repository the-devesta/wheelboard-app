import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../../utils/responsive_utils.dart';
import '../../../controllers/Professional/expense_controller.dart';
import '../../../controllers/Professional/assigned_trip_controller.dart';
import '../../../models/expense_purpose_model.dart';
import '../../../models/assigned_trip_model.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final ExpenseController expenseController = Get.put(ExpenseController());
  final AssignedTripController tripController = Get.put(AssignedTripController());

  ExpensePurpose? _selectedExpensePurpose;
  AssignedTrip? _selectedTrip;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  File? _uploadedFile;

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

  @override
  void initState() {
    super.initState();
    _amountController.text = '0.00';
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
        _dateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
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
          return const Center(child: CircularProgressIndicator());
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
                final color = _expenseColors[purpose.purposeName] ?? Colors.grey;
                final isSelected = _selectedExpensePurpose?.expensePurposeId ==
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
              }).toList(),
            ],
          ),
        );
      }),
    );
  }

  void _showTripSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Obx(() {
        if (tripController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
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
                    'Select Trip',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Trip List
              Expanded(
                child: tripController.assignedTrips.isEmpty
                    ? const Center(
                        child: Text('No trips available'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: tripController.assignedTrips.length,
                        itemBuilder: (context, index) {
                          final trip = tripController.assignedTrips[index];
                          final isSelected =
                              _selectedTrip?.bidId == trip.bidId;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedTrip = trip;
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFF2196F3), width: 2)
                                    : Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Route
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          color: Color(0xFF2196F3), size: 18),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${trip.pickupLocation} → ${trip.deliveryLocation}',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Trip ID: ${trip.bidId.substring(0, 12)}...',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Vehicle Type and Date
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Vehicle Type: ${trip.bidDescription.isNotEmpty ? trip.bidDescription : "N/A"}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        'Date: ${trip.pickupDate.day}/${trip.pickupDate.month}/${trip.pickupDate.year}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _saveExpense() async {
    if (_selectedExpensePurpose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expense purpose'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    if (_selectedTrip == null) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    if (_selectedDate == null) {
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

    final success = await expenseController.saveExpense(
      tripId: _selectedTrip!.bidId, // Using bidId as tripId
      expensePurposeId: _selectedExpensePurpose!.expensePurposeId,
      expenseDate: _selectedDate!,
      amount: amount,
      description: description,
      receiptFile: _uploadedFile,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsiveHorizontalPadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: padding.horizontal,
                  right: padding.horizontal,
                  top: ResponsiveUtils.getResponsiveSpacing(
                      context, small: 16, medium: 20, large: 24),
                  bottom: ResponsiveUtils.getResponsiveSpacing(
                      context, small: 100, medium: 110, large: 120),
                ),
                child: Container(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.getResponsiveSpacing(
                        context, small: 16, medium: 18, large: 20),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(
                          context, small: 10, medium: 12, large: 14),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Expense Purpose
                      _buildFormField(
                        context,
                        label: 'Expense Purpose',
                        required: true,
                        child: _buildExpensePurposeField(context),
                      ),
                      const SizedBox(height: 20),
                      // Amount
                      _buildFormField(
                        context,
                        label: 'Amount',
                        required: true,
                        child: _buildAmountField(context),
                      ),
                      const SizedBox(height: 20),
                      // Date
                      _buildFormField(
                        context,
                        label: 'Date',
                        child: _buildDateField(context),
                      ),
                      const SizedBox(height: 20),
                      // Description
                      _buildFormField(
                        context,
                        label: 'Description',
                        optional: true,
                        child: _buildDescriptionField(context),
                      ),
                      const SizedBox(height: 20),
                      // Choose Trip
                      _buildFormField(
                        context,
                        label: 'Choose Trip',
                        child: _buildTripField(context),
                      ),
                      const SizedBox(height: 20),
                      // Upload Receipt
                      _buildFormField(
                        context,
                        label: 'Upload Receipt',
                        child: _buildUploadReceipt(context),
                      ),
                      const SizedBox(height: 32),
                      // Save Button
                      Obx(() => _buildSaveButton(context)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(
            context, small: 16, medium: 20, large: 23),
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(Icons.arrow_back_ios, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          // Title - Centered
          Expanded(
            child: Center(
              child: Text(
                'ADD Expenses',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context, small: 18, medium: 20, large: 22),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF36969),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          // Menu Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.1),
            ),
            child: const Icon(Icons.more_vert, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
    BuildContext context, {
    required String label,
    required Widget child,
    bool required = false,
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context, small: 13, medium: 14, large: 15),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF424242),
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFE74C3C),
                ),
              ),
            ],
            if (optional) ...[
              const SizedBox(width: 4),
              Text(
                '(Optional)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF757575),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildExpensePurposeField(BuildContext context) {
    final color = _selectedExpensePurpose != null
        ? _expenseColors[_selectedExpensePurpose!.purposeName] ?? Colors.grey
        : Colors.grey;

    return GestureDetector(
      onTap: _showExpensePurposeModal,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            if (_selectedExpensePurpose != null) ...[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                _selectedExpensePurpose?.purposeName ?? 'Select expense purpose...',
                style: GoogleFonts.inter(
                  fontSize: 16,
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

  Widget _buildTripField(BuildContext context) {
    return GestureDetector(
      onTap: _showTripSelectionModal,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _selectedTrip != null
                    ? '${_selectedTrip!.pickupLocation} → ${_selectedTrip!.deliveryLocation}'
                    : 'Select a trip...',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _selectedTrip != null
                      ? const Color(0xFF424242)
                      : const Color(0xFFADAEBC),
                ),
                overflow: TextOverflow.ellipsis,
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

  Widget _buildAmountField(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              '₹',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF757575),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFADAEBC),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF424242),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Select date',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFADAEBC),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF424242),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _selectDate,
                child: const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Color(0xFF757575),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Describe this expense...',
          hintStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFADAEBC),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF424242),
        ),
      ),
    );
  }

  Widget _buildUploadReceipt(BuildContext context) {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.upload_file_outlined,
              size: 30,
              color: Color(0xFF757575),
            ),
            const SizedBox(height: 8),
            Text(
              _uploadedFile != null
                  ? _uploadedFile!.path.split('/').last
                  : 'Drag & drop or tap to upload (.jpg, .png, .pdf)',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: expenseController.isSaving.value ? null : _saveExpense,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: expenseController.isSaving.value
              ? Colors.grey
              : const Color(0xFFE74C3C),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: expenseController.isSaving.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'SAVE NOW',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context, small: 14, medium: 15, large: 16),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
