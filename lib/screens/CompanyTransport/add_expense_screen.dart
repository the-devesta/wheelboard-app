import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../widgets/expense_type_dropdown.dart';
import '../../widgets/trip_dropdown.dart';

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

  final List<ExpenseTypeItem> _expensePurposes = [
    ExpenseTypeItem(value: 'Advance', label: 'Advance', color: const Color(0xFFFF6E5E)),
    ExpenseTypeItem(value: 'Fuel', label: 'Fuel', color: const Color(0xFF77B9E8)),
    ExpenseTypeItem(value: 'Challan', label: 'Challan', color: const Color(0xFFB187D6)),
    ExpenseTypeItem(value: 'Food', label: 'Food', color: const Color(0xFFFFA26B)),
    ExpenseTypeItem(value: 'Salary', label: 'Salary', color: const Color(0xFFFFC966)),
    ExpenseTypeItem(value: 'Enroute', label: 'Enroute', color: const Color(0xFFBDBDBD)),
    ExpenseTypeItem(value: 'Other', label: 'Other', color: const Color(0xFFBDBDBD)),
  ];

  final List<TripItem> _trips = [
    TripItem(
      tripId: 'ST0624ADI2024',
      origin: 'Surat',
      destination: 'Ahmedabad',
      vehicleType: 'Shipment',
      date: '24/06/2024',
    ),
    TripItem(
      tripId: 'PN0624BRC2023',
      origin: 'Pune',
      destination: 'Vadodara',
      vehicleType: 'Construction',
      date: '24/06/2023',
    ),
    TripItem(
      tripId: 'PN0624BRC2023',
      origin: 'Pune',
      destination: 'Vadodara',
      vehicleType: 'Mining',
      date: '24/06/2023',
    ),
    TripItem(
      tripId: 'PN0624BRC2023',
      origin: 'Pune',
      destination: 'Vadodara',
      vehicleType: 'Shipment',
      date: '24/06/2023',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dateController.text = _formatDate(_selectedDate!);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
          bottom: BorderSide(
            color: Color(0xFFFCD2D2),
            width: 1,
          ),
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
                ExpenseTypeDropdown(
                  selectedValue: _selectedExpensePurpose,
                  onChanged: (value) {
                    setState(() {
                      _selectedExpensePurpose = value;
                    });
                  },
                  items: _expensePurposes,
                ),
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
                TripDropdown(
                  selectedValue: _selectedTrip,
                  onChanged: (value) {
                    setState(() {
                      _selectedTrip = value;
                    });
                  },
                  items: _trips,
                ),
                const SizedBox(height: 24),

                // Upload Receipt
                _buildLabel("Upload Receipt"),
                const SizedBox(height: 12),
                _buildUploadReceipt(),

                const SizedBox(height: 40),

                // Save Button
                Center(
                  child: Container(
                    width: 312,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5E5E), Color(0xFFF36969)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _saveExpense,
                        borderRadius: BorderRadius.circular(14),
                        child: Center(
                          child: Text(
                            "SAVE NOW",
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
                  ),
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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter amount',
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFADAEBC),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
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
                  _dateController.text.isEmpty ? 'Select date' : _dateController.text,
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
            const Icon(
              Icons.attach_file,
              size: 16,
              color: Color(0xFF424242),
            ),
            const SizedBox(width: 8),
            Text(
              _uploadedFileName ?? 'Upload receipt',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: _uploadedFileName != null
                    ? const Color(0xFF424242)
                    : const Color(0xFFADAEBC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

