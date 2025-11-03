import 'package:flutter/material.dart';

class TripOverviewScreen extends StatelessWidget {
  const TripOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Overview'),
      ),
      body: const Center(
        child: Text('Trip Overview Screen'),
      ),
    );
  }
}

