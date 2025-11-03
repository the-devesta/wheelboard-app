import 'package:flutter/material.dart';

class TransactionSummaryScreen extends StatelessWidget {
  const TransactionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Summary'),
      ),
      body: const Center(
        child: Text('Transaction Summary Screen'),
      ),
    );
  }
}

