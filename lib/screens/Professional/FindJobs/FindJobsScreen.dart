import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:wheelboard/utils/share_service.dart';

import '../../../controllers/Professional/open_jobs_controller.dart';
import '../../../controllers/Professional/unassigned_trips_controller.dart';
import '../../../core/auth/auth_service.dart';
import '../../../models/job_model.dart';
import '../../../models/unassigned_trip_model.dart';
import '../../../theme/design_system.dart';
import '../../../widgets/custom_snackbar.dart';
import '../JobDetails/JobDetailsScreen.dart';
import '../Notification1/Notification1Screen.dart';

/// Find Jobs — modern, brand-consistent job board + open-trip board.
///
/// Mirrors the web `/professional/jobs` (search + filters + apply/save/share)
/// and keeps the app's extra "Trips" tab (open trips to bid on). Removes the old
/// nested `MaterialApp` anti-pattern and the off-brand colour soup; routes the
/// bell to the professional notifications screen. All APIs/actions preserved.
class FindJobsScreen extends StatefulWidget {
  const FindJobsScreen({super.key});

  @override
  State<FindJobsScreen> createState() => _FindJobsScreenState();
}

class _FindJobsScreenState extends State<FindJobsScreen>
    with SingleTickerProviderStateMixin {
  final tripsController = Get.put(UnassignedTripsController());
  final jobsController = Get.put(OpenJobsController());
  final _searchController = TextEditingController();

  late final TabController _tabController;
  String _jobFilter = 'All'; // All | Urgent | Saved | Applied

  static const _jobFilters = ['All', 'Urgent', 'Saved', 'Applied'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
    jobsController.fetchOpenJobs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    tripsController.searchQuery.value = _searchController.text.toLowerCase();
    setState(() {}); // re-filter jobs
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
        title: Text('Find Jobs', style: AppText.h2),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification, color: AppPalette.textDark),
            onPressed: () => Get.to(() => const Notification1Screen()),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppPalette.primary,
          unselectedLabelColor: AppPalette.textGrey,
          indicatorColor: AppPalette.primary,
          indicatorWeight: 3,
          labelStyle: AppText.subtitle,
          unselectedLabelStyle: AppText.subtitle,
          tabs: const [Tab(text: 'Jobs'), Tab(text: 'Trips')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_jobsTab(), _tripsTab()],
      ),
    );
  }

  // ── search field ──────────────────────────────────────────────────────────
  Widget _searchField(String hint) {
    return TextField(
      controller: _searchController,
      style: AppText.body.on(AppPalette.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.bodySm.on(AppPalette.textFaint),
        prefixIcon: const Icon(Iconsax.search_normal_1,
            size: 18, color: AppPalette.textGrey),
        filled: true,
        fillColor: AppPalette.card,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
    );
  }

  // ── jobs tab ────────────────────────────────────────────────────────────────
  Widget _jobsTab() {
    return RefreshIndicator(
      color: AppPalette.primary,
      onRefresh: jobsController.refreshOpenJobs,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _searchField('Search by role, company or location'),
          AppSpacing.vGapMd,
          Row(
            children: _jobFilters.map((f) {
              final sel = _jobFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => setState(() => _jobFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: sel ? AppPalette.brandGradient : null,
                      color: sel ? null : AppPalette.card,
                      borderRadius: AppRadius.rPill,
                      border: Border.all(
                          color: sel ? Colors.transparent : AppPalette.border),
                    ),
                    child: Text(f,
                        style: AppText.label
                            .on(sel ? Colors.white : AppPalette.textMid)
                            .weight(FontWeight.w600)),
                  ),
                ),
              );
            }).toList(),
          ),
          AppSpacing.vGapLg,
          Obx(() {
            if (jobsController.isLoading.value &&
                jobsController.openJobs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: AppLoading(message: 'Loading jobs…'),
              );
            }
            final jobs = _visibleJobs();
            if (jobs.isEmpty) {
              return const AppEmptyState(
                icon: Iconsax.briefcase,
                title: 'No jobs found',
                subtitle: 'Try a different search or check back later.',
              );
            }
            return Column(
              children: jobs
                  .map((j) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _jobCard(j),
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  List<JobModel> _visibleJobs() {
    var list = jobsController.openJobs.toList();
    if (_jobFilter == 'Urgent') list = list.where((j) => j.urgent).toList();
    if (_jobFilter == 'Saved') list = list.where((j) => j.isSaved).toList();
    if (_jobFilter == 'Applied') list = list.where((j) => j.isApplied).toList();
    final q = _searchController.text.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((job) {
        return job.role.toLowerCase().contains(q) ||
            job.city.toLowerCase().contains(q) ||
            job.jobType.toLowerCase().contains(q) ||
            job.description.toLowerCase().contains(q) ||
            (job.companyName ?? '').toLowerCase().contains(q);
      }).toList();
    }
    // Urgent jobs first (mirrors web /professional/jobs sort).
    list.sort((a, b) => (b.urgent ? 1 : 0).compareTo(a.urgent ? 1 : 0));
    return list;
  }

  Widget _jobCard(JobModel job) {
    return AppCard(
      onTap: () => Get.to(() => JobDetailsScreen(job: job),
          transition: Transition.cupertino),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: AppPalette.primaryLight,
                    borderRadius: AppRadius.rMd),
                child: const Icon(Iconsax.building_4,
                    color: AppPalette.primary, size: 20),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.companyName?.isNotEmpty == true
                        ? job.companyName!
                        : 'Company',
                        style: AppText.subtitle.on(AppPalette.primary)),
                    Text(job.role.isNotEmpty ? job.role : 'Job Opening',
                        style: AppText.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => jobsController.toggleSave(job.jobId),
                child: Icon(
                  job.isSaved ? Iconsax.archive_tick5 : Iconsax.archive_1,
                  color: job.isSaved ? AppPalette.primary : AppPalette.textFaint,
                  size: 22,
                ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (job.urgent)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppPalette.dangerBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Iconsax.flash_1,
                      size: 12, color: AppPalette.danger),
                  const SizedBox(width: 4),
                  Text('Urgent',
                      style: AppText.caption
                          .on(AppPalette.danger)
                          .weight(FontWeight.w700)),
                ]),
              ),
            if (job.city.isNotEmpty) _metaChip(Iconsax.location, job.city),
            _metaChip(Iconsax.money_recive,
                job.salary.isNotEmpty ? job.salary : 'Not specified'),
            if (job.jobDuration.isNotEmpty)
              _metaChip(Iconsax.clock, job.jobDuration),
            if (job.openings > 0)
              _metaChip(Iconsax.people, '${job.openings} openings'),
          ]),
          AppSpacing.vGapLg,
          Row(children: [
            Expanded(
              child: AppSecondaryButton(
                label: 'Share',
                icon: Iconsax.share,
                color: AppPalette.textMid,
                onPressed: () => ShareService.shareJob(
                  jobId: job.jobId,
                  jobTitle: job.role,
                  city: job.city,
                  jobType: job.jobType,
                  jobDuration: job.jobDuration,
                  openings: job.openings,
                  salary: job.salary,
                  description: job.description,
                ),
              ),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: AppPrimaryButton(
                label: job.isApplied ? 'Applied' : 'Apply now',
                icon: job.isApplied ? Iconsax.tick_circle : Iconsax.send_2,
                loading: jobsController.isApplying(job.jobId),
                color: job.isApplied ? AppPalette.textFaint : AppPalette.primary,
                onPressed: job.isApplied
                    ? null
                    : () async {
                        final ok = await jobsController.applyForJob(job.jobId);
                        if (ok) await jobsController.refreshOpenJobs();
                      },
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: AppPalette.bg, borderRadius: AppRadius.rPill),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppPalette.textGrey),
        const SizedBox(width: 5),
        Text(text, style: AppText.caption.on(AppPalette.textMid)),
      ]),
    );
  }

  // ── trips tab ───────────────────────────────────────────────────────────────
  Widget _tripsTab() {
    return RefreshIndicator(
      color: AppPalette.primary,
      onRefresh: () => tripsController.fetchUnassignedTrips(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _searchField('Search trips by location'),
          AppSpacing.vGapLg,
          Obx(() {
            if (tripsController.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: AppLoading(message: 'Loading trips…'),
              );
            }
            final trips = tripsController.filteredTrips;
            if (trips.isEmpty) {
              return const AppEmptyState(
                icon: Iconsax.routing,
                title: 'No open trips',
                subtitle: 'New trips you can bid on will appear here.',
              );
            }
            return Column(
              children: trips
                  .map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _tripCard(t),
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _tripCard(UnassignedTrip trip) {
    String city(String s) =>
        s.isEmpty ? 'Unknown' : (s.split(',').first.trim());
    final userId = AuthService.to.currentUserId;
    final alreadyBid = trip.hasBidFrom(userId);
    final durationText = _durationText(trip.durationSeconds);
    final payText = trip.payRange.isNotEmpty
        ? trip.payRange
        : (trip.price != null && trip.price! > 0
            ? '₹${trip.price!.round()}'
            : 'Open for Bidding');

    return AppCard(
      onTap: () => _openTripDetails(trip),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — icon, route title + distance/duration chips, bids count.
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: AppPalette.primaryLight,
                  borderRadius: AppRadius.rMd),
              child: const Icon(Iconsax.truck_fast,
                  color: AppPalette.primary, size: 20),
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
                      _metaChip(Iconsax.routing, '${trip.distanceKm!.round()} km'),
                    if (durationText != null)
                      _metaChip(Iconsax.clock, durationText),
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
          _tripRow(Iconsax.location, 'From: ${trip.pickupLocation}'),
          const SizedBox(height: 6),
          _tripRow(Iconsax.location_tick, 'To: ${trip.destination}'),
          AppSpacing.vGapMd,
          // Departure + pay row.
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
            decoration: BoxDecoration(
                color: AppPalette.bg, borderRadius: AppRadius.rMd),
            child: Row(children: [
              Expanded(
                  child: _miniStat('Departure',
                      trip.pickupDate != null
                          ? _shortDate(trip.pickupDate!)
                          : 'Flexible')),
              _vDivider(),
              Expanded(
                  child: _miniStat(
                      'Time',
                      trip.pickupTime.isNotEmpty ? trip.pickupTime : 'N/A')),
              _vDivider(),
              Expanded(
                  child: _miniStat('Pay', payText,
                      valueColor: AppPalette.green)),
            ]),
          ),
          AppSpacing.vGapMd,
          // Actions — direct Place Bid (web parity) + Details.
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
            Expanded(
              child: AppSecondaryButton(
                label: 'Details',
                icon: Iconsax.eye,
                color: AppPalette.textMid,
                onPressed: () => _openTripDetails(trip),
              ),
            ),
          ]),
        ],
      ),
    );
  }

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

  Widget _vDivider() =>
      Container(width: 1, height: 26, color: AppPalette.border);

  /// FE-parity trip details modal (mirrors the web `/professional/search`
  /// Trip Details modal): route boxes, a distance/duration/departure grid, a
  /// pay/bids panel, and a Place Bid / Bid Placed footer. Replaces the old
  /// `TripOverviewPopup`/`BidSubmissionScreen` flow.
  void _openTripDetails(UnassignedTrip trip) {
    final userId = AuthService.to.currentUserId;
    final alreadyBid = trip.hasBidFrom(userId);
    final durationText = _durationText(trip.durationSeconds) ?? 'N/A';
    final distanceText = (trip.distanceKm != null && trip.distanceKm! > 0)
        ? '${trip.distanceKm!.round()} km'
        : 'N/A';
    final payText = trip.payRange.isNotEmpty
        ? trip.payRange
        : (trip.price != null && trip.price! > 0
            ? '₹${trip.price!.round()}'
            : 'Open for Bidding');

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: const BoxDecoration(
          color: AppPalette.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gradient header.
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
                  child: const Icon(Iconsax.truck, color: Colors.white, size: 20),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trip Details',
                          style: AppText.title.on(Colors.white)),
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
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ]),
            ),
            // Scrollable body.
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
            // Footer actions.
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppPalette.border)),
              ),
              child: Row(children: [
                Expanded(
                  child: AppSecondaryButton(
                    label: 'Close',
                    onPressed: () => Get.back(),
                  ),
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

  Widget _detailLocationBox(
      Color accent, Color bg, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Iconsax.location, size: 15, color: accent),
            const SizedBox(width: 6),
            Text(label,
                style: AppText.label.on(accent).weight(FontWeight.w600)),
          ]),
          const SizedBox(height: 4),
          Text(value.isEmpty ? 'N/A' : value, style: AppText.bodySm),
        ],
      ),
    );
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

  Widget _tripRow(IconData icon, String text) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 16, color: AppPalette.textGrey),
      AppSpacing.hGapSm,
      Expanded(
          child: Text(text,
              style: AppText.bodySm,
              maxLines: 2,
              overflow: TextOverflow.ellipsis)),
    ]);
  }

  // ── bid modal (web parity: amount + notes → POST /trips/:id/bid) ───────────
  void _showBidModal(UnassignedTrip trip) {
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String city(String s) => s.isEmpty ? '—' : s.split(',').first.trim();

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              Text('Bid Amount (₹)',
                  style: AppText.label.weight(FontWeight.w600)),
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
                decoration: _bidInputDecoration(
                    'Any additional details…', Iconsax.note_1),
              ),
              AppSpacing.vGapLg,
              Row(children: [
                Expanded(
                  child: AppSecondaryButton(
                    label: 'Cancel',
                    onPressed: () => Get.back(),
                  ),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  flex: 2,
                  child: Obx(() => AppPrimaryButton(
                        label: 'Submit Bid',
                        icon: Iconsax.send_2,
                        loading: tripsController.isSubmittingBid.value,
                        onPressed: () async {
                          // Accept "5,000", "₹5000", spaces, etc. — sanitize to
                          // a plain number rather than silently failing.
                          final raw = amountCtrl.text
                              .replaceAll(RegExp(r'[^\d.]'), '');
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

  InputDecoration _bidInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppText.bodySm.on(AppPalette.textFaint),
      prefixIcon: Icon(icon, size: 18, color: AppPalette.textGrey),
      filled: true,
      fillColor: AppPalette.bg,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
