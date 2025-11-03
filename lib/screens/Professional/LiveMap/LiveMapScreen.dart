import 'package:flutter/material.dart';

class LiveMapScreen extends StatelessWidget {
  const LiveMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Map'),
      ),
      body: const Center(
        child: Text('Live Map Screen'),
      ),
    );
  }
}

