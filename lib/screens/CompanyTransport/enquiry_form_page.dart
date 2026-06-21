import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../theme/design_system.dart';
import '../../widgets/custom_snackbar.dart';

/// Service enquiry form — 1:1 with wheelboard-fe `ServiceEnquiryModal`.
///
/// Submits to `POST /enquiries/service` with the exact web payload:
/// `{ companyId?, serviceType, serviceLocation, currentChallenges, specialRequirements? }`.
/// `serviceType` is one of `'tire' | 'consulting'` (web defaults to `'tire'`).
class EnquiryFormPage extends StatefulWidget {
  const EnquiryFormPage({super.key});

  @override
  State<EnquiryFormPage> createState() => _EnquiryFormPageState();
}

class _EnquiryFormPageState extends State<EnquiryFormPage> {
  // Matches the web `selectedService` values exactly.
  String _serviceType = 'tire';

  final _locationCtrl = TextEditingController();
  final _challengesCtrl = TextEditingController();
  final _requirementsCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _locationCtrl.dispose();
    _challengesCtrl.dispose();
    _requirementsCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _locationCtrl.text.trim().isNotEmpty &&
      _challengesCtrl.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_isValid || _submitting) return;
    setState(() => _submitting = true);
    try {
      final companyId = AuthService.to.userId;
      await ApiClient.instance.post(
        ApiEndpoints.enquiries.service,
        data: {
          if (companyId.isNotEmpty) 'companyId': companyId,
          'serviceType': _serviceType,
          'serviceLocation': _locationCtrl.text.trim(),
          'currentChallenges': _challengesCtrl.text.trim(),
          'specialRequirements': _requirementsCtrl.text.trim(),
        },
      );
      if (!mounted) return;
      SnackBarHelper.success('Enquiry submitted. Our team will reach out soon.');
      Navigator.pop(context);
    } catch (e) {
      SnackBarHelper.error('Failed to submit enquiry. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xl),
              children: [
                Text('What do you need?', style: AppText.h3),
                const SizedBox(height: AppSpacing.xs),
                Text('Pick a service category',
                    style: AppText.bodySm.on(AppPalette.textGrey)),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _serviceCard(
                        icon: Icons.build_circle_outlined,
                        title: 'Tire Services',
                        subtitle: 'We manage & maintain your tires',
                        value: 'tire',
                        accent: AppPalette.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _serviceCard(
                        icon: Icons.insights_outlined,
                        title: 'Consulting',
                        subtitle: 'We manage your operational complexities',
                        value: 'consulting',
                        accent: AppPalette.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _field(
                  label: 'Service location',
                  required: true,
                  controller: _locationCtrl,
                  hint: 'Enter your service location…',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: AppSpacing.lg),
                _field(
                  label: 'Current challenges',
                  required: true,
                  controller: _challengesCtrl,
                  hint: 'Describe the current issues you are facing…',
                  icon: Icons.report_problem_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: AppSpacing.lg),
                _field(
                  label: 'Special requirements',
                  required: false,
                  controller: _requirementsCtrl,
                  hint: 'Mention any special instructions (optional)…',
                  icon: Icons.info_outline,
                  maxLines: 4,
                ),
              ],
            ),
          ),
          _submitBar(),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _header(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppPalette.brandGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Service Enquiry',
                        style: AppText.h1.on(Colors.white)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tell us what you need and our team will reach out.',
                      style: AppText.bodySm.on(Colors.white.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Service card ────────────────────────────────────────────────────────
  Widget _serviceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color accent,
  }) {
    final selected = _serviceType == value;
    return GestureDetector(
      onTap: () => setState(() => _serviceType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.06) : AppPalette.card,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: selected ? accent : AppPalette.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                Icon(
                  selected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: selected ? accent : AppPalette.textFaint,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppText.title),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: AppText.caption, maxLines: 2),
          ],
        ),
      ),
    );
  }

  // ── Labeled field ───────────────────────────────────────────────────────
  Widget _field({
    required String label,
    required bool required,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppText.subtitle),
            if (required)
              Text(' *', style: AppText.subtitle.on(AppPalette.danger)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppPalette.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppPalette.border),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: (_) => setState(() {}),
            style: AppText.body.on(AppPalette.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppText.bodySm.on(AppPalette.textFaint),
              prefixIcon: Padding(
                padding: EdgeInsets.only(
                    bottom: maxLines > 1 ? (maxLines - 1) * 22.0 : 0),
                child: Icon(icon, color: AppPalette.textGrey, size: 20),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 44, minHeight: 44),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md, horizontal: AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }

  // ── Submit bar ──────────────────────────────────────────────────────────
  Widget _submitBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppPalette.card,
        border: Border(top: BorderSide(color: AppPalette.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppPrimaryButton(
            label: 'Submit Enquiry',
            icon: Icons.send_rounded,
            loading: _submitting,
            onPressed: _isValid ? _submit : null,
          ),
        ),
      ),
    );
  }
}
