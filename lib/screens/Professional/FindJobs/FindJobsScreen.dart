import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:wheelboard/utils/share_service.dart';

import '../../../controllers/Professional/open_jobs_controller.dart';
import '../../../controllers/Professional/unassigned_trips_controller.dart';
import '../../../models/job_model.dart';
import '../../../models/unassigned_trip_model.dart';
import '../../../theme/design_system.dart';
import '../JobDetails/JobDetailsScreen.dart';
import '../Notification1/Notification1Screen.dart';
import '../TripOverview/TripOverviewScreen.dart';

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
  String _jobFilter = 'All'; // All | Saved | Applied

  static const _jobFilters = ['All', 'Saved', 'Applied'];

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
    if (_jobFilter == 'Saved') list = list.where((j) => j.isSaved).toList();
    if (_jobFilter == 'Applied') list = list.where((j) => j.isApplied).toList();
    final q = _searchController.text.toLowerCase().trim();
    if (q.isEmpty) return list;
    return list.where((job) {
      return job.role.toLowerCase().contains(q) ||
          job.city.toLowerCase().contains(q) ||
          job.jobType.toLowerCase().contains(q) ||
          job.description.toLowerCase().contains(q) ||
          (job.companyName ?? '').toLowerCase().contains(q);
    }).toList();
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
    String loc(String s) =>
        s.isEmpty ? 'Unknown' : (s.split(',').first.trim());
    return AppCard(
      onTap: () async {
        await tripsController.fetchTripDetails(trip.tripId);
        final details = tripsController.tripDetails.value;
        if (details != null && mounted) {
          TripOverviewPopup.show(context,
              tripId: trip.tripId, tripDetails: details);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text('Trip to ${loc(trip.destination)}',
                  style: AppText.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppPalette.primaryLight,
                  borderRadius: AppRadius.rPill),
              child: Text(trip.tripType,
                  style: AppText.micro.on(AppPalette.primary).size(10)),
            ),
          ]),
          AppSpacing.vGapMd,
          _tripRow(Iconsax.location, 'From: ${loc(trip.pickupLocation)}'),
          const SizedBox(height: 6),
          _tripRow(Iconsax.location_tick, 'To: ${loc(trip.destination)}'),
          const SizedBox(height: 6),
          _tripRow(Iconsax.money_recive,
              trip.payRange.isNotEmpty ? 'Pay: ${trip.payRange}' : 'Pay: N/A'),
          AppSpacing.vGapMd,
          AppPrimaryButton(
            label: 'View Details',
            icon: Iconsax.eye,
            onPressed: () async {
              await tripsController.fetchTripDetails(trip.tripId);
              final details = tripsController.tripDetails.value;
              if (details != null && mounted) {
                TripOverviewPopup.show(context,
                    tripId: trip.tripId, tripDetails: details);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _tripRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 16, color: AppPalette.textGrey),
      AppSpacing.hGapSm,
      Expanded(child: Text(text, style: AppText.bodySm)),
    ]);
  }
}
