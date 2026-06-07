import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/issue_model.dart';
import '../../../services/issue_service.dart';
import 'issue_status_style.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _primary = Color(0xFFF36969);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _green = Color(0xFF22C55E);

/// Issue detail — fetches `GET /issues/:id` and shows the full ticket with its
/// status, priority, description and (when present) the admin resolution.
class IssueDetailScreen extends StatefulWidget {
  final String issueId;
  const IssueDetailScreen({super.key, required this.issueId});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  final _service = IssueService();
  Issue? _issue;
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
      final issue = await _service.getIssue(widget.issueId);
      if (mounted) {
        setState(() {
          _issue = issue;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textDark),
          onPressed: () => Get.back(),
        ),
        centerTitle: false,
        title: Text('Issue Details',
            style: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.w700, color: _textDark)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _error != null
              ? _errorState()
              : _content(_issue!),
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

  Widget _content(Issue issue) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        _card1(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (issue.issueId.isNotEmpty)
                Text('#${issue.issueId}',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textGrey)),
              const Spacer(),
              IssueStatusStyle.badge(issue.status),
            ]),
            const SizedBox(height: 10),
            Text(issue.title,
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 10),
            Row(children: [
              _metaPill(Iconsax.category, issue.category),
              const SizedBox(width: 8),
              IssueStatusStyle.priorityPill(issue.priority),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
        _card1(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Description',
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 8),
            Text(issue.description,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: const Color(0xFF374151), height: 1.5)),
          ]),
        ),
        if (issue.resolution != null && issue.resolution!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _green.withValues(alpha: 0.25)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Iconsax.tick_circle, size: 16, color: _green),
                const SizedBox(width: 8),
                Text('Resolution',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _green)),
              ]),
              const SizedBox(height: 8),
              Text(issue.resolution!,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF374151),
                      height: 1.5)),
              if (issue.resolvedAt != null) ...[
                const SizedBox(height: 6),
                Text('Resolved on ${_fmtDate(issue.resolvedAt!)}',
                    style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
              ],
            ]),
          ),
        ],
        const SizedBox(height: 14),
        _card1(
          child: Column(children: [
            _kv('Reported by', issue.reportedByName.isNotEmpty
                ? issue.reportedByName
                : issue.reportedByEmail),
            if (issue.createdAt != null)
              _kv('Reported on', _fmtDate(issue.createdAt!)),
            if (issue.updatedAt != null)
              _kv('Last updated', _fmtDate(issue.updatedAt!)),
          ]),
        ),
      ],
    );
  }

  Widget _card1({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: child,
      );

  Widget _metaPill(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: _bg, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: _textGrey),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11, fontWeight: FontWeight.w600, color: _textGrey)),
        ]),
      );

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 110,
            child: Text(k,
                style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
          ),
          Expanded(
            child: Text(v,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textDark)),
          ),
        ]),
      );

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final local = d.toLocal();
    return '${m[local.month - 1]} ${local.day}, ${local.year}';
  }
}
