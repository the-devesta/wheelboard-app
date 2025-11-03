import 'package:flutter/material.dart';

class TripProgressScreen extends StatelessWidget {
  const TripProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Progress'),
      ),
      body: const Center(
        child: Text('Trip Progress Screen'),
      ),
    );
  }
}

