import 'package:flutter/material.dart';
import '../widgets/calendar_header_widget.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/event_card_widget.dart';
import '../CalendarMarkDate/CalendarMarkDateScreen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime(2025, 9, 2);
  final List<DateTime> _eventDates = [
    DateTime(2025, 9, 2),
    DateTime(2025, 9, 6),
    DateTime(2025, 9, 7),
    DateTime(2025, 9, 8),
    DateTime(2025, 9, 9),
    DateTime(2025, 9, 10),
    DateTime(2025, 9, 11),
    DateTime(2025, 9, 12),
    DateTime(2025, 9, 13),
    DateTime(2025, 9, 14),
    DateTime(2025, 9, 15),
    DateTime(2025, 9, 16),
    DateTime(2025, 9, 17),
    DateTime(2025, 9, 18),
    DateTime(2025, 9, 19),
    DateTime(2025, 9, 20),
    DateTime(2025, 9, 21),
    DateTime(2025, 9, 22),
    DateTime(2025, 9, 23),
    DateTime(2025, 9, 24),
    DateTime(2025, 9, 25),
    DateTime(2025, 9, 26),
    DateTime(2025, 9, 27),
    DateTime(2025, 9, 28),
    DateTime(2025, 9, 29),
    DateTime(2025, 9, 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CalendarHeaderWidget(),
            Expanded(
              child: SingleChildScrollView(
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
                      eventDates: _eventDates,
                    ),
                    const SizedBox(height: 24),
                    const EventCardWidget(
                      fromLocation: 'Warehouse A',
                      toLocation: 'Store Z',
                      time: 'Today, 09:35 AM',
                      vehicleNumber: 'MH12AB3456',
                      status: 'In Transit',
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CalendarMarkDateScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFFFF5E5E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

