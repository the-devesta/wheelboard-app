import 'package:flutter/material.dart';

class EarningSummaryScreen extends StatelessWidget {
  const EarningSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earning Summary'),
      ),
      body: const Center(
        child: Text('Earning Summary Screen'),
      ),
    );
  }
}

