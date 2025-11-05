import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../widgets/calendar_header_widget.dart';
import '../widgets/calendar_widget.dart';
import '../../../controllers/Professional/calendar_controller.dart';

class CalendarMarkDateScreen extends StatefulWidget {
  final DateTime? initialDate;
  
  const CalendarMarkDateScreen({super.key, this.initialDate});

  @override
  State<CalendarMarkDateScreen> createState() => _CalendarMarkDateScreenState();
}

class _CalendarMarkDateScreenState extends State<CalendarMarkDateScreen> {
  final CalendarController calendarController = Get.find<CalendarController>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedCategory = 'Trip';
  bool _isActive = true;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CalendarHeaderWidget(),
            Expanded(
              child: Stack(
                children: [
                  // Calendar View
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 45),
                        CalendarWidget(
                          selectedDate: _selectedDate,
                          onDateSelected: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                  // Modal Sheet
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 623,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x29000000),
                            blurRadius: 30,
                            offset: Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          Text(
                            'Mark Your Calendar',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF222B45),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  // Event Name
                                  TextField(
                                    controller: _eventNameController,
                                    decoration: InputDecoration(
                                      hintText: 'Event name*',
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: const Color(0xFF8F9BB3),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEDF1F7),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEDF1F7),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEDF1F7),
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Start Time and End Time
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _startTimeController,
                                          readOnly: true,
                                          onTap: () async {
                                            final time = await showTimePicker(
                                              context: context,
                                              initialTime: _selectedStartTime ?? TimeOfDay.now(),
                                            );
                                            if (time != null) {
                                              setState(() {
                                                _selectedStartTime = time;
                                                _startTimeController.text = time.format(context);
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Start time',
                                            hintStyle: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: const Color(0xFF8F9BB3),
                                            ),
                                            suffixIcon: const Icon(
                                              Icons.access_time,
                                              size: 18,
                                              color: Color(0xFF8F9BB3),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFEDF1F7),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFEDF1F7),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFEDF1F7),
                                              ),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: TextField(
                                          controller: _endTimeController,
                                          readOnly: true,
                                          onTap: () async {
                                            final time = await showTimePicker(
                                              context: context,
                                              initialTime: _selectedEndTime ?? TimeOfDay.now(),
                                            );
                                            if (time != null) {
                                              setState(() {
                                                _selectedEndTime = time;
                                                _endTimeController.text = time.format(context);
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'End time',
                                            hintStyle: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: const Color(0xFF8F9BB3),
                                            ),
                                            suffixIcon: const Icon(
                                              Icons.access_time,
                                              size: 18,
                                              color: Color(0xFF8F9BB3),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFEDF1F7),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFEDF1F7),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFEDF1F7),
                                              ),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Note
                                  TextField(
                                    controller: _noteController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: 'Type the note here...',
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: const Color(0xFF8F9BB3),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEDF1F7),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEDF1F7),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEDF1F7),
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(14),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Select Category
                                  Text(
                                    'Select Category',
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF535353),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedCategory = 'Trip';
                                            });
                                          },
                                          child: Container(
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: _selectedCategory == 'Trip'
                                                  ? const Color(0xFF735BF2).withOpacity(0.07)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(11),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF735BF2),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Trip',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(0xFF222B45),
                                                    letterSpacing: 0.875,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedCategory = 'Job';
                                            });
                                          },
                                          child: Container(
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: _selectedCategory == 'Job'
                                                  ? const Color(0xFF735BF2).withOpacity(0.07)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(11),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF735BF2),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Job',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(0xFF222B45),
                                                    letterSpacing: 0.875,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Mark the date As
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Mark the date As:',
                                        style: GoogleFonts.poppins(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF535353),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Active',
                                            style: GoogleFonts.poppins(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF535353),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _isActive = !_isActive;
                                              });
                                            },
                                            child: Container(
                                              width: 51,
                                              height: 31,
                                              decoration: BoxDecoration(
                                                color: _isActive
                                                    ? const Color(0xFF34C759)
                                                    : const Color(0xFF787880).withOpacity(0.16),
                                                borderRadius: BorderRadius.circular(100),
                                              ),
                                              child: Stack(
                                                children: [
                                                  AnimatedPositioned(
                                                    duration: const Duration(milliseconds: 200),
                                                    curve: Curves.easeInOut,
                                                    left: _isActive ? 24 : 2,
                                                    right: _isActive ? 2 : 24,
                                                    top: 2,
                                                    bottom: 2,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(100),
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color: Color(0x0A000000),
                                                            blurRadius: 3,
                                                            offset: Offset(0, 3),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  // Mark the Date Button
                                  Obx(
                                    () {
                                      return SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                        onPressed: calendarController.isLoading.value ? null : () async {
                                          // Validate form
                                          if (_eventNameController.text.trim().isEmpty) {
                                            Get.snackbar("Error", "Please enter event name");
                                            return;
                                          }
                                          
                                          if (_selectedStartTime == null) {
                                            Get.snackbar("Error", "Please select start time");
                                            return;
                                          }
                                          
                                          if (_selectedEndTime == null) {
                                            Get.snackbar("Error", "Please select end time");
                                            return;
                                          }

                                          // Combine selected date with selected times
                                          final startDateTime = DateTime(
                                            _selectedDate.year,
                                            _selectedDate.month,
                                            _selectedDate.day,
                                            _selectedStartTime!.hour,
                                            _selectedStartTime!.minute,
                                          );
                                          
                                          final endDateTime = DateTime(
                                            _selectedDate.year,
                                            _selectedDate.month,
                                            _selectedDate.day,
                                            _selectedEndTime!.hour,
                                            _selectedEndTime!.minute,
                                          );

                                          // Save event
                                          final success = await calendarController.saveEvent(
                                            eventName: _eventNameController.text.trim(),
                                            startTime: startDateTime,
                                            endTime: endDateTime,
                                            note: _noteController.text.trim(),
                                            category: _selectedCategory,
                                            isActive: _isActive,
                                          );

                                          if (success) {
                                            Navigator.pop(context);
                                          }
                                        },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF36969),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(7),
                                        ),
                                      ),
                                      child: calendarController.isLoading.value
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              'Mark the Date',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

