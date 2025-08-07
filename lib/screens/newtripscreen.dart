import 'package:flutter/material.dart';
import 'package:wheelboard/commonwidget/app_textfield.dart';
import 'package:wheelboard/constants/apps_colors.dart';

class Newtripscreen extends StatefulWidget {
  const Newtripscreen({super.key});

  @override
  State<Newtripscreen> createState() => _ScheduleTripScreenState();
}

class _ScheduleTripScreenState extends State<Newtripscreen> {
  String? selectedVehicle;
  String? selectedDriver;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController deliveryController = TextEditingController();

  final Color fieldBorderColor = const Color.fromARGB(255, 199, 198, 198);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9DCDC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'New Post Trip',
          style: TextStyle(color: Colors.black),
        ),
        leading: const BackButton(color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.close, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Trip Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildDropdown(
                label: "Select Vehicle",
                value: selectedVehicle,
                hint: "Select Vehicle",
                items: ["Truck A", "Van B", "Bike C"],
                onChanged: (val) => setState(() => selectedVehicle = val),
              ),
              const SizedBox(height: 16),

              _buildDropdown(
                label: "Select Driver",
                value: selectedDriver,
                hint: "Select Driver",
                items: ["John", "Rahul", "Ankit"],
                onChanged: (val) => setState(() => selectedDriver = val),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                "Pickup Location",
                "Enter pickup location",
                pickupController,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                "Delivery Location",
                "Enter delivery location",
                deliveryController,
              ),
              const SizedBox(height: 16),

              _buildDatePicker(context),
              const SizedBox(height: 16),

              _buildTimePicker(context),
              const SizedBox(height: 16),

              AppTextField(hintText: 'Special Instructions'),
              const SizedBox(height: 16),
              AppTextField(hintText: 'Enter Pay range (Rs 200 - Rs900)'),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Submit action here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBg,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF2B5DF2)),
                    ),
                  ),
                  child: const Text(
                    "Schedule Now",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          decoration: _inputDecoration(borderColor: fieldBorderColor),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: _inputDecoration(
            hint: hint,
            borderColor: fieldBorderColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pick up a Date"),
        const SizedBox(height: 6),
        TextFormField(
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() => selectedDate = date);
            }
          },
          decoration: _inputDecoration(
            hint: selectedDate == null
                ? "Choose a date"
                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
            suffixIcon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.blue,
            ),
            borderColor: fieldBorderColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pick Time"),
        const SizedBox(height: 6),
        TextFormField(
          readOnly: true,
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (time != null) {
              setState(() => selectedTime = time);
            }
          },
          decoration: _inputDecoration(
            hint: selectedTime == null
                ? "Pick your time."
                : selectedTime!.format(context),
            suffixIcon: const Icon(Icons.access_time, color: Colors.blue),
            borderColor: fieldBorderColor,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffixIcon,
    Color? borderColor,
  }) {
    final color = borderColor ?? Theme.of(context).primaryColor;

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: 2.0),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      ),
    );
  }
}
