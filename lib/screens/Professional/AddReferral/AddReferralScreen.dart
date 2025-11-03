import 'package:flutter/material.dart';

class AddReferralScreen extends StatelessWidget {
  const AddReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Referral'),
      ),
      body: const Center(
        child: Text('Add Referral Screen'),
      ),
    );
  }
}

