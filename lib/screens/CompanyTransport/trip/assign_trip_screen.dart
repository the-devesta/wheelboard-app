import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'trip_accepted.dart';

class AssignTripScreen extends StatelessWidget {
  final String driverName;
  final String driverImage;
  final String bidAmount;
  final String pickupAddress;
  final String destinationAddress;
  final String dateTime;
  final String requirements;

  const AssignTripScreen({
    super.key,
    this.driverName = 'Jon Doe',
    this.driverImage = 'https://i.pravatar.cc/150?img=1',
    this.bidAmount = '₹150',
    this.pickupAddress = '123 Main street, AnyTown, CA 32132',
    this.destinationAddress = '456 Oak Avenue, OtherTown, NY, 10001',
    this.dateTime = 'October 26, 2024, 10:00 AM',
    this.requirements = 'Fragile, Cargo, Lift Gate required',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Review Summary',
          style: TextStyle(
            color: Color(0xFF2D3436),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Bid Amount and Trip Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bid Amount Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bid Amount to Pay',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Color(0xFF2D3436),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  bidAmount,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                    color: Color(0xFF00B894),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '/ trip',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.help_outline,
                                size: 12,
                                color: Color(0xFF2186EB),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF2186EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Driver Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(driverImage),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driverName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Color(0xFF2D3436),
                              ),
                            ),
                            Text(
                              'Driver',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Trip Details
                    _buildTripDetail(
                      icon: Icons.location_on,
                      label: 'Pickup',
                      value: pickupAddress,
                      iconColor: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildTripDetail(
                      icon: Icons.location_on,
                      label: 'Destination',
                      value: destinationAddress,
                      iconColor: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          dateTime,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            requirements,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Review Your Booking Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B894),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Review Your Booking',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Summary Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Color(0xFF2D3436),
                              ),
                            ),
                            Text(
                              'Summary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Color(0xFF2D3436),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8FAF4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                '20% upfront, 80% on-',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF00B894),
                                ),
                              ),
                              Text(
                                'trip',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF00B894),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildPaymentRow(
                      label: 'Platform Booking Fee',
                      amount: '₹3',
                      hasInfo: true,
                      hasPayNow: true,
                    ),
                    const Divider(height: 32),
                    _buildPaymentRow(
                      label: 'Amount Payable to Driver',
                      amount: '₹120',
                      hasInfo: true,
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Trip Cost',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        Text(
                          '₹123',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            color: Color(0xFF00B894),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Method Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    Text(
                      '(for Platform Fee)',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Selected Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5FEFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00B894),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 27,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.credit_card, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Mastercard •••• 4679',
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                color: Color(0xFF2D3436),
                              ),
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00B894),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 18,
                              color: Color(0xFF00B894),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Add New Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBFBFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_card, size: 20, color: Colors.grey),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Add New Card',
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Or pay using UPI',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'UPI ID:',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              color: Color(0xFF2D3436),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter UPI ID',
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  color: Colors.grey[400],
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Color(0xFF2D3436),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: Color(0xFF2D3436),
                              ),
                              children: [
                                const TextSpan(text: 'Pay Remaining Amount ('),
                                TextSpan(
                                  text: '₹120',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                    color: const Color(0xFF00B894),
                                  ),
                                ),
                                const TextSpan(text: ') directly to\nthe driver via:'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.money, size: 13, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                'Cash',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.account_balance_wallet, size: 13, color: Colors.grey),
                              const SizedBox(width: 6),
                              const Icon(Icons.help_outline, size: 13, color: Colors.grey),
                              const SizedBox(width: 6),
                              const Icon(Icons.phone_android, size: 13, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                'UPI',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You\'ll receive payment instructions after\nbooking confirmation.',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pay Now Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to trip active page after payment
                    String extractedDate = dateTime;
                    String extractedTime = '';
                    
                    if (dateTime.contains(',')) {
                      final parts = dateTime.split(',');
                      extractedDate = parts[0].trim();
                      if (parts.length > 1) {
                        extractedTime = parts[1].trim();
                      }
                    }
                    
                    Get.to(() => TripAccepted(
                      driverName: driverName,
                      vehicleType: 'Bus', // You can pass actual vehicle type
                      date: extractedDate,
                      time: extractedTime.isNotEmpty ? extractedTime : '10:00 AM',
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF36969),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetail({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow({
    required String label,
    required String amount,
    bool hasInfo = false,
    bool hasPayNow = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.grey[600],
                ),
              ),
              if (hasInfo) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.help_outline,
                  size: 13,
                  color: Colors.grey,
                ),
              ],
              if (hasPayNow) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FAF4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: Color(0xFF00B894),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            color: Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }
}

