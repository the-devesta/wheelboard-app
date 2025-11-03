import 'package:flutter/material.dart';

class YourProfileScreen extends StatelessWidget {
  const YourProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
      ),
      body: const Center(
        child: Text('Your Profile Screen'),
      ),
    );
  }
}

