import 'package:flutter/material.dart';

class TrackTripScreen extends StatelessWidget {
  const TrackTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Trip'),
      ),
      body: const Center(
        child: Text('Track Trip Screen'),
      ),
    );
  }
}

