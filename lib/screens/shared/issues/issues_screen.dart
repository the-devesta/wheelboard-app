import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/issue_model.dart';
import '../../../services/issue_service.dart';
import 'issue_detail_screen.dart';
import 'issue_status_style.dart';
import 'report_issue_sheet.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _primary = Color(0xFFF36969);
const _primaryLt = Color(0xFFFFF1F1);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);

/// "Help & Support" — the user's reported issues (`GET /issues/my`) with a
/// button to report a new one. Available to all roles.
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
      final issues = await _service.getMyIssues();
      if (mounted) {
        setState(() {
          _issues = issues;
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

  Future<void> _report() async {
    final created = await ReportIssueSheet.show(context);
    if (created == true) _fetch();
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
        title: Text('Help & Support',
            style: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.w700, color: _textDark)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _report,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        icon: const Icon(Iconsax.add, size: 20),
        label: Text('Report Issue',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _error != null
              ? _errorState()
              : RefreshIndicator(
                  color: _primary,
                  onRefresh: _fetch,
                  child: _issues.isEmpty ? _emptyState() : _list(),
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
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.22),
          Center(
            child: Column(children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                    color: _primaryLt, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Iconsax.message_question,
                    color: _primary, size: 32),
              ),
              const SizedBox(height: 16),
              Text('No issues reported',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textGrey)),
              const SizedBox(height: 6),
              Text('Tap “Report Issue” if you need help.',
                  style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
            ]),
          ),
        ],
      );

  Widget _list() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _issues.length,
      itemBuilder: (_, i) => _issueCard(_issues[i]),
    );
  }

  Widget _issueCard(Issue issue) {
    return GestureDetector(
      onTap: () => Get.to(() => IssueDetailScreen(issueId: issue.id)),
      child: Container(
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _textDark)),
            ),
            const SizedBox(width: 8),
            IssueStatusStyle.badge(issue.status),
          ]),
          const SizedBox(height: 6),
          Text(issue.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
          const SizedBox(height: 10),
          Row(children: [
            if (issue.issueId.isNotEmpty) ...[
              Text('#${issue.issueId}',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _textGrey)),
              const SizedBox(width: 10),
            ],
            Icon(Iconsax.category, size: 12, color: _textGrey),
            const SizedBox(width: 4),
            Text(issue.category,
                style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
            const Spacer(),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                  color: IssueStatusStyle.priorityColor(issue.priority),
                  shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(issue.priority,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: IssueStatusStyle.priorityColor(issue.priority))),
          ]),
        ]),
      ),
    );
  }
}
