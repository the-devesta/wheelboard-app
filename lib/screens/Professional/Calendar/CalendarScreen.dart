import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/calendar_header_widget.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/event_card_widget.dart';
import '../CalendarMarkDate/CalendarMarkDateScreen.dart';
import '../../../controllers/Professional/calendar_controller.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarController calendarController = Get.put(CalendarController());
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CalendarHeaderWidget(),
            Expanded(
              child: Obx(() {
                final eventDates = calendarController.getEventDates();
                final selectedDateEvents = calendarController.getEventsForDate(
                  _selectedDate,
                );

                return SingleChildScrollView(
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
                        eventDates: eventDates,
                      ),
                      const SizedBox(height: 24),
                      // Show events for selected date
                      if (selectedDateEvents.isNotEmpty)
                        ...selectedDateEvents.map(
                          (event) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: EventCardWidget(
                              eventName: event.eventName,
                              time: _formatEventTime(
                                event.startTime,
                                event.endTime,
                              ),
                              vehicleNumber: event.note,
                              status: event.isActive ? 'Active' : 'Inactive',
                            ),
                          ),
                        ),
                      if (selectedDateEvents.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No events for selected date',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CalendarMarkDateScreen(initialDate: _selectedDate),
            ),
          ).then((_) {
            // Refresh events after returning from mark date screen
            calendarController.refreshEvents();
          });
        },
        backgroundColor: const Color(0xFFFF5E5E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatEventTime(DateTime startTime, DateTime endTime) {
    final now = DateTime.now();
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    String dateStr;
    if (selected.isAtSameMomentAs(today)) {
      dateStr = 'Today';
    } else if (selected.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      dateStr = 'Tomorrow';
    } else if (selected.isAtSameMomentAs(
      today.subtract(const Duration(days: 1)),
    )) {
      dateStr = 'Yesterday';
    } else {
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
      dateStr =
          '${months[selected.month - 1]} ${selected.day}, ${selected.year}';
    }

    final startTimeStr =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endTimeStr =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    return '$dateStr, $startTimeStr - $endTimeStr';
  }
}
