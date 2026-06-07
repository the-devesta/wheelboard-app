import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/issue_model.dart';
import '../../../services/issue_service.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _primary = Color(0xFFF36969);
const _bg = Color(0xFFF9FAFB);
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _green = Color(0xFF22C55E);
const _amber = Color(0xFFF59E0B);
const _danger = Color(0xFFEF4444);

/// Bottom sheet to report a new issue — mirrors the web issue report form.
/// Returns `true` from [show] when an issue was created.
class ReportIssueSheet extends StatefulWidget {
  const ReportIssueSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReportIssueSheet(),
    );
  }

  @override
  State<ReportIssueSheet> createState() => _ReportIssueSheetState();
}

class _ReportIssueSheetState extends State<ReportIssueSheet> {
  final _service = IssueService();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _category = kIssueCategories.first;
  String _priority = 'Medium';
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (title.isEmpty || desc.isEmpty) {
      setState(() => _error = 'Please enter a title and description.');
      return;
    }
    setState(() {
      _error = null;
      _submitting = true;
    });
    try {
      await _service.createIssue(CreateIssuePayload(
        title: title,
        description: desc,
        category: _category,
        priority: _priority,
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Issue reported successfully',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: _border, borderRadius: BorderRadius.circular(10)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Iconsax.message_question,
                      size: 18, color: _primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Report an Issue',
                      style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _textDark)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: _textGrey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]),
            ),
            const Divider(height: 1, color: _border),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Title'),
                    _field(_titleCtrl, 'Brief summary of the issue'),
                    const SizedBox(height: 16),
                    _label('Description'),
                    _field(_descCtrl, 'Describe what happened…', maxLines: 4),
                    const SizedBox(height: 16),
                    _label('Category'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kIssueCategories
                          .map((c) => _chip(c, _category == c,
                              () => setState(() => _category = c)))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    _label('Priority'),
                    Row(
                      children: [
                        for (final p in kIssuePriorities) ...[
                          Expanded(child: _priorityTile(p)),
                          if (p != kIssuePriorities.last)
                            const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Text(_error!,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: const Color(0xFFB91C1C))),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitting ? null : _submit,
                        icon: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Iconsax.send_1, size: 18),
                        label: Text('Submit Report',
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              _primary.withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey)),
      );

  Widget _field(TextEditingController c, String hint, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      enabled: !_submitting,
      style: GoogleFonts.poppins(fontSize: 14, color: _textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: _textGrey),
        filled: true,
        fillColor: _bg,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1.4),
        ),
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: _submitting ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _primary : _bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? _primary : _border),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : _textGrey)),
      ),
    );
  }

  Widget _priorityTile(String p) {
    final active = _priority == p;
    final color = p == 'High'
        ? _danger
        : p == 'Medium'
            ? _amber
            : _green;
    return GestureDetector(
      onTap: _submitting ? null : () => setState(() => _priority = p),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : _bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? color : _border),
        ),
        child: Text(p,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? color : _textGrey)),
      ),
    );
  }
}
