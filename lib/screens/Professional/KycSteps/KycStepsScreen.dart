import 'package:flutter/material.dart';

class KycStepsScreen extends StatelessWidget {
  const KycStepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Steps'),
      ),
      body: const Center(
        child: Text('KYC Steps Screen'),
      ),
    );
  }
}

