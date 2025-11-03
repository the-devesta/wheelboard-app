import 'package:flutter/material.dart';

class JobProgressScreen extends StatelessWidget {
  const JobProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Progress'),
      ),
      body: const Center(
        child: Text('Job Progress Screen'),
      ),
    );
  }
}

