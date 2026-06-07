import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/issue_model.dart';
import '../../services/issue_service.dart';
import '../../widgets/custom_snackbar.dart';

// Design tokens
const _primary = Color(0xFFF36969);
const _primaryLt = Color(0xFFFFF1F1);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _green = Color(0xFF22C55E);
const _amber = Color(0xFFF59E0B);
const _red = Color(0xFFEF4444);

/// Issues / Support Ticket screen — mirrors `/company/issues` on web.
///
/// Shared across all 3 roles (Company, Professional, Service Provider).
/// Accessible from each role's profile or settings menu.
///
/// Features:
///  - List current user's tickets grouped by status
///  - Create new ticket via bottom sheet form
class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  final _service = IssueService();
  List<Issue> _issues = [];
  bool _loading = true;
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
      final list = await _service.getMyIssues();
      if (!mounted) return;
      setState(() {
        _issues = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ── Create ticket bottom sheet ─────────────────────────────────────────────

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateIssueSheet(
        onCreated: () {
          Get.back();
          _fetch();
        },
        service: _service,
      ),
    );
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
        title: Text(
          'Support Tickets',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _showCreateSheet,
              icon: const Icon(Icons.add_rounded, color: _primary, size: 18),
              label: Text(
                'New',
                style: GoogleFonts.poppins(
                  color: _primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _error != null
              ? _errorState()
              : RefreshIndicator(
                  onRefresh: _fetch,
                  color: _primary,
                  child: _issues.isEmpty ? _emptyState() : _list(),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSheet,
        backgroundColor: _primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: Text(
          'Report Issue',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _errorState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Iconsax.warning_2, size: 44, color: _primary),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: _textGrey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetch,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0),
              child: Text('Try again',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      );

  Widget _emptyState() => ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                    color: _primaryLt, shape: BoxShape.circle),
                child: const Icon(Iconsax.message_question,
                    size: 38, color: _primary),
              ),
              const SizedBox(height: 20),
              Text('No tickets yet',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textDark)),
              const SizedBox(height: 6),
              Text('Report an issue and we\'ll help you quickly.',
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: _textGrey),
                  textAlign: TextAlign.center),
            ]),
          ),
        ],
      );

  Widget _list() {
    final open = _issues.where((i) => i.isOpen).toList();
    final inProcess = _issues.where((i) => i.isInProcess).toList();
    final resolved = _issues.where((i) => i.isResolved).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Quick stats row
        _statsRow(open.length, inProcess.length, resolved.length),
        const SizedBox(height: 16),
        if (open.isNotEmpty) ...[
          _sectionTitle('Open', open.length),
          ...open.map(_issueCard),
          const SizedBox(height: 8),
        ],
        if (inProcess.isNotEmpty) ...[
          _sectionTitle('In Progress', inProcess.length),
          ...inProcess.map(_issueCard),
          const SizedBox(height: 8),
        ],
        if (resolved.isNotEmpty) ...[
          _sectionTitle('Resolved', resolved.length),
          ...resolved.map(_issueCard),
        ],
      ],
    );
  }

  Widget _statsRow(int open, int inProcess, int resolved) {
    return Row(children: [
      _statCard('Open', '$open', _red),
      const SizedBox(width: 10),
      _statCard('In Progress', '$inProcess', _amber),
      const SizedBox(width: 10),
      _statCard('Resolved', '$resolved', _green),
    ]);
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String title, int count) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text('$title ($count)',
            style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textDark)),
      );

  Widget _issueCard(Issue issue) {
    final statusColor = issue.isResolved
        ? _green
        : issue.isInProcess
            ? _amber
            : _red;
    final priorityColor = issue.priority == 'High'
        ? _red
        : issue.priority == 'Medium'
            ? _amber
            : _green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(issue.title,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          // Status badge
          _badge(issue.status, statusColor),
        ]),
        const SizedBox(height: 6),
        Text(issue.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
        const SizedBox(height: 10),
        Row(children: [
          _badge(issue.category, _primary),
          const SizedBox(width: 6),
          _badge(issue.priority, priorityColor),
          const Spacer(),
          if (issue.createdAt != null)
            Text(
              _formatDate(issue.createdAt!),
              style: GoogleFonts.poppins(fontSize: 10, color: _textGrey),
            ),
        ]),
        if (issue.isResolved && issue.resolution != null) ...[
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _green.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.check_circle_outline_rounded,
                  size: 14, color: _green),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(issue.resolution!,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: _green))),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      );

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ── Create Issue Bottom Sheet ─────────────────────────────────────────────────

class _CreateIssueSheet extends StatefulWidget {
  final VoidCallback onCreated;
  final IssueService service;

  const _CreateIssueSheet({
    required this.onCreated,
    required this.service,
  });

  @override
  State<_CreateIssueSheet> createState() => _CreateIssueSheetState();
}

class _CreateIssueSheetState extends State<_CreateIssueSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = kIssueCategories.first;
  String _priority = 'Medium';
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (title.isEmpty) {
      SnackBarHelper.error('Please enter a title');
      return;
    }
    if (desc.isEmpty) {
      SnackBarHelper.error('Please enter a description');
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.service.createIssue(CreateIssuePayload(
        title: title,
        description: desc,
        category: _category,
        priority: _priority,
      ));
      SnackBarHelper.success('Ticket submitted! Our team will review it shortly.');
      widget.onCreated();
    } catch (e) {
      SnackBarHelper.error(
          e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 16),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: _border, borderRadius: BorderRadius.circular(2)),
        ),
        Text('Report an Issue',
            style: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.w700, color: _textDark)),
        const SizedBox(height: 16),
        _field('Title', _titleCtrl, 'e.g. Payment not processed'),
        const SizedBox(height: 12),
        _field('Description', _descCtrl,
            'Describe your issue in detail…',
            maxLines: 4),
        const SizedBox(height: 12),
        // Category + Priority row
        Row(children: [
          Expanded(child: _dropdown('Category', _category,
              kIssueCategories, (v) => setState(() => _category = v!))),
          const SizedBox(width: 12),
          Expanded(child: _dropdown('Priority', _priority,
              kIssuePriorities, (v) => setState(() => _priority = v!))),
        ]),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text('Submit Ticket',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        ),
      ]),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey)),
      const SizedBox(height: 4),
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: GoogleFonts.poppins(fontSize: 13, color: _textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: _textGrey),
          filled: true,
          fillColor: _bg,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primary)),
        ),
      ),
    ]);
  }

  Widget _dropdown(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey)),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(o,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: _textDark))))
                .toList(),
            onChanged: onChanged,
            style: GoogleFonts.poppins(fontSize: 13, color: _textDark),
          ),
        ),
      ),
    ]);
  }
}
