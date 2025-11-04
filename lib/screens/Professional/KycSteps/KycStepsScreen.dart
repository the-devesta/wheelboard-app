import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/responsive_utils.dart';

class KycStepsScreen extends StatefulWidget {
  const KycStepsScreen({super.key});

  @override
  State<KycStepsScreen> createState() => _KycStepsScreenState();
}

class _KycStepsScreenState extends State<KycStepsScreen> {
  bool _isConfirmed = false;
  final TextEditingController _accountHolderNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();

  @override
  void dispose() {
    _accountHolderNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _bankNameController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = ResponsiveUtils.getResponsiveHorizontalPadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: padding.horizontal,
                  right: padding.horizontal,
                  top: ResponsiveUtils.getResponsiveSpacing(context, small: 16, medium: 20, large: 24),
                  bottom: ResponsiveUtils.getResponsiveSpacing(context, small: 100, medium: 110, large: 120),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Indicator
                    _buildProgressIndicator(context),
                    const SizedBox(height: 12),
                    // Completion Status Card
                    _buildCompletionCard(context),
                    const SizedBox(height: 20),
                    // Document Upload Cards
                    _buildDocumentUploadCard(
                      context,
                      title: 'Upload Aadhar Card',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildDocumentUploadCard(
                      context,
                      title: 'Upload PAN Card',
                      icon: Icons.credit_card_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildDocumentUploadCard(
                      context,
                      title: 'Upload Driving License',
                      icon: Icons.drive_eta_outlined,
                    ),
                    const SizedBox(height: 16),
                    // Bank Account Details
                    _buildBankAccountDetails(context),
                    const SizedBox(height: 16),
                    // Profile Photo Upload
                    _buildProfilePhotoUpload(context),
                    const SizedBox(height: 20),
                    // Confirmation Checkbox
                    _buildConfirmationCheckbox(context),
                  ],
                ),
              ),
            ),
            // Footer with Save Button
            _buildFooter(context, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, small: 16, medium: 20, large: 23),
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(Icons.arrow_back_ios, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          // Title - Centered
          Expanded(
            child: Center(
              child: Text(
                'KYC',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 18, medium: 20, large: 22),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF36969),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          // Notification Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.1),
            ),
            child: const Icon(Icons.notifications_outlined, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Step 1 Circle (Active)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5E5E),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '1',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Connecting Line
            Container(
              height: 2,
              width: 48,
              color: const Color(0xFFFF5E5E).withOpacity(0.5),
            ),
            // Step 2 Circle (Inactive)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '2',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Step 1 of 1: Document Upload',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 11, medium: 12, large: 13),
            fontWeight: FontWeight.w400,
            color: const Color(0xFF757575),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, small: 16, medium: 18, large: 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, small: 10, medium: 12, large: 14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Your KYC is',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 14, medium: 15, large: 16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '40% Complete',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 14, medium: 15, large: 16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF6AA1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Stack(
              children: [
                Container(
                  width: 130.391,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5E5E), Color(0xFFF6AA1C), Color(0xFF39D353)],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Incomplete',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFFF5E5E),
                ),
              ),
              Text(
                'In Progress',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFF6AA1C),
                ),
              ),
              Text(
                'Complete',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, small: 16, medium: 18, large: 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, small: 10, medium: 12, large: 14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 14, medium: 15, large: 16),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              // Upload Button
              GestureDetector(
                onTap: () {
                  // TODO: Implement file upload
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5E5E),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    'Upload',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(icon, size: 34, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No file uploaded',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 11, medium: 12, large: 13),
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Pending',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF424242),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              // TODO: Show sample image
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sample Image',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF2D8CFF),
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.info_outline, size: 12, color: Color(0xFF2D8CFF)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountDetails(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, small: 16, medium: 18, large: 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, small: 10, medium: 12, large: 14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bank Account Details',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 14, medium: 15, large: 16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Pending',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF424242),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Account Holder Name
          _buildFormField(
            context,
            label: 'Account Holder Name',
            controller: _accountHolderNameController,
            hint: 'Enter name as per bank',
          ),
          const SizedBox(height: 16),
          // Account Number
          _buildFormField(
            context,
            label: 'Account Number',
            controller: _accountNumberController,
            hint: 'XXXXXXXXXXXX',
          ),
          const SizedBox(height: 4),
          Text(
            'Re-enter to confirm',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          // IFSC Code
          _buildFormField(
            context,
            label: 'IFSC Code',
            controller: _ifscCodeController,
            hint: 'e.g. HDFC0001234',
          ),
          const SizedBox(height: 4),
          Text(
            'Find on cheque or passbook',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          // Bank Name
          _buildFormField(
            context,
            label: 'Bank Name',
            controller: _bankNameController,
            hint: 'e.g. HDFC Bank',
          ),
          const SizedBox(height: 16),
          // UPI ID
          Row(
            children: [
              Text(
                'UPI ID',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF757575),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(optional)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[400],
                ),
              ),
              const Spacer(),
              const Icon(Icons.info_outline, size: 12, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          _buildFormField(
            context,
            controller: _upiIdController,
            hint: 'e.g. johndoe@upi',
            showLabel: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    String? label,
    bool showLabel = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel && label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF757575),
              ),
            ),
          ),
        ],
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFADAEBC),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFFF5E5E), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhotoUpload(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, small: 16, medium: 18, large: 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, small: 10, medium: 12, large: 14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Profile Photo',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 14, medium: 15, large: 16),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () {
                // TODO: Implement photo upload
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      image: const DecorationImage(
                        image: NetworkImage('https://via.placeholder.com/80'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Tap to',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Upload',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Upload a clear selfie with a plain background. No sunglasses or caps.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF757575),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationCheckbox(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isConfirmed = !_isConfirmed;
            });
          },
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _isConfirmed ? const Color(0xFF0075FF) : Colors.transparent,
              border: Border.all(
                color: _isConfirmed ? const Color(0xFF0075FF) : Colors.grey[400]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(1),
            ),
            child: _isConfirmed
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'I confirm that all uploaded documents are accurate and belong to me',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 14, medium: 15, large: 16),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF424242),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, double screenWidth) {
    final padding = ResponsiveUtils.getResponsiveHorizontalPadding(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            const Color(0xFFF5F6FA).withOpacity(0.5),
          ],
        ),
      ),
      padding: EdgeInsets.only(
        left: padding.horizontal,
        right: padding.horizontal,
        top: 8,
        bottom: 8 + MediaQuery.of(context).padding.bottom,
      ),
      child: GestureDetector(
        onTap: () {
          // TODO: Implement save and continue
        },
        child: Container(
          width: double.infinity,
          height: 54.5,
          decoration: BoxDecoration(
            color: const Color(0xFFFF5E5E),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context, small: 10, medium: 12, large: 14),
            ),
          ),
          child: Center(
            child: Text(
              'Save and Continue',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, small: 14, medium: 15, large: 16),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
