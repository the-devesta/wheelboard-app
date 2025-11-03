import 'package:flutter/material.dart';

class Notification1Screen extends StatelessWidget {
  const Notification1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
      ),
      body: const Center(
        child: Text('Notification Screen'),
      ),
    );
  }
}

