import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/Professional/open_jobs_controller.dart';
import '../../../controllers/Professional/unassigned_trips_controller.dart';
import '../../../controllers/Professional/professional_tab_controller.dart';
import '../../../core/auth/auth_service.dart';
import '../../../models/job_model.dart';
import '../../../models/unassigned_trip_model.dart';
import '../../../theme/design_system.dart';
import '../../../widgets/custom_snackbar.dart';

/// Professional "Find" screen — a 1:1 port of the web `/professional/search`
/// ("Find Opportunities") page.
///
/// Loads all open jobs + unassigned trips on entry, filters them client-side by
/// the search box, and shows them under All / Jobs / Trips tabs. Each job can be
/// applied to (with a granular application-status badge) and opened in a details
/// sheet; each trip can be bid on (or shows "Bid Placed") and opened in a details
/// sheet. No "Learning" tab and no required search — matching the web exactly.
class ProfessionalSearchScreen extends StatefulWidget {
  /// When [embedded] the screen is hosted inside the professional bottom-nav
  /// (the "Find" tab) — the back button is suppressed so it behaves like a tab.
  const ProfessionalSearchScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ProfessionalSearchScreen> createState() =>
      _ProfessionalSearchScreenState();
}

class _ProfessionalSearchScreenState extends State<ProfessionalSearchScreen> {
  final jobsController = Get.put(OpenJobsController());
  final tripsController = Get.put(UnassignedTripsController());
  final _searchCtrl = TextEditingController();

  late final ProfessionalTabController _tab;
  Worker? _tabWorker;

  String _query = '';
  String _activeTab = 'All'; // All | Jobs | Trips

