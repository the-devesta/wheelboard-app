import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/job_application_model.dart';
import '../../../models/job_model.dart';
import '../../../theme/design_system.dart';

/// Job details — brand design system. Shows job info, description and (if the
/// professional has applied) the application status + details.
class JobDetailsScreen extends StatelessWidget {
  final JobModel job;

  const JobDetailsScreen({super.key, required this.job});

  JobApplication? get _app => job.myApplication;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110,
            pinned: true,
            elevation: 0,
            backgroundColor: AppPalette.primary,
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text('Job Details', style: AppText.h3.on(Colors.white)),
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppPalette.brandGradient),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerCard(),
                  if (_hasJobInfo(job)) ...[
                    AppSpacing.vGapXl,
                    _sectionTitle('Job Information', Iconsax.briefcase),
                    AppSpacing.vGapMd,
                    AppCard(child: Column(children: _jobInfoRows())),
                  ],
                  if (job.description.isNotEmpty) ...[
                    AppSpacing.vGapXl,
                    _sectionTitle('Description', Iconsax.document_text),
                    AppSpacing.vGapMd,
                    AppCard(
                      child: Text(job.description,
                          style: AppText.body.copyWith(height: 1.6)),
                    ),
                  ],
                  if (_hasApplicationInfo(job)) ...[
                    AppSpacing.vGapXl,
                    _sectionTitle('Application Details', Iconsax.task_square),
                    AppSpacing.vGapMd,
                    AppCard(child: Column(children: _applicationInfoRows())),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title.isNotEmpty ? job.title : 'Job Opening',
                    style: AppText.h1.on(AppPalette.primary).size(22)),
                if (job.city.isNotEmpty) ...[
                  AppSpacing.vGapSm,
                  Row(children: [
                    const Icon(Iconsax.location,
                        size: 15, color: AppPalette.textGrey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(job.city, style: AppText.bodySm)),
                  ]),
                ],
              ],
            ),
          ),
          AppSpacing.hGapMd,
          _statusBadge(),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    final status = _app?.status ?? '';
    late Color bg;
    late IconData icon;
    switch (status) {
      case 'hired':
        bg = AppPalette.green;
        icon = Iconsax.tick_circle;
        break;
      case 'rejected':
        bg = AppPalette.danger;
        icon = Iconsax.close_circle;
        break;
      case 'shortlisted':
        bg = AppPalette.purple;
        icon = Iconsax.star1;
        break;
      case 'reviewed':
        bg = AppPalette.blue;
        icon = Iconsax.eye;
        break;
      default:
        bg = AppPalette.amber;
        icon = Iconsax.clock;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rPill),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: Colors.white),
        const SizedBox(width: 6),
        Text(_app?.statusLabel ?? 'Applied',
            style: AppText.label.on(Colors.white).weight(FontWeight.w600)),
      ]),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 19, color: AppPalette.primary),
      AppSpacing.hGapSm,
      Text(title, style: AppText.h3),
    ]);
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppPalette.primaryLight, borderRadius: AppRadius.rSm),
          child: Icon(icon, size: 17, color: AppPalette.primary),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.label),
              const SizedBox(height: 2),
              Text(value,
                  style: AppText.subtitle.on(AppPalette.textDark).size(14)),
            ],
          ),
        ),
      ]),
    );
  }

  bool _hasJobInfo(JobModel job) =>
      job.title.isNotEmpty ||
      job.jobDuration.isNotEmpty ||
      job.city.isNotEmpty ||
      job.salary.isNotEmpty;

  bool _hasApplicationInfo(JobModel job) {
    final app = job.myApplication;
    if (app == null) return false;
    return app.appliedDateFormatted.isNotEmpty ||
        app.status.isNotEmpty ||
        (app.expectedSalary ?? '').isNotEmpty ||
        (app.notes ?? app.coverLetter ?? '').isNotEmpty;
  }

  List<Widget> _jobInfoRows() {
    final rows = <Widget>[];
    if (job.title.isNotEmpty) {
      rows.add(_infoRow('Job Role', job.title, Iconsax.briefcase));
    }
    if (job.city.isNotEmpty) {
      rows.add(_infoRow('Location', job.city, Iconsax.location));
    }
    if (job.jobDuration.isNotEmpty) {
      rows.add(_infoRow('Duration', job.jobDuration, Iconsax.clock));
    }
    if (job.salary.isNotEmpty) {
      rows.add(_infoRow('Salary', job.salary, Iconsax.money_recive));
    }
    return _trimLast(rows);
  }

  List<Widget> _applicationInfoRows() {
    final rows = <Widget>[];
    final app = _app;
    if (app == null) return rows;
    if (app.appliedDateFormatted.isNotEmpty) {
      rows.add(
          _infoRow('Applied Date', app.appliedDateFormatted, Iconsax.calendar_1));
    }
    if (app.status.isNotEmpty) {
      rows.add(_infoRow('Status', app.statusLabel, Iconsax.info_circle));
    }
    if ((app.expectedSalary ?? '').isNotEmpty) {
      rows.add(_infoRow(
          'Salary Expectation', app.expectedSalary!, Iconsax.money_recive));
    }
    final remarks = app.notes ?? app.coverLetter ?? '';
    if (remarks.isNotEmpty) {
      rows.add(_infoRow('Remarks', remarks, Iconsax.note_1));
    }
    return _trimLast(rows);
  }

  /// Removes the trailing bottom padding from the last info row.
  List<Widget> _trimLast(List<Widget> rows) {
    if (rows.isNotEmpty) {
      rows[rows.length - 1] =
          Padding(padding: EdgeInsets.zero, child: rows.last);
    }
    return rows;
  }
}
