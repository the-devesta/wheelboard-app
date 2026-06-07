import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/Professional/job_progress_controller.dart';
import '../../../models/job_model.dart';
import '../../../theme/design_system.dart';
import '../JobDetails/JobDetailsScreen.dart';

/// Job Progress — the professional's applied + saved jobs with search & status
/// filter. Modernized to the brand design system; all controller calls/APIs
/// preserved.
class JobProgressScreen extends StatelessWidget {
  const JobProgressScreen({super.key});

  static const _statusFilters = [
    'All', 'pending', 'reviewed', 'shortlisted', 'rejected', 'hired'
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JobProgressController());

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed('/professional-home');
        }
      },
      child: Scaffold(
        backgroundColor: AppPalette.bg,
        appBar: AppBar(
          backgroundColor: AppPalette.card,
          elevation: 0.5,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Text('Job Progress', style: AppText.h2),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('My Applied Jobs', style: AppText.h3),
            const SizedBox(height: 2),
            Text('Track your job application status', style: AppText.caption),
            AppSpacing.vGapMd,
            _searchAndFilter(controller),
            AppSpacing.vGapLg,
            Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                    padding: EdgeInsets.all(40), child: AppLoading());
              }
              final jobs = controller.filteredAppliedJobs;
              if (jobs.isEmpty) {
                final filtering = controller.searchQuery.value.isNotEmpty ||
                    controller.selectedFilter.value != 'All';
                return AppEmptyState(
                  icon: Iconsax.briefcase,
                  title: filtering ? 'No jobs found' : 'No applied jobs yet',
                  subtitle: filtering
                      ? 'Try adjusting your search or filter.'
                      : 'Apply for jobs to see them here.',
                );
              }
              return Column(
                children: jobs.map((j) => _AppliedJobCard(job: j)).toList(),
              );
            }),
            AppSpacing.vGapXl,
            Text('My Saved Jobs', style: AppText.h3),
            AppSpacing.vGapMd,
            Obx(() {
              if (controller.isSavedLoading.value) {
                return const Padding(
                    padding: EdgeInsets.all(20), child: AppLoading());
              }
              if (controller.savedJobs.isEmpty) {
                return const AppEmptyState(
                  icon: Iconsax.archive_1,
                  title: 'No saved jobs yet',
                  subtitle: 'Bookmark jobs to find them here later.',
                );
              }
              return Column(
                children: controller.savedJobs
                    .map((j) => _AppliedJobCard(
                          job: j,
                          onUnsave: () => controller.unsaveJob(j.id),
                        ))
                    .toList(),
              );
            }),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _searchAndFilter(JobProgressController controller) {
    return Row(children: [
      Expanded(
        child: TextField(
          onChanged: controller.updateSearchQuery,
          style: AppText.body.on(AppPalette.textDark),
          decoration: InputDecoration(
            prefixIcon: const Icon(Iconsax.search_normal_1,
                size: 18, color: AppPalette.textGrey),
            hintText: 'Search jobs…',
            hintStyle: AppText.bodySm.on(AppPalette.textFaint),
            filled: true,
            fillColor: AppPalette.card,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
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
      ),
      AppSpacing.hGapSm,
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: AppPalette.card,
            borderRadius: AppRadius.rLg,
            border: Border.all(color: AppPalette.border)),
        child: Obx(() => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedFilter.value,
                icon: const Icon(Iconsax.arrow_down_1,
                    size: 16, color: AppPalette.textGrey),
                style: AppText.bodySm.on(AppPalette.textDark),
                items: _statusFilters
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v == 'All'
                              ? 'All'
                              : v[0].toUpperCase() + v.substring(1)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) controller.updateFilter(v);
                },
              ),
            )),
      ),
    ]);
  }
}

class _AppliedJobCard extends StatelessWidget {
  final JobModel job;

  /// When provided this card represents a *saved* job and shows a remove action
  /// instead of the application status badge.
  final VoidCallback? onUnsave;

  const _AppliedJobCard({required this.job, this.onUnsave});

  ({Color bg, Color fg, String label}) _status() {
    final app = job.myApplication;
    final s = app?.status ?? '';
    switch (s) {
      case 'hired':
        return (bg: AppPalette.greenBg, fg: AppPalette.green, label: app!.statusLabel);
      case 'rejected':
        return (bg: AppPalette.dangerBg, fg: AppPalette.danger, label: app!.statusLabel);
      case 'shortlisted':
        return (bg: const Color(0xFFEDE9FE), fg: AppPalette.purple, label: app!.statusLabel);
      case 'reviewed':
        return (bg: AppPalette.blueBg, fg: AppPalette.blue, label: app!.statusLabel);
      default:
        return (bg: AppPalette.amberBg, fg: AppPalette.amber, label: app?.statusLabel ?? 'Applied');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = job.myApplication;
    final st = _status();
    final title = job.title.isNotEmpty
        ? (job.city.isNotEmpty ? '${job.title} - ${job.city}' : job.title)
        : (job.description.isNotEmpty ? job.description : 'Job');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        onTap: () => Get.to(() => JobDetailsScreen(job: job),
            transition: Transition.cupertino),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppText.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if ((job.type.isNotEmpty ? job.type : job.city).isNotEmpty)
                    Text(job.type.isNotEmpty ? job.type : job.city,
                        style: AppText.caption),
                  if (job.salary.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(job.salary,
                        style: AppText.bodySm.weight(FontWeight.w500)),
                  ],
                  if (app?.appliedDateFormatted.isNotEmpty ?? false) ...[
                    const SizedBox(height: 6),
                    Text('Applied on ${app!.appliedDateFormatted}',
                        style: AppText.caption),
                  ],
                ],
              ),
            ),
            AppSpacing.hGapSm,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (onUnsave != null)
                  GestureDetector(
                    onTap: onUnsave,
                    child: const Icon(Iconsax.archive_minus,
                        color: AppPalette.danger, size: 22),
                  )
                else if (app != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: st.bg, borderRadius: AppRadius.rPill),
                    child: Text(st.label,
                        style: AppText.micro.on(st.fg).weight(FontWeight.w600)),
                  ),
                AppSpacing.vGapSm,
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('View Details',
                      style: AppText.caption
                          .on(AppPalette.primary)
                          .weight(FontWeight.w600)),
                  const Icon(Iconsax.arrow_right_3,
                      size: 13, color: AppPalette.primary),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
