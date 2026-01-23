import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wheelboard/controllers/ServiceProvider/service_earnings_controller.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_snackbar.dart';

class RegisterPaymentScreen extends StatefulWidget {
  const RegisterPaymentScreen({super.key});

  @override
  State<RegisterPaymentScreen> createState() => _RegisterPaymentScreenState();
}

class _RegisterPaymentScreenState extends State<RegisterPaymentScreen> {
  final controller = Get.find<ServiceEarningsController>();

  final _purposeController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();

  String? _selectedServiceId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Refresh services when screen opens
    controller.fetchUserServices();

    // Listen for userServices changes to set default selection
    ever(controller.userServices, (services) {
      if (services.isNotEmpty && _selectedServiceId == null) {
        setState(() {
          _selectedServiceId = services.first['serviceId'];
        });
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF36969)),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Register Payment',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF36969),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Details Section
              _buildSectionHeader(
                Icons.payment,
                "Payment Details",
                const Color(0xFF347FE9),
              ),
              const SizedBox(height: 16),
              _buildLabel("Purpose of Payment*"),
              _buildTextField(
                controller: _purposeController,
                hintText: "Enter purpose",
              ),
              const SizedBox(height: 16),
              _buildLabel("Payment Amount*"),
              _buildTextField(
                controller: _amountController,
                hintText: "0.00",
                keyboardType: TextInputType.number,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text(
                    "₹",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF347FE9),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Service Information Section
              _buildSectionHeader(
                Icons.settings,
                "Service Information",
                const Color(0xFF347FE9),
              ),
              const SizedBox(height: 16),
              _buildLabel("Linked Service*"),
              _buildServiceDropdown(),
              const SizedBox(height: 16),
              _buildLabel("Enter Date :"),
              _buildTextField(
                controller: _dateController,
                hintText: "Select date",
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 24),

              // Notes Section
              _buildSectionHeader(Icons.note, "Notes", const Color(0xFF347FE9)),
              const SizedBox(height: 16),
              _buildLabel("Payment Notes (Optional)"),
              _buildTextField(
                controller: _notesController,
                hintText: "Add any additional notes...",
                maxLines: 4,
                maxLength: 300,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: controller.isRecordingPayment.value
                  ? null
                  : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF36969),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: controller.isRecordingPayment.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "SAVE PAYMENT",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFF36969)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixIcon,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF36969), width: 1),
        ),
      ),
    );
  }

  Widget _buildServiceDropdown() {
    return Obx(() {
      final services = controller.userServices;

      if (services.isEmpty) {
        // Fallback to serviceBreakdown if userServices is empty
        final data = controller.dashboardData.value;
        if (data != null && data.serviceBreakdown.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedServiceId,
                isExpanded: true,
                hint: const Text(
                  "Select service",
                  style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedServiceId = newValue;
                  });
                },
                items: data.serviceBreakdown.map((service) {
                  return DropdownMenuItem<String>(
                    value: service.serviceId,
                    child: Text(
                      service.serviceTitle,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }
        return const Text("No services available. Please add a service first.");
      }

      // Use userServices from API
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedServiceId,
            isExpanded: true,
            hint: const Text(
              "Select service",
              style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            ),
            onChanged: (String? newValue) {
              setState(() {
                _selectedServiceId = newValue;
              });
            },
            items: services.map((service) {
              return DropdownMenuItem<String>(
                value: service['serviceId'],
                child: Text(
                  service['serviceTitle'] ?? 'Service',
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Future<void> _handleSave() async {
    if (_purposeController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedServiceId == null) {
      SnackBarHelper.error('Please fill in all mandatory fields.');
      return;
    }

    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      SnackBarHelper.error('Please enter a valid payment amount.');
      return;
    }

    final success = await controller.recordPayment(
      serviceId: _selectedServiceId!,
      amount: amount,
      purpose: _purposeController.text,
      notes: _notesController.text,
    );

    if (success && mounted) {
      // Delay to let user see the success snackbar
      await Future.delayed(const Duration(seconds: 1));

      // Navigate back using Navigator.pop (more reliable)
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
