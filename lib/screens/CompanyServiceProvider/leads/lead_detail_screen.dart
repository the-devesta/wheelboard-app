import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/lead_model.dart';
import '../../../services/lead_service.dart';
import '../../../theme/design_system.dart';
import 'lead_status_style.dart';

/// Lead detail + CRM actions (contact / qualify / convert / lost / notes).
class LeadDetailScreen extends StatefulWidget {
  final String leadId;
  const LeadDetailScreen({super.key, required this.leadId});

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  final _service = LeadService();
  Lead? _lead;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lead = await _service.getLead(widget.leadId);
      if (mounted) {
        setState(() {
          _lead = lead;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _toast(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
    ));
  }

  Future<void> _run(Future<Lead> Function() action, String okMsg) async {
    setState(() => _busy = true);
    try {
      final updated = await action();
      if (mounted) {
        setState(() {
          _lead = updated;
          _busy = false;
        });
        _toast(okMsg, AppPalette.green);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        _toast(e.toString().replaceFirst('Exception: ', ''), AppPalette.danger);
      }
    }
  }

  Future<String?> _promptText(String title, String hint,
      {bool required = false}) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rXl),
        title: Text(title, style: AppText.title),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          style: AppText.bodySm,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.caption,
            filled: true,
            fillColor: AppPalette.bg,
            border: OutlineInputBorder(
                borderRadius: AppRadius.rMd,
                borderSide: const BorderSide(color: AppPalette.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.rMd,
                borderSide: const BorderSide(color: AppPalette.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.rMd,
                borderSide: const BorderSide(color: AppPalette.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppText.subtitle.on(AppPalette.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (required && ctrl.text.trim().isEmpty) return;
              Navigator.of(ctx).pop(ctrl.text.trim());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd)),
            child: Text('Save', style: AppText.subtitle.on(Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(String scheme, String value) async {
    final uri = Uri(scheme: scheme, path: value);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        backgroundColor: AppPalette.card,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppPalette.textDark),
          onPressed: () => Get.back(),
        ),
        centerTitle: false,
        title: Text('Lead Details', style: AppText.h2),
      ),
      body: _loading
          ? const AppLoading()
          : _error != null
              ? AppErrorState(message: _error!, onRetry: _fetch)
              : _content(_lead!),
    );
  }

  Widget _content(Lead lead) {
    final closed = lead.status == 'Converted' || lead.status == 'Lost';
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(lead.companyName, style: AppText.h3)),
              LeadStatusStyle.badge(lead.status),
            ]),
            const SizedBox(height: 4),
            Text('Source: ${lead.source}', style: AppText.caption),
            if (lead.estimatedValue != null && lead.estimatedValue! > 0) ...[
              AppSpacing.vGapMd,
              Row(children: [
                const Icon(Iconsax.money_recive, size: 16, color: AppPalette.green),
                const SizedBox(width: 6),
                Text('Estimated value: ₹${lead.estimatedValue!.toStringAsFixed(0)}',
                    style: AppText.subtitle.on(AppPalette.green)),
              ]),
            ],
          ]),
        ),
        if (lead.companyPhone != null || lead.companyEmail != null) ...[
          AppSpacing.vGapMd,
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Contact', style: AppText.title),
              AppSpacing.vGapSm,
              if (lead.companyPhone != null && lead.companyPhone!.isNotEmpty)
                _contactRow(Iconsax.call, lead.companyPhone!,
                    () => _launch('tel', lead.companyPhone!)),
              if (lead.companyEmail != null && lead.companyEmail!.isNotEmpty)
                _contactRow(Iconsax.sms, lead.companyEmail!,
                    () => _launch('mailto', lead.companyEmail!)),
            ]),
          ),
        ],
        if ((lead.serviceName ?? '').isNotEmpty ||
            (lead.requirements ?? '').isNotEmpty) ...[
          AppSpacing.vGapMd,
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Service', style: AppText.title),
              AppSpacing.vGapSm,
              if ((lead.serviceName ?? '').isNotEmpty)
                _kv('Service', lead.serviceName!),
              if ((lead.serviceCategory ?? '').isNotEmpty)
                _kv('Category', lead.serviceCategory!),
              if ((lead.requirements ?? '').isNotEmpty)
                _kv('Requirements', lead.requirements!),
            ]),
          ),
        ],
        if ((lead.notes ?? '').isNotEmpty) ...[
          AppSpacing.vGapMd,
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Notes', style: AppText.title),
              AppSpacing.vGapSm,
              Text(lead.notes!, style: AppText.bodySm),
            ]),
          ),
        ],
        if (lead.status == 'Lost' && (lead.lostReason ?? '').isNotEmpty) ...[
          AppSpacing.vGapMd,
          AppBanner(
            text: 'Lost: ${lead.lostReason}',
            icon: Iconsax.close_circle,
            color: AppPalette.danger,
            background: AppPalette.dangerBg,
            borderColor: const Color(0x33EF4444),
          ),
        ],
        if (!closed) ...[
          AppSpacing.vGapXl,
          _actions(lead),
        ],
      ],
    );
  }

  Widget _actions(Lead lead) {
    return Column(children: [
      Row(children: [
        if (lead.status == 'New')
          Expanded(
            child: AppSecondaryButton(
              label: 'Mark Contacted',
              icon: Iconsax.call_calling,
              onPressed: _busy
                  ? null
                  : () => _run(() => _service.markContacted(lead.id),
                      'Marked as contacted'),
            ),
          )
        else if (lead.status == 'Contacted')
          Expanded(
            child: AppSecondaryButton(
              label: 'Qualify',
              icon: Iconsax.verify,
              onPressed: _busy
                  ? null
                  : () => _run(
                      () => _service.updateStatus(lead.id, 'Qualified'),
                      'Lead qualified'),
            ),
          )
        else
          const Expanded(child: SizedBox.shrink()),
        AppSpacing.hGapMd,
        Expanded(
          child: AppSecondaryButton(
            label: 'Add Note',
            icon: Iconsax.note_1,
            onPressed: _busy
                ? null
                : () async {
                    final note = await _promptText('Add Note', 'Type a note…',
                        required: true);
                    if (note != null && note.isNotEmpty) {
                      _run(() => _service.addNotes(lead.id, note), 'Note added');
                    }
                  },
          ),
        ),
      ]),
      AppSpacing.vGapMd,
      Row(children: [
        Expanded(
          child: AppPrimaryButton(
            label: 'Convert',
            icon: Iconsax.tick_circle,
            color: AppPalette.green,
            loading: _busy,
            onPressed: _busy
                ? null
                : () => _run(() => _service.convert(lead.id), 'Lead converted!'),
          ),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: AppPrimaryButton(
            label: 'Mark Lost',
            icon: Iconsax.close_circle,
            color: AppPalette.danger,
            loading: false,
            onPressed: _busy
                ? null
                : () async {
                    final reason = await _promptText(
                        'Mark as Lost', 'Reason…',
                        required: true);
                    if (reason != null && reason.isNotEmpty) {
                      _run(() => _service.markLost(lead.id, reason),
                          'Marked as lost');
                    }
                  },
          ),
        ),
      ]),
    ]);
  }

  Widget _contactRow(IconData icon, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Row(children: [
          Icon(icon, size: 16, color: AppPalette.primary),
          AppSpacing.hGapSm,
          Expanded(child: Text(value, style: AppText.bodySm.on(AppPalette.primary))),
          const Icon(Iconsax.arrow_right_3, size: 14, color: AppPalette.textGrey),
        ]),
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 110, child: Text(k, style: AppText.label)),
          Expanded(child: Text(v, style: AppText.bodySm.weight(FontWeight.w600))),
        ]),
      );
}
