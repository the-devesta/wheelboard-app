import 'package:flutter/material.dart';

class PaymentVerificationScreen extends StatelessWidget {
  const PaymentVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Verification'),
      ),
      body: const Center(
        child: Text('Payment Verification Screen'),
      ),
    );
  }
}