  static const _tabs = ['All', 'Jobs', 'Trips'];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.toLowerCase().trim());
    });

    _tab = Get.isRegistered<ProfessionalTabController>()
        ? Get.find<ProfessionalTabController>()
        : Get.put(ProfessionalTabController(), permanent: true);

    // This screen lives inside the bottom-nav IndexedStack, so it is built once
    // and its first fetch can fire before auth/token is ready — then never
    // retries, leaving the page blank. Reloading whenever the Find tab becomes
    // active guarantees fresh data the moment the user looks at it.
    _tabWorker = ever<int>(_tab.currentIndex, (i) {
      if (i == ProfessionalTabController.find) _loadAll();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  @override
  void dispose() {
    _tabWorker?.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _isReloading = false;

  Future<void> _loadAll() async {
    if (_isReloading) return;
    _isReloading = true;
    try {
      await Future.wait([
        jobsController
            .fetchOpenJobs(filters: {'status': 'Active', 'limit': 100}),
        tripsController.fetchUnassignedTrips(),
        jobsController.fetchMyApplicationStatuses(),
      ]);
    } finally {
      _isReloading = false;
    }
  }

  // ── Client-side filtering (web parity) ──────────────────────────────────────
  List<JobModel> get _filteredJobs {
    final q = _query;
    if (q.isEmpty) return jobsController.openJobs.toList();
    return jobsController.openJobs.where((job) {
      return job.title.toLowerCase().contains(q) ||
          job.employerName.toLowerCase().contains(q) ||
          job.city.toLowerCase().contains(q) ||
          job.description.toLowerCase().contains(q);
    }).toList();
  }

  List<UnassignedTrip> get _filteredTrips {
    final q = _query;
    if (q.isEmpty) return tripsController.unassignedTrips.toList();
    return tripsController.unassignedTrips.where((trip) {
      return trip.pickupLocation.toLowerCase().contains(q) ||
          trip.destination.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        backgroundColor: AppPalette.card,
        elevation: 0.5,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppPalette.textDark, size: 20),
                onPressed: () => Get.back(),
              ),
        title: Text('Find Opportunities', style: AppText.h2),
      ),
      body: Column(
        children: [
          // Search + filters + tab pills (pinned header — web parity).
          Container(
            color: AppPalette.card,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: _searchField()),
                  AppSpacing.hGapMd,
                  _filtersButton(),
                ]),
                AppSpacing.vGapMd,
                Row(
                  children: _tabs.map((t) {
                    final sel = _activeTab == t;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: t == _tabs.last ? 0 : AppSpacing.sm),
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              gradient: sel ? AppPalette.brandGradient : null,
                              color: sel ? null : AppPalette.bg,
                              borderRadius: AppRadius.rPill,
                              border: Border.all(
                                  color: sel
                                      ? Colors.transparent
                                      : AppPalette.border),
                            ),
                            child: Text(t,
                                style: AppText.label
                                    .on(sel ? Colors.white : AppPalette.textMid)
                                    .weight(FontWeight.w600)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppPalette.primary,
              onRefresh: _loadAll,
              child: Obx(() {
                final loading = jobsController.isLoading.value ||
                    tripsController.isLoading.value;
                final results = _buildResults();

                if (loading &&
                    jobsController.openJobs.isEmpty &&
                    tripsController.unassignedTrips.isEmpty) {
                  return ListView(children: const [
                    SizedBox(height: 120),
                    AppLoading(message: 'Loading opportunities…'),
                  ]);
                }

                if (results.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      AppEmptyState(
                        icon: Iconsax.search_normal_1,
                        title: 'No results found',
                        subtitle: _query.isEmpty
                            ? 'New jobs and trips will appear here.'
                            : 'Nothing matched "$_query"',
                      ),
                      if (_query.isNotEmpty)
                        Center(
                          child: TextButton(
                            onPressed: () => _searchCtrl.clear(),
                            child: Text('Clear search',
                                style: AppText.label.on(AppPalette.primary)),
                          ),
                        )
                      else
                        Center(
                          child: TextButton.icon(
                            onPressed: _loadAll,
                            icon: const Icon(Iconsax.refresh,
                                size: 16, color: AppPalette.primary),
                            label: Text('Retry',
                                style: AppText.label.on(AppPalette.primary)),
                          ),
                        ),
                    ],
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: results.length,
                  itemBuilder: (_, i) {
                    final item = results[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: item is JobModel ? _jobCard(item) : _tripCard(item as UnassignedTrip),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the active tab's result list. "All" interleaves jobs and trips so
  /// the user sees a mix (web parity).
  List<Object> _buildResults() {
    final jobs = _filteredJobs;
    final trips = _filteredTrips;
    if (_activeTab == 'Jobs') return jobs;
    if (_activeTab == 'Trips') return trips;
    final combined = <Object>[];
    final maxLen = jobs.length > trips.length ? jobs.length : trips.length;
    for (var i = 0; i < maxLen; i++) {
      if (i < jobs.length) combined.add(jobs[i]);
      if (i < trips.length) combined.add(trips[i]);
    }
    return combined;
  }

  Widget _searchField() {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: _searchCtrl,
        style: AppText.body.on(AppPalette.textDark),
        decoration: InputDecoration(
          hintText: 'Search by title, location, or company…',
          hintStyle: AppText.bodySm.on(AppPalette.textFaint),
          prefixIcon: const Icon(Iconsax.search_normal_1,
              size: 18, color: AppPalette.textGrey),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close,
                      size: 18, color: AppPalette.textGrey),
                  onPressed: () => _searchCtrl.clear(),
                ),
          filled: true,
          fillColor: AppPalette.bg,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
              borderRadius: AppRadius.rLg,
              borderSide: const BorderSide(color: AppPalette.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.rLg,
              borderSide: const BorderSide(color: AppPalette.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.rLg,
              borderSide: const BorderSide(color: AppPalette.primary)),
        ),
      ),
    );
  }

  Widget _filtersButton() {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: AppPalette.bg,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppPalette.border),
      ),
      child: const Icon(Iconsax.setting_4, size: 20, color: AppPalette.textMid),
    );
  }

  // ── Job card (web parity) ───────────────────────────────────────────────────
  Widget _jobCard(JobModel job) {
    final status = jobsController.applicationStatus[job.id];
    return AppCard(
      onTap: () => _openJobDetails(job),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppPalette.primaryLight, borderRadius: AppRadius.rMd),
              child:
                  const Icon(Iconsax.building_4, color: AppPalette.primary, size: 22),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.title.isNotEmpty ? job.title : 'Job Opening',
                      style: AppText.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (job.employerName.isNotEmpty)
                    Text(job.employerName,
                        style: AppText.bodySm.on(AppPalette.textGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (job.urgent)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: AppPalette.dangerBg,
                    borderRadius: BorderRadius.circular(6)),
                child: Text('URGENT',
                    style: AppText.micro
                        .on(AppPalette.danger)
                        .weight(FontWeight.w700)),
              ),
          ]),
          AppSpacing.vGapMd,
          if (job.city.isNotEmpty) _metaRow(Iconsax.location, job.city),
          if (job.type.isNotEmpty) _metaRow(Iconsax.briefcase, job.type),
          _metaRow(Iconsax.money_recive,
              job.salary.isNotEmpty ? job.salary : 'Not specified',
              valueColor: AppPalette.green),
          AppSpacing.vGapMd,
          Row(children: [
            Expanded(
              child: status != null
                  ? _statusBadge(status)
                  : AppPrimaryButton(
                      label: 'Apply Now',
                      icon: Iconsax.send_2,
                      loading: jobsController.isApplying(job.jobId),
                      onPressed: () => _applyToJob(job),
                    ),
            ),
            AppSpacing.hGapMd,
            AppSecondaryButton(
              label: 'Details',
              color: AppPalette.textMid,
              expand: false,
              onPressed: () => _openJobDetails(job),
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _applyToJob(JobModel job) async {
    if (jobsController.applicationStatus.containsKey(job.id)) return;
    await jobsController.applyForJob(
      job.jobId,
      experience: 'See profile',
      availability: 'Available per calendar',
    );
  }

  /// Granular application-status pill, mirroring the web `getStatusBadge`.
  Widget _statusBadge(String status) {
    late final Color color;
    late final String label;
    switch (status) {
      case 'reviewed':
        color = const Color(0xFF3B82F6);
        label = 'Viewed';
        break;
      case 'shortlisted':
        color = const Color(0xFF8B5CF6);
        label = 'Shortlisted';
        break;
      case 'hired':
        color = const Color(0xFFF59E0B);
        label = 'Hired';
        break;
      case 'rejected':
        color = AppPalette.danger;
        label = 'Rejected';
        break;
      case 'pending':
      default:
        color = AppPalette.green;
        label = 'Applied';
    }
    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.rMd),
      child: Text(label,
          style: AppText.label.on(Colors.white).weight(FontWeight.w700)),
    );
  }

  // ── Trip card (web parity — same shape as FindJobs Trips tab) ───────────────
  Widget _tripCard(UnassignedTrip trip) {
    String city(String s) => s.isEmpty ? 'Unknown' : s.split(',').first.trim();
    final userId = AuthService.to.currentUserId;
    final alreadyBid = trip.hasBidFrom(userId);
    final durationText = _durationText(trip.durationSeconds);
    final payText = _payText(trip);

    return AppCard(
      onTap: () => _openTripDetails(trip),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppPalette.primaryLight, borderRadius: AppRadius.rMd),
              child: const Icon(Iconsax.truck_fast,
                  color: AppPalette.primary, size: 22),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${city(trip.pickupLocation)} → ${city(trip.destination)}',
                      style: AppText.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 6, children: [
                    if (trip.distanceKm != null && trip.distanceKm! > 0)
                      _chip(Iconsax.routing, '${trip.distanceKm!.round()} km'),
                    if (durationText != null) _chip(Iconsax.clock, durationText),
                  ]),
                ],
              ),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Bids', style: AppText.micro.size(10)),
              Text('${trip.bidsCount}',
                  style: AppText.h2.on(AppPalette.textDark).size(20)),
            ]),
          ]),
          AppSpacing.vGapMd,
          _routeRow(AppPalette.green, 'Pickup', trip.pickupLocation),
          const SizedBox(height: 8),
          _routeRow(AppPalette.danger, 'Delivery', trip.destination),
          AppSpacing.vGapMd,
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
            decoration:
                BoxDecoration(color: AppPalette.bg, borderRadius: AppRadius.rMd),
            child: Row(children: [
              Expanded(
                  child: _miniStat(
                      'Departure',
                      trip.pickupDate != null
                          ? _shortDate(trip.pickupDate!)
                          : 'Flexible')),
              _vDivider(),
              Expanded(
                  child: _miniStat('Time',
                      trip.pickupTime.isNotEmpty ? trip.pickupTime : 'N/A')),
              _vDivider(),
              Expanded(
                  child: _miniStat('Pay', payText, valueColor: AppPalette.green)),
            ]),
          ),
          AppSpacing.vGapMd,
          Row(children: [
            Expanded(
              child: alreadyBid
                  ? AppPrimaryButton(
                      label: 'Bid Placed',
                      icon: Iconsax.tick_circle,
                      color: AppPalette.green,
                      onPressed: null,
                    )
                  : AppPrimaryButton(
                      label: 'Place Bid',
                      icon: Iconsax.money_recive,
                      onPressed: () => _showBidModal(trip),
                    ),
            ),
            AppSpacing.hGapMd,
            AppSecondaryButton(
              label: 'Details',
              color: AppPalette.textMid,
              expand: false,
              onPressed: () => _openTripDetails(trip),
            ),
          ]),
        ],
      ),
    );
  }

  // ── Job details sheet (web parity Job Details modal) ────────────────────────
  void _openJobDetails(JobModel job) {
    final status = jobsController.applicationStatus[job.id];
    Get.bottomSheet(
      Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: const BoxDecoration(
          color: AppPalette.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppPalette.border)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                      gradient: AppPalette.brandGradient,
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child:
                      const Icon(Iconsax.building_4, color: Colors.white, size: 22),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title,
                          style: AppText.h2,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      if (job.employerName.isNotEmpty)
                        Text(job.employerName,
                            style: AppText.bodySm.on(AppPalette.textGrey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppPalette.textGrey),
                  onPressed: () => Get.back(),
                ),
              ]),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      if (job.urgent)
                        _detailTag('🔥 URGENT', AppPalette.dangerBg,
                            AppPalette.danger),
                      if (job.type.isNotEmpty)
                        _detailTag(job.type, AppPalette.primaryLight,
                            AppPalette.primary),
                      if (job.city.isNotEmpty)
                        _detailTag(
                            job.location.isNotEmpty
                                ? '${job.location} (${job.city})'
                                : job.city,
                            AppPalette.bg,
                            AppPalette.textMid),
                      if (job.salary.isNotEmpty)
                        _detailTag(job.salary, AppPalette.greenBg,
                            AppPalette.green),
                    ]),
                    AppSpacing.vGapLg,
                    if (job.description.isNotEmpty) ...[
                      Text('Job Description',
                          style: AppText.title.on(AppPalette.textDark)),
                      AppSpacing.vGapSm,
                      Text(job.description, style: AppText.bodySm),
                      AppSpacing.vGapLg,
                    ],
                    if (job.requirements.isNotEmpty) ...[
                      Text('Requirements',
                          style: AppText.title.on(AppPalette.textDark)),
                      AppSpacing.vGapSm,
                      ...job.requirements.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6, right: 8),
                                    child: Icon(Icons.circle,
                                        size: 6, color: AppPalette.textGrey),
                                  ),
                                  Expanded(
                                      child: Text(r, style: AppText.bodySm)),
                                ]),
                          )),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppPalette.border)),
              ),
              child: Row(children: [
                Expanded(
                  child: AppSecondaryButton(
                      label: 'Close', onPressed: () => Get.back()),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  flex: 2,
                  child: status != null
                      ? _statusBadge(status)
                      : Obx(() => AppPrimaryButton(
                            label: 'Apply for this Job',
                            icon: Iconsax.send_2,
                            loading: jobsController.isApplying(job.jobId),
                            onPressed: () async {
                              Get.back();
                              await _applyToJob(job);
                            },
                          )),
                ),
              ]),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ── Trip details sheet (web parity Trip Details modal) ──────────────────────
  void _openTripDetails(UnassignedTrip trip) {
    final userId = AuthService.to.currentUserId;
    final alreadyBid = trip.hasBidFrom(userId);
    final durationText = _durationText(trip.durationSeconds) ?? 'N/A';
    final distanceText = (trip.distanceKm != null && trip.distanceKm! > 0)
        ? '${trip.distanceKm!.round()} km'
        : 'N/A';
    final payText = _payText(trip);

    Get.bottomSheet(
      Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: const BoxDecoration(
          color: AppPalette.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppPalette.brandGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: AppRadius.rMd),
                  child:
                      const Icon(Iconsax.truck, color: Colors.white, size: 20),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trip Details', style: AppText.title.on(Colors.white)),
                      Text(trip.tripCode.isNotEmpty ? trip.tripCode : trip.tripId,
                          style: AppText.caption
                              .on(Colors.white.withValues(alpha: 0.85)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: AppRadius.rMd),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ]),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailLocationBox(AppPalette.green, AppPalette.greenBg,
                        'Pickup Location', trip.pickupLocation),
                    AppSpacing.vGapMd,
                    _detailLocationBox(AppPalette.danger, AppPalette.dangerBg,
                        'Delivery Location', trip.destination),
                    AppSpacing.vGapMd,
                    Row(children: [
                      Expanded(child: _statBox('Distance', distanceText)),
                      AppSpacing.hGapMd,
                      Expanded(child: _statBox('Duration', durationText)),
                    ]),
                    AppSpacing.vGapMd,
                    Row(children: [
                      Expanded(
                          child: _statBox(
                              'Departure Date',
                              trip.pickupDate != null
                                  ? _shortDate(trip.pickupDate!)
                                  : 'Flexible')),
                      AppSpacing.hGapMd,
                      Expanded(
                          child: _statBox(
                              'Departure Time',
                              trip.pickupTime.isNotEmpty
                                  ? trip.pickupTime
                                  : 'N/A')),
                    ]),
                    AppSpacing.vGapMd,
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                          color: AppPalette.greenBg,
                          borderRadius: AppRadius.rLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  trip.bidsCount > 0
                                      ? 'Current Bids'
                                      : 'Expected Pay',
                                  style: AppText.label
                                      .on(AppPalette.green)
                                      .weight(FontWeight.w600)),
                              Text('${trip.bidsCount} bids placed',
                                  style: AppText.caption),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(payText,
                              style: AppText.h2.on(AppPalette.green).size(22)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppPalette.border)),
              ),
              child: Row(children: [
                Expanded(
                  child: AppSecondaryButton(
                      label: 'Close', onPressed: () => Get.back()),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  flex: 2,
                  child: alreadyBid
                      ? AppPrimaryButton(
                          label: 'Bid Placed',
                          icon: Iconsax.tick_circle,
                          color: AppPalette.green,
                          onPressed: null,
                        )
                      : AppPrimaryButton(
                          label: 'Place Bid',
                          icon: Iconsax.money_recive,
                          onPressed: () {
                            Get.back();
                            _showBidModal(trip);
                          },
                        ),
                ),
              ]),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ── Bid modal (amount + notes → POST /trips/:id/bid) ────────────────────────
  void _showBidModal(UnassignedTrip trip) {
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String city(String s) => s.isEmpty ? '—' : s.split(',').first.trim();

    Get.bottomSheet(
      Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppPalette.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppPalette.border,
                        borderRadius: AppRadius.rPill)),
              ),
              AppSpacing.vGapLg,
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Place Bid', style: AppText.h2),
                      Text(
                          '${city(trip.pickupLocation)} → ${city(trip.destination)}',
                          style: AppText.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppPalette.textGrey),
                  onPressed: () => Get.back(),
                ),
              ]),
              AppSpacing.vGapLg,
              Text('Bid Amount (₹)', style: AppText.label.weight(FontWeight.w600)),
              AppSpacing.vGapSm,
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: AppText.body.on(AppPalette.textDark),
                decoration: _bidInputDecoration(
                    'Enter your bid amount', Iconsax.money_recive),
              ),
              AppSpacing.vGapMd,
              Text('Notes (optional)',
                  style: AppText.label.weight(FontWeight.w600)),
              AppSpacing.vGapSm,
              TextField(
                controller: notesCtrl,
                maxLines: 3,
                style: AppText.body.on(AppPalette.textDark),
                decoration:
                    _bidInputDecoration('Any additional details…', Iconsax.note_1),
              ),
              AppSpacing.vGapLg,
              Row(children: [
                Expanded(
                  child: AppSecondaryButton(
                      label: 'Cancel', onPressed: () => Get.back()),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  flex: 2,
                  child: Obx(() => AppPrimaryButton(
                        label: 'Submit Bid',
                        icon: Iconsax.send_2,
                        loading: tripsController.isSubmittingBid.value,
                        onPressed: () async {
                          final raw =
                              amountCtrl.text.replaceAll(RegExp(r'[^\d.]'), '');
                          final amount = double.tryParse(raw);
                          if (amount == null || amount <= 0) {
                            SnackBarHelper.error(
                                'Please enter a valid bid amount');
                            return;
                          }
                          final ok = await tripsController.submitBid(
                            tripId: trip.tripId,
                            bidAmount: amount,
                            bidDescription: notesCtrl.text.trim(),
                          );
                          if (ok) {
                            Get.back();
                            await tripsController.fetchUnassignedTrips();
                          }
                        },
                      )),
                ),
              ]),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ── Small shared helpers ────────────────────────────────────────────────────
  String _payText(UnassignedTrip trip) => trip.payRange.isNotEmpty
      ? trip.payRange
      : (trip.price != null && trip.price! > 0
          ? '₹${trip.price!.round()}'
          : 'Open for Bidding');

  Widget _metaRow(IconData icon, String text, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: AppPalette.textGrey),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: AppText.bodySm.on(valueColor ?? AppPalette.textMid),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: AppPalette.bg, borderRadius: AppRadius.rPill),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: AppPalette.textGrey),
        const SizedBox(width: 4),
        Text(text, style: AppText.micro.on(AppPalette.textMid)),
      ]),
    );
  }

  Widget _detailTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rPill),
      child: Text(text,
          style: AppText.caption.on(fg).weight(FontWeight.w600)),
    );
  }

  Widget _routeRow(Color dot, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppText.micro.size(10)),
          Text(value.isEmpty ? 'N/A' : value,
              style: AppText.bodySm.weight(FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ]),
      ),
    ]);
  }

  Widget _miniStat(String label, String value, {Color? valueColor}) {
    return Column(children: [
      Text(label, style: AppText.micro.size(10)),
      const SizedBox(height: 2),
      Text(value,
          style: AppText.label
              .on(valueColor ?? AppPalette.textDark)
              .weight(FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center),
    ]);
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration:
          BoxDecoration(color: AppPalette.bg, borderRadius: AppRadius.rLg),
      child: Column(children: [
        Text(label, style: AppText.micro.size(10)),
        const SizedBox(height: 2),
        Text(value,
            style: AppText.title.on(AppPalette.textDark).size(16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _detailLocationBox(
      Color accent, Color bg, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rLg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Iconsax.location, size: 15, color: accent),
          const SizedBox(width: 6),
          Text(label, style: AppText.label.on(accent).weight(FontWeight.w600)),
        ]),
        const SizedBox(height: 4),
        Text(value.isEmpty ? 'N/A' : value, style: AppText.bodySm),
      ]),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 26, color: AppPalette.border);

  String? _durationText(int? seconds) {
    if (seconds == null || seconds <= 0) return null;
    final m = (seconds / 60).round();
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem > 0 ? '${h}h ${rem}m' : '${h}h';
  }

  String _shortDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final local = d.toLocal();
    return '${local.day} ${months[local.month - 1]}';
  }

  InputDecoration _bidInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppText.bodySm.on(AppPalette.textFaint),
      prefixIcon: Icon(icon, size: 18, color: AppPalette.textGrey),
      filled: true,
      fillColor: AppPalette.bg,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
          borderRadius: AppRadius.rLg,
          borderSide: const BorderSide(color: AppPalette.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.rLg,
          borderSide: const BorderSide(color: AppPalette.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.rLg,
          borderSide: const BorderSide(color: AppPalette.primary)),
    );
  }
}
