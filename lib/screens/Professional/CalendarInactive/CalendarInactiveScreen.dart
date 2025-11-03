import 'package:flutter/material.dart';

class CalendarInactiveScreen extends StatelessWidget {
  const CalendarInactiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Inactive'),
      ),
      body: const Center(
        child: Text('Calendar Inactive Screen'),
      ),
    );
  }
}

