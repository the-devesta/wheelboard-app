import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/service_controller.dart';
import '../../models/service_assignment_summary.dart';
import '../../models/service_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_snackbar.dart';
import 'service_confirmation.dart';

class ServiceDetailsPopup extends StatefulWidget {
  const ServiceDetailsPopup({super.key, required this.service});

  final ServiceModel service;

  @override
  State<ServiceDetailsPopup> createState() => _ServiceDetailsPopupState();
}

class _ServiceDetailsPopupState extends State<ServiceDetailsPopup> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _vehicleController;
  late final TextEditingController _descriptionController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.service.serviceTitle.isNotEmpty
          ? widget.service.serviceTitle
          : 'Service',
    );
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _vehicleController = TextEditingController();
    _descriptionController = TextEditingController(
      text: widget.service.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _vehicleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = _formatTime(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    final monthNames = <String>[
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
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatTimeForRequest(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      SnackBarHelper.error('Please select a schedule date.');
      return;
    }

    if (_selectedTime == null) {
      SnackBarHelper.error('Please select a schedule time.');
      return;
    }

    final assignedToUserId = AuthService.to.currentUserId;
    if (assignedToUserId.isEmpty) {
      SnackBarHelper.error('Unable to find user session. Please log in again.');
      return;
    }

    final controller = Get.find<ServiceController>();
    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final success = await controller.assignService(
      serviceId: widget.service.serviceId,
      serviceTitle: widget.service.serviceTitle,
      assignedToUserId: assignedToUserId,
      vehicleNumber: _vehicleController.text.trim(),
      scheduledDate: scheduledDateTime,
      scheduledTime: _formatTimeForRequest(_selectedTime!),
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Get.back(); // close popup
      Get.to(
        () => ServiceConfirmationPage(
          summary: ServiceAssignmentSummary(
            serviceId: widget.service.serviceId,
            serviceTitle: widget.service.serviceTitle,
            vehicleNumber: _vehicleController.text.trim(),
            scheduledDateTime: scheduledDateTime,
            scheduledTime: _selectedTime!,
            description: _descriptionController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceController>();

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.event_note, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        "Service Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Service Title"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Service Date"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: InputDecoration(
                    hintText: "Select Service Date",
                    suffixIcon: const Icon(Icons.calendar_month),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (_) {
                    if (_selectedDate == null) {
                      return 'Please pick a date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text("Service Time"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  onTap: _pickTime,
                  decoration: InputDecoration(
                    hintText: "Select Service Time",
                    suffixIcon: const Icon(Icons.access_time),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (_) {
                    if (_selectedTime == null) {
                      return 'Please pick a time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text("Vehicle Number"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _vehicleController,
                  decoration: InputDecoration(
                    hintText: "Enter Vehicle Number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vehicle number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  "Service Description",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Add instructions or notes",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() {
                  final isAssigning = controller.isAssigning.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isAssigning ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isAssigning
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "Assign Service",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
