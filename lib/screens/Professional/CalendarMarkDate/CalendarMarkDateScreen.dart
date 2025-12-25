import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../widgets/calendar_header_widget.dart';
import '../widgets/calendar_widget.dart';
import '../../../controllers/Professional/calendar_controller.dart';
import '../../../widgets/custom_loader.dart';

class CalendarMarkDateScreen extends StatefulWidget {
  final DateTime? initialDate;

  const CalendarMarkDateScreen({super.key, this.initialDate});

  @override
  State<CalendarMarkDateScreen> createState() => _CalendarMarkDateScreenState();
}

class _CalendarMarkDateScreenState extends State<CalendarMarkDateScreen> {
  final CalendarController calendarController = Get.find<CalendarController>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final String _selectedCategory = 'Trip';
  bool _isActive = true;
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

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
    _startDateController.dispose();
    _endDateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset:
          false, // Prevent keyboard from pushing content up
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 15,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Start Date and End Date
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _startDateController,
                                          readOnly: true,
                                          onTap: () async {
                                            // First select date
                                            final date = await showDatePicker(
                                              context: context,
                                              initialDate:
                                                  _selectedStartDate ??
                                                  _selectedDate,
                                              firstDate: DateTime.now()
                                                  .subtract(
                                                    const Duration(days: 365),
                                                  ),
                                              lastDate: DateTime.now().add(
                                                const Duration(days: 365),
                                              ),
                                            );
                                            if (date != null) {
                                              // Then select time
                                              final time = await showTimePicker(
                                                context: context,
                                                initialTime:
                                                    _selectedStartDate != null
                                                    ? TimeOfDay.fromDateTime(
                                                        _selectedStartDate!,
                                                      )
                                                    : TimeOfDay.now(),
                                              );
                                              if (time != null) {
                                                final dateTime = DateTime(
                                                  date.year,
                                                  date.month,
                                                  date.day,
                                                  time.hour,
                                                  time.minute,
                                                );
                                                setState(() {
                                                  _selectedStartDate = dateTime;
                                                  _startDateController.text =
                                                      _formatDateTime(dateTime);
                                                });
                                              }
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Start date',
                                            hintStyle: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: const Color(0xFF8F9BB3),
                                            ),
                                            suffixIcon: const Icon(
                                              Icons.calendar_today,
                                              size: 18,
                                              color: Color(0xFF8F9BB3),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFEDF1F7),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFEDF1F7),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFEDF1F7),
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 15,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: TextField(
                                          controller: _endDateController,
                                          readOnly: true,
                                          onTap: () async {
                                            // First select date
                                            final date = await showDatePicker(
                                              context: context,
                                              initialDate:
                                                  _selectedEndDate ??
                                                  _selectedDate,
                                              firstDate: DateTime.now()
                                                  .subtract(
                                                    const Duration(days: 365),
                                                  ),
                                              lastDate: DateTime.now().add(
                                                const Duration(days: 365),
                                              ),
                                            );
                                            if (date != null) {
                                              // Then select time
                                              final time = await showTimePicker(
                                                context: context,
                                                initialTime:
                                                    _selectedEndDate != null
                                                    ? TimeOfDay.fromDateTime(
                                                        _selectedEndDate!,
                                                      )
                                                    : TimeOfDay.now(),
                                              );
                                              if (time != null) {
                                                final dateTime = DateTime(
                                                  date.year,
                                                  date.month,
                                                  date.day,
                                                  time.hour,
                                                  time.minute,
                                                );
                                                setState(() {
                                                  _selectedEndDate = dateTime;
                                                  _endDateController.text =
                                                      _formatDateTime(dateTime);
                                                });
                                              }
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'End date',
                                            hintStyle: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: const Color(0xFF8F9BB3),
                                            ),
                                            suffixIcon: const Icon(
                                              Icons.calendar_today,
                                              size: 18,
                                              color: Color(0xFF8F9BB3),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFEDF1F7),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFEDF1F7),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFEDF1F7),
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
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
                                  // Mark the date As
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                                    : const Color(
                                                        0xFF787880,
                                                      ).withOpacity(0.16),
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                              ),
                                              child: Stack(
                                                children: [
                                                  AnimatedPositioned(
                                                    duration: const Duration(
                                                      milliseconds: 200,
                                                    ),
                                                    curve: Curves.easeInOut,
                                                    left: _isActive ? 24 : 2,
                                                    right: _isActive ? 2 : 24,
                                                    top: 2,
                                                    bottom: 2,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              100,
                                                            ),
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color: Color(
                                                              0x0A000000,
                                                            ),
                                                            blurRadius: 3,
                                                            offset: Offset(
                                                              0,
                                                              3,
                                                            ),
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
                                  Obx(() {
                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed:
                                            calendarController.isLoading.value
                                            ? null
                                            : () async {
                                                // Use default values if fields are empty
                                                final eventName =
                                                    _eventNameController.text
                                                        .trim()
                                                        .isEmpty
                                                    ? 'Calendar Event'
                                                    : _eventNameController.text
                                                          .trim();

                                                // Use selected date with current time if start date not selected
                                                final startDateTime =
                                                    _selectedStartDate ??
                                                    DateTime(
                                                      _selectedDate.year,
                                                      _selectedDate.month,
                                                      _selectedDate.day,
                                                      DateTime.now().hour,
                                                      DateTime.now().minute,
                                                    );

                                                // Use start date + 1 hour if end date not selected
                                                final endDateTime =
                                                    _selectedEndDate ??
                                                    startDateTime.add(
                                                      const Duration(hours: 1),
                                                    );

                                                // Save event
                                                final success =
                                                    await calendarController
                                                        .saveEvent(
                                                          eventName: eventName,
                                                          startTime:
                                                              startDateTime,
                                                          endTime: endDateTime,
                                                          note: _noteController
                                                              .text
                                                              .trim(),
                                                          category:
                                                              _selectedCategory,
                                                          isActive: _isActive,
                                                        );

                                                if (success) {
                                                  Navigator.pop(context);
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFF36969,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              7,
                                            ),
                                          ),
                                        ),
                                        child:
                                            calendarController.isLoading.value
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CustomLoader.small(
                                                  color: Colors.white,
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
                                  }),
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

  String _formatDateTime(DateTime dateTime) {
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
    final dateStr =
        '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr, $timeStr';
  }
}
