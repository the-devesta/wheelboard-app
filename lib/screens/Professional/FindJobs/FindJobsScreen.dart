import 'package:flutter/material.dart';

class FindJobsScreen extends StatelessWidget {
  const FindJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Jobs'),
      ),
      body: const Center(
        child: Text('Find Jobs Screen'),
      ),
    );
  }
}

