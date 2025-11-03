import 'package:flutter/material.dart';

class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Learning'),
      ),
      body: const Center(
        child: Text('My Learning Screen'),
      ),
    );
  }
}

