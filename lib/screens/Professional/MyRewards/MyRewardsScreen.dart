import 'package:flutter/material.dart';

class MyRewardsScreen extends StatelessWidget {
  const MyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rewards'),
      ),
      body: const Center(
        child: Text('My Rewards Screen'),
      ),
    );
  }
}

