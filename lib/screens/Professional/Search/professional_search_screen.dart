import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

// Design tokens
const _primary = Color(0xFFF36969);
const _primaryLt = Color(0xFFFFF1F1);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _blue = Color(0xFF3B82F6);
const _green = Color(0xFF22C55E);
const _amber = Color(0xFFF59E0B);

/// Professional global search screen — mirrors `/professional/search` on web.
///
/// Searches across:
///  - Jobs (browse endpoint with query param)
///  - Trips (unassigned list with query param)
///  - Learning modules
///
/// All results in a unified tabbed view.
class ProfessionalSearchScreen extends StatefulWidget {
  const ProfessionalSearchScreen({super.key});

  @override
  State<ProfessionalSearchScreen> createState() =>
      _ProfessionalSearchScreenState();
}

class _ProfessionalSearchScreenState
    extends State<ProfessionalSearchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _searchCtrl = TextEditingController();
  String _query = '';

  // Results
  List<Map<String, dynamic>> _jobs = [];
  List<Map<String, dynamic>> _trips = [];
  List<Map<String, dynamic>> _learning = [];

  bool _loading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _hasSearched = true;
      _query = q.trim();
    });

    try {
      final results = await Future.wait([
        _fetchJobs(q),
        _fetchTrips(q),
        _fetchLearning(q),
      ]);

      if (!mounted) return;
      setState(() {
        _jobs = results[0];
        _trips = results[1];
        _learning = results[2];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchJobs(String q) async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.jobs.browse,
        queryParameters: {'search': q, 'limit': 20},
      );
      return _extractList(raw, 'jobs');
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTrips(String q) async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.trips.unassignedList,
        queryParameters: {'search': q, 'assigned': false, 'limit': 20},
      );
      return _extractList(raw, 'trips');
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchLearning(String q) async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.learning.list,
        queryParameters: {'search': q, 'limit': 20},
      );
      return _extractList(raw, 'modules');
    } catch (_) {
      return [];
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic raw, String key) {
    if (raw is Map) {
      // Try data.jobs / data.trips / data.modules
      final data = raw['data'] ?? raw;
      if (data is List) {
        return data.whereType<Map>().map(_toStringMap).toList();
      }
      if (data is Map) {
        final inner = data[key] ?? data['items'] ?? data;
        if (inner is List) {
          return inner.whereType<Map>().map(_toStringMap).toList();
        }
      }
    }
    if (raw is List) return raw.whereType<Map>().map(_toStringMap).toList();
    return [];
  }

  Map<String, dynamic> _toStringMap(Map m) =>
      Map<String, dynamic>.from(m);

  int get _totalResults =>
      _jobs.length + _trips.length + _learning.length;

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
        title: _searchBar(),
        titleSpacing: 0,
      ),
      body: Column(children: [
        // Tab bar
        Container(
          color: _card,
          child: TabBar(
            controller: _tabs,
            labelColor: _primary,
            unselectedLabelColor: _textGrey,
            indicatorColor: _primary,
            labelStyle: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle:
                GoogleFonts.poppins(fontSize: 12),
            tabs: [
              Tab(text: 'Jobs (${_jobs.length})'),
              Tab(text: 'Trips (${_trips.length})'),
              Tab(text: 'Learning (${_learning.length})'),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: _primary))
              : !_hasSearched
                  ? _placeholder()
                  : _totalResults == 0
                      ? _noResults()
                      : TabBarView(
                          controller: _tabs,
                          children: [
                            _jobsTab(),
                            _tripsTab(),
                            _learningTab(),
                          ],
                        ),
        ),
      ]),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: TextField(
        controller: _searchCtrl,
        autofocus: true,
        onSubmitted: _search,
        style: GoogleFonts.poppins(fontSize: 14, color: _textDark),
        decoration: InputDecoration(
          hintText: 'Search jobs, trips, learning…',
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: _textGrey),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Iconsax.search_normal_1,
                size: 20, color: _primary),
            onPressed: () => _search(_searchCtrl.text),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Iconsax.search_normal_1, size: 56, color: _textGrey),
        const SizedBox(height: 16),
        Text('Search anything',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textDark)),
        const SizedBox(height: 6),
        Text('Jobs, trips, and learning modules',
            style: GoogleFonts.poppins(fontSize: 14, color: _textGrey)),
      ]),
    );
  }

  Widget _noResults() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
              color: _primaryLt,
              borderRadius: BorderRadius.circular(20)),
          child: const Icon(Iconsax.search_normal_1,
              size: 32, color: _primary),
        ),
        const SizedBox(height: 16),
        Text('No results for "$_query"',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textDark)),
        const SizedBox(height: 6),
        Text('Try different keywords',
            style: GoogleFonts.poppins(fontSize: 13, color: _textGrey)),
      ]),
    );
  }

  // ── Jobs Tab ──────────────────────────────────────────────────────────────

  Widget _jobsTab() {
    if (_jobs.isEmpty) return _emptyTab('No jobs matched your search');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: _jobs.length,
      itemBuilder: (_, i) => _jobCard(_jobs[i]),
    );
  }

  Widget _jobCard(Map<String, dynamic> job) {
    final role = (job['role'] ?? job['type'] ?? 'Job').toString();
    final city = (job['city'] ?? '').toString();
    final salary = (job['salary'] ?? '').toString();
    final duration = (job['jobDuration'] ?? job['duration'] ?? '').toString();

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
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Iconsax.briefcase, color: _blue, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textDark)),
                if (city.isNotEmpty)
                  _metaRow(Iconsax.location, city),
                if (salary.isNotEmpty)
                  _metaRow(Iconsax.money, salary),
                if (duration.isNotEmpty)
                  _metaRow(Iconsax.clock, duration),
              ]),
        ),
      ]),
    );
  }

  // ── Trips Tab ─────────────────────────────────────────────────────────────

  Widget _tripsTab() {
    if (_trips.isEmpty) return _emptyTab('No trips matched your search');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: _trips.length,
      itemBuilder: (_, i) => _tripCard(_trips[i]),
    );
  }

  Widget _tripCard(Map<String, dynamic> trip) {
    final origin = (trip['origin'] ?? trip['from'] ?? '—').toString();
    final dest = (trip['destination'] ?? trip['to'] ?? '—').toString();
    final status = (trip['status'] ?? '').toString();

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
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.directions_car_outlined,
              color: _green, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$origin → $dest',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (status.isNotEmpty)
                  _metaRow(Iconsax.status, status),
              ]),
        ),
      ]),
    );
  }

  // ── Learning Tab ──────────────────────────────────────────────────────────

  Widget _learningTab() {
    if (_learning.isEmpty) {
      return _emptyTab('No learning modules matched your search');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: _learning.length,
      itemBuilder: (_, i) => _learningCard(_learning[i]),
    );
  }

  Widget _learningCard(Map<String, dynamic> module) {
    final title = (module['title'] ?? 'Module').toString();
    final desc = (module['description'] ?? '').toString();
    final duration = (module['duration'] ?? '').toString();
    final progress = (module['progress'] ?? 0) as num;

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
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: _amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Iconsax.book, color: _amber, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (desc.isNotEmpty)
                  Text(desc,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: _textGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                if (duration.isNotEmpty)
                  _metaRow(Iconsax.clock, duration),
                if (progress > 0) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: _border,
                    valueColor:
                        const AlwaysStoppedAnimation(_amber),
                  ),
                ],
              ]),
        ),
      ]),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _metaRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(children: [
        Icon(icon, size: 12, color: _textGrey),
        const SizedBox(width: 4),
        Expanded(
            child: Text(text,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: _textGrey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _emptyTab(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(msg,
            style: GoogleFonts.poppins(
                fontSize: 14, color: _textGrey),
            textAlign: TextAlign.center),
      ),
    );
  }
}
