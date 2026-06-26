import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/legal_content.dart';

// Design tokens
const _primary = Color(0xFFF36969);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);

/// Legal content screen — renders the canonical Privacy Policy / Terms &
/// Conditions bundled in [legal_content.dart]. The exact same content (verbatim
/// from the official PDFs) is shown on the web app, so the documents are
/// identical across mobile and web. Renders fully offline — no network needed.
enum LegalType { privacyPolicy, termsOfService }

class LegalScreen extends StatelessWidget {
  final LegalType type;

  const LegalScreen({super.key, required this.type});

  LegalDoc get _doc =>
      type == LegalType.privacyPolicy ? privacyPolicy : termsAndConditions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: _border,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _textDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _doc.title,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: LegalDocumentBody(
        doc: _doc,
        icon: type == LegalType.privacyPolicy
            ? Icons.shield_outlined
            : Icons.gavel_rounded,
      ),
    );
  }
}

/// Renders a [LegalDoc] (header card + sections/blocks). Shared so the same
/// rendering is used wherever legal content is shown in the app.
class LegalDocumentBody extends StatelessWidget {
  final LegalDoc doc;
  final IconData icon;

  const LegalDocumentBody({super.key, required this.doc, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF36969), Color(0xFFFF8C8C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              doc.title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated: ${doc.lastUpdated}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ]),
        ),
        // Document body
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final section in doc.sections) ..._buildSection(section),
            ],
          ),
        ),
      ]),
    );
  }

  List<Widget> _buildSection(LegalSection section) {
    return [
      if (section.heading != null) ...[
        const SizedBox(height: 6),
        Text(
          section.heading!,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 8),
      ],
      for (final block in section.blocks) _buildBlock(block),
      const SizedBox(height: 6),
    ];
  }

  Widget _buildBlock(LegalBlock block) {
    switch (block.kind) {
      case 'sub':
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            block.text,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: _textDark,
              height: 1.5,
            ),
          ),
        );
      case 'li':
        return Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 7, right: 8),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: _primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  block.text,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _textDark,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      default: // 'p'
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            block.text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: _textDark,
              height: 1.7,
            ),
          ),
        );
    }
  }
}

/// About Wheelboard — company info screen for the Legal/Settings section.
class AboutWheelboardScreen extends StatelessWidget {
  const AboutWheelboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: _border,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _textDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text('About Wheelboard',
            style: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.w700, color: _textDark)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: Column(children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.local_shipping_rounded,
                color: _primary, size: 40),
          ),
          const SizedBox(height: 16),
          Text('Wheelboard',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w700, color: _textDark)),
          const SizedBox(height: 4),
          Text(LegalContact.company,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: _textGrey)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wheelboard provides an integrated digital logistics ecosystem designed to connect fleet owners, drivers, mechanics, and service providers — with tools for tracking transport profitability, operational intelligence, maintenance, and other logistics-related services.',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: _textDark, height: 1.7),
                ),
                const SizedBox(height: 16),
                _infoRow(Icons.email_outlined, LegalContact.email),
                const SizedBox(height: 10),
                _infoRow(Icons.phone_outlined, LegalContact.phone),
                const SizedBox(height: 10),
                _infoRow(Icons.location_on_outlined, LegalContact.address),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: _primary),
      const SizedBox(width: 10),
      Expanded(
        child: Text(text,
            style: GoogleFonts.poppins(fontSize: 13, color: _textDark)),
      ),
    ]);
  }
}

/// Contact Support — quick actions to reach the Wheelboard team.
class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  Future<void> _launch(String uri) async {
    final u = Uri.parse(uri);
    if (await canLaunchUrl(u)) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: _border,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _textDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text('Contact Support',
            style: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.w700, color: _textDark)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          Text(
            'We are here to help. Reach the Wheelboard team using any of the options below.',
            style: GoogleFonts.poppins(fontSize: 13, color: _textGrey),
          ),
          const SizedBox(height: 16),
          _supportTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: LegalContact.email,
            onTap: () => _launch('mailto:${LegalContact.email}'),
          ),
          _supportTile(
            icon: Icons.phone_outlined,
            title: 'Call',
            subtitle: '020-6732049',
            onTap: () => _launch('tel:0206732049'),
          ),
          _supportTile(
            icon: Icons.chat_outlined,
            title: 'WhatsApp',
            subtitle: '+91 7420861942',
            onTap: () => _launch('https://wa.me/917420861942'),
          ),
          _supportTile(
            icon: Icons.location_on_outlined,
            title: 'Address',
            subtitle: LegalContact.address,
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _supportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _primary, size: 20),
        ),
        title: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
        subtitle: Text(subtitle,
            style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: _textGrey)
            : null,
      ),
    );
  }
}
