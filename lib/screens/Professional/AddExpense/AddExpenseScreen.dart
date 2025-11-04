import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../../utils/responsive_utils.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String? _selectedExpensePurpose;
  String? _selectedTrip;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String? _uploadedFileName;

  final List<String> _expensePurposes = [
    'Fuel',
    'Toll',
    'Parking',
    'Maintenance',
    'Food',
    'Other',
  ];

  final List<String> _trips = [
    'Trip 1 - Delhi to Mumbai',
    'Trip 2 - Mumbai to Bangalore',
    'Trip 3 - Bangalore to Chennai',
  ];

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

      if (result != null) {
        setState(() {
          _uploadedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _saveExpense() {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense saved successfully'),
        backgroundColor: Color(0xFF27AE60),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
                  top: ResponsiveUtils.getResponsiveSpacing(context, small: 16, medium: 20, large: 24),
                  bottom: ResponsiveUtils.getResponsiveSpacing(context, small: 100, medium: 110, large: 120),
                ),
                child: Container(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.getResponsiveSpacing(context, small: 16, medium: 18, large: 20),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, small: 10, medium: 12, large: 14),
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
                        child: _buildDropdown(
                          context,
                          value: _selectedExpensePurpose,
                          hint: 'Select expense purpose...',
                          items: _expensePurposes,
                          onChanged: (value) {
                            setState(() {
                              _selectedExpensePurpose = value;
                            });
                          },
                        ),
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
                        child: _buildDropdown(
                          context,
                          value: _selectedTrip,
                          hint: 'Select a trip...',
                          items: _trips,
                          onChanged: (value) {
                            setState(() {
                              _selectedTrip = value;
                            });
                          },
                        ),
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
                      _buildSaveButton(context),
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
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, small: 16, medium: 20, large: 23),
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
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 18, medium: 20, large: 22),
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
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 13, medium: 14, large: 15),
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

  Widget _buildDropdown(
    BuildContext context, {
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFADAEBC),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          suffixIcon: const Icon(Icons.arrow_drop_down, size: 16),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF424242),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
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
              _uploadedFileName != null
                  ? _uploadedFileName!
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
      onTap: _saveExpense,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'SAVE NOW',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 14, medium: 15, large: 16),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
