import 'package:flutter/material.dart';

class TripDashboardScreen extends StatelessWidget {
  const TripDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Dashboard'),
      ),
      body: const Center(
        child: Text('Trip Dashboard Screen'),
      ),
    );
  }
}

