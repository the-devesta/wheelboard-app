import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/learning_model.dart';
import '../../../services/learning_service.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _primary = Color(0xFFF36969);
const _primaryLt = Color(0xFFFFF1F1);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _green = Color(0xFF22C55E);
const _blue = Color(0xFF3B82F6);
const _amber = Color(0xFFF59E0B);
const _danger = Color(0xFFEF4444);

/// Professional learning module detail (mirrors web
/// `/professional/learning/[id]`): enroll-gated video / article content,
/// progress, mark-complete, rating and certificate download.
class LearningDetailScreen extends StatefulWidget {
  final String moduleId;
  const LearningDetailScreen({super.key, required this.moduleId});

  @override
  State<LearningDetailScreen> createState() => _LearningDetailScreenState();
}

class _LearningDetailScreenState extends State<LearningDetailScreen> {
  final _service = LearningService();

  LearningModule? _module;
  List<LearningModule> _related = [];
  bool _loading = true;
  String? _error;
  bool _busy = false;

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
      final results = await Future.wait([
        _service.getModule(widget.moduleId),
        _service.getModules(),
        _service.getMyProgress(widget.moduleId),
      ]);
      if (!mounted) return;
      final module = results[0] as LearningModule;
      final all = results[1] as List<LearningModule>;
      final progress = results[2] as LearningProgress?;
      setState(() {
        _module = module.mergeProgress(progress);
        _related = all
            .where((m) => m.category == module.category && m.id != module.id)
            .take(3)
            .toList();
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

  void _toast(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _enroll() async {
    setState(() => _busy = true);
    try {
      await _service.enroll(widget.moduleId);
      setState(() {
        _module = _module!.copyWith(
          isEnrolled: true,
          enrolledCount: _module!.enrolledCount + 1,
        );
      });
      _toast('Enrolled successfully! You can now watch the content.', _green);
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''), _danger);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _markComplete() async {
    setState(() => _busy = true);
    try {
      await _service.updateProgress(widget.moduleId, 100);
      setState(() => _module = _module!.copyWith(isCompleted: true, progress: 100));
      _toast('Module marked as completed!', _green);
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''), _danger);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rate(int value) async {
    setState(() => _busy = true);
    try {
      await _service.rate(widget.moduleId, value);
      setState(() => _module = _module!.copyWith(userRating: value.toDouble()));
      _toast('Thanks for your rating!', _green);
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''), _danger);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _downloadCertificate() async {
    setState(() => _busy = true);
    try {
      final url = await _service.getCertificate(widget.moduleId);
      await _launch(url);
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''), _danger);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _toast('Invalid link', _danger);
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _toast('Could not open the link', _danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _primary))
            : _error != null
                ? _errorState()
                : _content(),
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
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _primary, foregroundColor: Colors.white, elevation: 0),
              child: Text('Go back',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      );

  Widget _content() {
    final m = _module!;
    return Column(children: [
      _header(m),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            m.isArticle ? _articleCard(m) : _videoCard(m),
            const SizedBox(height: 16),
            _aboutCard(m),
            if (m.isEnrolled && !m.isCompleted) ...[
              const SizedBox(height: 16),
              _markCompleteCard(),
            ],
            if (m.isEnrolled) ...[
              const SizedBox(height: 16),
              _progressCard(m),
            ] else ...[
              const SizedBox(height: 16),
              _enrollButton(),
            ],
            if (m.isCompleted) ...[
              const SizedBox(height: 16),
              _certificateCard(),
            ],
            if (_related.isNotEmpty) ...[
              const SizedBox(height: 20),
              _relatedSection(),
            ],
          ],
        ),
      ),
    ]);
  }

  Widget _header(LearningModule m) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 14),
      color: _card,
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: _textDark),
          onPressed: () => Get.back(),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w700, color: _textDark)),
            Text('${_cap(m.category)} Module',
                style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
          ]),
        ),
      ]),
    );
  }

  // ── Video ──
  Widget _videoCard(LearningModule m) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: !m.isEnrolled
            ? _enrollOverlay(m)
            : (m.videoUrl != null && m.videoUrl!.isNotEmpty)
                ? _playOverlay(m)
                : _noVideo(),
      ),
    );
  }

  Widget _enrollOverlay(LearningModule m) => Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Iconsax.lock, size: 40, color: Colors.white70),
          Padding(
            padding: const EdgeInsets.only(top: 90),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Enroll to watch',
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              Text('Join ${m.enrolledCount} other learners',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _busy ? null : _enroll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Start Learning',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ],
      );

  Widget _playOverlay(LearningModule m) => GestureDetector(
        onTap: () => _launch(m.videoUrl!),
        child: Stack(alignment: Alignment.center, children: [
          if (m.thumbnail != null && m.thumbnail!.isNotEmpty)
            Image.network(m.thumbnail!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
          ),
          Positioned(
            bottom: 12,
            child: Text('Tap to play',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
          ),
        ]),
      );

  Widget _noVideo() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Iconsax.video_slash, size: 36, color: Colors.white54),
          const SizedBox(height: 8),
          Text('No video available',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white54)),
        ]),
      );

  // ── Article ──
  Widget _articleCard(LearningModule m) {
    final text = _stripHtml(m.articleContent ?? '');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Iconsax.document_text, size: 16, color: _primary),
          const SizedBox(width: 8),
          Text('Article • ${m.duration}',
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey)),
        ]),
        const SizedBox(height: 12),
        if (!m.isEnrolled)
          _articleLockedHint()
        else ...[
          Text(text.isEmpty ? 'No content available.' : text,
              style: GoogleFonts.poppins(
                  fontSize: 14, color: const Color(0xFF374151), height: 1.5)),
          if (m.articleUrl != null && m.articleUrl!.isNotEmpty) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _launch(m.articleUrl!),
              icon: const Icon(Iconsax.export_1, size: 16),
              label: Text('Open full article',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: const BorderSide(color: _primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ],
      ]),
    );
  }

  Widget _articleLockedHint() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: _bg, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Iconsax.lock, size: 18, color: _textGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Enroll to read this article.',
                style: GoogleFonts.poppins(fontSize: 13, color: _textGrey)),
          ),
        ]),
      );

  // ── About ──
  Widget _aboutCard(LearningModule m) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('About This Module',
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
        const SizedBox(height: 8),
        Text(m.description,
            style: GoogleFonts.poppins(
                fontSize: 13, color: _textGrey, height: 1.5)),
        const SizedBox(height: 14),
        Row(children: [
          _meta(Iconsax.clock, 'Duration', m.duration, _primary),
          _meta(Iconsax.book_1, 'Lessons', '${m.totalLessons}', _blue),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _meta(Iconsax.star1, 'Rating', m.rating.toStringAsFixed(1), _amber),
          _meta(Iconsax.people, 'Enrolled', '${m.enrolledCount}', _green),
        ]),
        if (m.instructor != null && m.instructor!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _primary,
              child: Text(m.instructor![0].toUpperCase(),
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Instructor',
                  style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
              Text(m.instructor!,
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
            ]),
          ]),
        ],
        const SizedBox(height: 14),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final t in m.tags)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: _primaryLt, borderRadius: BorderRadius.circular(20)),
              child: Text(t,
                  style: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.w500, color: _primary)),
            ),
        ]),
      ]),
    );
  }

  Widget _meta(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
            color: _bg, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: GoogleFonts.poppins(fontSize: 10, color: _textGrey)),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w700, color: _textDark)),
          ]),
        ]),
      ),
    );
  }

  // ── Mark complete ──
  Widget _markCompleteCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Finished?',
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
            Text('Mark complete to unlock your certificate.',
                style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
          ]),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _busy ? null : _markComplete,
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Mark Complete',
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  // ── Progress + rating ──
  Widget _progressCard(LearningModule m) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your Progress',
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${m.progress}% Complete',
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _primary)),
          Text(m.isCompleted ? 'Completed' : 'In Progress',
              style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: m.progress / 100,
            minHeight: 8,
            backgroundColor: _border,
            valueColor: const AlwaysStoppedAnimation(_primary),
          ),
        ),
        const Divider(height: 28, color: _border),
        Center(
          child: Text(m.userRating > 0 ? 'Your rating' : 'How was this module?',
              style: GoogleFonts.poppins(fontSize: 13, color: _textGrey)),
        ),
        const SizedBox(height: 8),
        _ratingStars(m),
        if (m.userRating > 0)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Thanks for rating!',
                  style: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.w600, color: _green)),
            ),
          ),
      ]),
    );
  }

  Widget _ratingStars(LearningModule m) {
    final rated = m.userRating.round();
    final locked = m.userRating > 0 || _busy;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      for (var i = 1; i <= 5; i++)
        GestureDetector(
          onTap: locked ? null : () => _rate(i),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(i <= rated ? Iconsax.star1 : Iconsax.star,
                color: _amber, size: 32),
          ),
        ),
    ]);
  }

  // ── Enroll CTA ──
  Widget _enrollButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _busy ? null : _enroll,
        icon: _busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Iconsax.book, size: 18),
        label: Text('Enroll Now',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  // ── Certificate ──
  Widget _certificateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Iconsax.award, size: 20, color: Color(0xFFB45309)),
          const SizedBox(width: 8),
          Text('Certificate Unlocked',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF92400E))),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _busy ? null : _downloadCertificate,
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Iconsax.document_download, size: 18),
            label: Text('Download Certificate',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Related ──
  Widget _relatedSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Related Modules',
          style: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
      const SizedBox(height: 10),
      ..._related.map((r) => GestureDetector(
            onTap: () =>
                Get.off(() => LearningDetailScreen(moduleId: r.id), preventDuplicates: false),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: _primaryLt, borderRadius: BorderRadius.circular(8)),
                  child: Icon(r.isArticle ? Iconsax.document_text : Iconsax.play,
                      size: 16, color: _primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
                    Text(r.duration,
                        style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
                  ]),
                ),
                const Icon(Iconsax.arrow_right_3, size: 16, color: _textGrey),
              ]),
            ),
          )),
    ]);
  }

  String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String _stripHtml(String html) {
    var s = html.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    s = s.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
    s = s.replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n\n');
    s = s.replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n•  ');
    s = s.replaceAll(RegExp(r'<[^>]+>'), '');
    s = s
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    return s.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }
}
