import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/learning_model.dart';
import '../../../services/learning_service.dart';
import 'learning_detail_screen.dart';

// ── Design tokens (match Trips / Fleet) ────────────────────────────────────────
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

/// Professional "My Learning" list — wired to the backend (mirrors web
/// `/professional/learning`): stats, search, category filter and the
/// Continue / Completed / Available sections.
class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  final _service = LearningService();
  final _searchCtrl = TextEditingController();

  List<LearningModule> _modules = [];
  List<LearningCategory> _categories = [];
  bool _loading = true;
  String? _error;
  String _selectedCategory = 'all';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.getModules(),
        _service.getCategories(),
      ]);
      if (!mounted) return;
      setState(() {
        _modules = results[0] as List<LearningModule>;
        _categories = results[1] as List<LearningCategory>;
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

  List<LearningModule> get _filtered {
    return _modules.where((m) {
      final matchesCat =
          _selectedCategory == 'all' || m.category == _selectedCategory;
      final q = _search.toLowerCase();
      final matchesSearch = q.isEmpty ||
          m.title.toLowerCase().contains(q) ||
          m.description.toLowerCase().contains(q);
      return matchesCat && matchesSearch;
    }).toList();
  }

  Future<void> _openModule(LearningModule m) async {
    await Get.to(() => LearningDetailScreen(moduleId: m.id));
    // Refresh so completed/progress changes reflect in stats & sections.
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _header(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _primary))
                : _error != null
                    ? _errorState()
                    : RefreshIndicator(
                        color: _primary,
                        onRefresh: _fetch,
                        child: _body(),
                      ),
          ),
        ]),
      ),
    );
  }

  Widget _header() {
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
            Text('My Learning',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700, color: _textDark)),
            Text('Enhance your skills with training modules',
                style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
          ]),
        ),
      ]),
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
                  backgroundColor: _primary, foregroundColor: Colors.white, elevation: 0),
              child: Text('Try again',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      );

  Widget _body() {
    final filtered = _filtered;
    final inProgress = filtered.where((m) => m.isInProgress).toList();
    final completed = filtered.where((m) => m.isCompleted).toList();
    final notStarted = filtered.where((m) => m.progress == 0).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _statsRow(),
        const SizedBox(height: 16),
        _searchBar(),
        const SizedBox(height: 14),
        _categoryChips(),
        const SizedBox(height: 18),
        if (filtered.isEmpty)
          _empty()
        else ...[
          if (inProgress.isNotEmpty) ...[
            _sectionTitle('Continue Learning', inProgress.length),
            ...inProgress.map(_moduleCard),
            const SizedBox(height: 8),
          ],
          if (completed.isNotEmpty) ...[
            _sectionTitle('Completed', completed.length),
            ...completed.map(_moduleCard),
            const SizedBox(height: 8),
          ],
          if (notStarted.isNotEmpty) ...[
            _sectionTitle('Available Modules', notStarted.length),
            ...notStarted.map(_moduleCard),
          ],
        ],
      ],
    );
  }

  Widget _statsRow() {
    final completed = _modules.where((m) => m.isCompleted).length;
    final inProgress = _modules.where((m) => m.isInProgress).length;
    return Row(children: [
      _statCard('Completed', '$completed', Iconsax.tick_circle, _green),
      const SizedBox(width: 10),
      _statCard('In Progress', '$inProgress', Iconsax.play_circle, _primary),
      const SizedBox(width: 10),
      _statCard('Total', '${_modules.length}', Iconsax.book, _blue),
      const SizedBox(width: 10),
      _statCard('Certificates', '$completed', Iconsax.award, _amber),
    ]);
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 10, color: _textGrey)),
        ]),
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: _searchCtrl,
      onChanged: (v) => setState(() => _search = v),
      style: GoogleFonts.poppins(fontSize: 13, color: _textDark),
      decoration: InputDecoration(
        hintText: 'Search modules…',
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: _textGrey),
        prefixIcon: const Icon(Iconsax.search_normal_1, size: 18, color: _textGrey),
        filled: true,
        fillColor: _card,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary),
        ),
      ),
    );
  }

  Widget _categoryChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip('all', 'All', '${_modules.length}', null),
          ..._categories.map((c) => _chip(c.id, c.name, '${c.count}', c.icon)),
        ],
      ),
    );
  }

  Widget _chip(String id, String label, String count, String? icon) {
    final active = _selectedCategory == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? _primary : _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? _primary : _border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null && icon.isNotEmpty) ...[
              Text(icon, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
            ],
            Text('$label ($count)',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : _textGrey)),
          ]),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, int count) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text('$title ($count)',
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
      );

  Widget _moduleCard(LearningModule m) {
    final Color accent =
        m.isCompleted ? _green : (m.isInProgress ? _primary : _textGrey);
    return GestureDetector(
      onTap: () => _openModule(m),
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
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.7)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                  m.isCompleted
                      ? Iconsax.tick_circle
                      : (m.isArticle ? Iconsax.document_text : Iconsax.play),
                  color: Colors.white,
                  size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
                const SizedBox(height: 2),
                Text(m.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Iconsax.clock, size: 12, color: _textGrey),
                  const SizedBox(width: 4),
                  Text(m.duration,
                      style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
                  const SizedBox(width: 10),
                  const Icon(Iconsax.book_1, size: 12, color: _textGrey),
                  const SizedBox(width: 4),
                  Text('${m.totalLessons} lessons',
                      style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
                ]),
              ]),
            ),
          ]),
          if (m.isInProgress) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: m.progress / 100,
                    minHeight: 6,
                    backgroundColor: _border,
                    valueColor: const AlwaysStoppedAnimation(_primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${m.progress}%',
                  style: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.w700, color: _primary)),
            ]),
          ],
          if (m.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in m.tags.take(3))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: _primaryLt, borderRadius: BorderRadius.circular(20)),
                    child: Text(t,
                        style: GoogleFonts.poppins(
                            fontSize: 10, fontWeight: FontWeight.w500, color: _primary)),
                  ),
                _difficultyBadge(m.difficulty),
              ],
            ),
          ],
        ]),
      ),
    );
  }

  Widget _difficultyBadge(String d) {
    Color c;
    switch (d) {
      case 'advanced':
        c = const Color(0xFFEF4444);
        break;
      case 'intermediate':
        c = _amber;
        break;
      default:
        c = _green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Text(d.isEmpty ? '' : '${d[0].toUpperCase()}${d.substring(1)}',
          style: GoogleFonts.poppins(
              fontSize: 10, fontWeight: FontWeight.w600, color: c)),
    );
  }

  Widget _empty() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: _primaryLt, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Iconsax.book, color: _primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text('No modules found',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600, color: _textGrey)),
          const SizedBox(height: 6),
          Text('Try adjusting your search or filters',
              style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
        ]),
      );
}
