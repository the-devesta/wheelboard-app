import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceDashboardScreen extends StatelessWidget {
  const ServiceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      const ServiceCardData(
        title: 'Tyre Replacement',
        subtitle: 'Professional tyre replacement service for all vehicle types',
        tag: 'Tyre Repair',
        tagColor: Color(0xFFDBEAFE),
        tagTextColor: Color(0xFF1E40AF),
        meta: 'Updated 2 days ago',
      ),
      const ServiceCardData(
        title: 'Engine Diagnostics',
        subtitle: 'Complete engine diagnostic and repair services',
        tag: 'Engine',
        tagColor: Color(0xFFE9D5FF),
        tagTextColor: Color(0xFF6B21A8),
        meta: 'Updated 1 day ago',
      ),
      const ServiceCardData(
        title: 'Oil Change Service',
        subtitle: 'Quick and efficient oil change for all vehicles',
        tag: 'Oil',
        tagColor: Color(0xFFFEF3C7),
        tagTextColor: Color(0xFF92400E),
        meta: 'Created 1 week ago',
      ),
    ];

    final timeline = <TaskStep>[
      TaskStep('Service Assigned', '10:00 AM', status: StepStatus.done),
      TaskStep('Contact Provider', '11:00 AM', status: StepStatus.done),
      TaskStep('Work Started', '11:15 AM', status: StepStatus.done),
      TaskStep('Work In Progress', 'Live', status: StepStatus.active),
      TaskStep('Work Completed', '-', status: StepStatus.todo),
      TaskStep('Payment', '-', status: StepStatus.todo),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _DashboardAppBar(
        title: 'Service Dashboard',
        subtitle: 'Raise a new request or track your active services',
        onBack: () => Navigator.maybePop(context),
        onBell: () {},
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // My Assigned Services header
            Text(
              'My Assigned Services',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track your Services here',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),

            // Search + filter row
            Row(
              children: [
                Expanded(
                  child: _SearchField(
                    hint: 'Search services...',
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(width: 10),
                _DropdownPill(value: 'All', onTap: () {}),
              ],
            ),
            const SizedBox(height: 12),

            // Assigned services list
            ...services.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ServiceCard(data: s),
              ),
            ),

            // In-progress block
            const SizedBox(height: 12),
            _InProgressSection(),

            const SizedBox(height: 12),

            // Task Progress section
            _TimelineCard(steps: timeline),
          ],
        ),
      ),

      // Bottom CTA
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF84FAB6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {},
            child: Text(
              'Complete Payment!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ----------------------- AppBar ----------------------- */

class _DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DashboardAppBar({
    required this.title,
    required this.subtitle,
    this.onBack,
    this.onBell,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onBell;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 18),
        onPressed: onBack,
        padding: const EdgeInsets.all(16),
      ),
      centerTitle: true,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: const Color(0xFF1F2937),
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: const Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black87, size: 18),
          onPressed: onBell,
          padding: const EdgeInsets.all(16),
        ),
      ],
    );
  }
}

/* ----------------------- Search Row ----------------------- */

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.hint,
    required this.onChanged,
  });

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          onChanged: onChanged,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF1F2937),
            ),
          decoration: InputDecoration(
            hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFFADAEBC),
              ),
              prefixIcon: const Icon(
                Icons.search,
                size: 14,
                color: Color(0xFFADAEBC),
              ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          Positioned(
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.tune,
                    size: 18,
                    color: Color(0xFFADAEBC),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownPill extends StatelessWidget {
  const _DropdownPill({required this.value, this.onTap});
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
      color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
          borderRadius: BorderRadius.circular(8),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Row(
              mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1F2937),
                ),
              ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.expand_more,
                  size: 19,
                  color: Color(0xFF1F2937),
                ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ----------------------- Cards ----------------------- */

class ServiceCardData {
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final String meta;
  final bool showTrash;

  const ServiceCardData({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
    required this.meta,
    this.showTrash = true,
  });
}

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.data, this.dense = false});
  final ServiceCardData data;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 148,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title row with chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                    height: 1.5,
                  ),
                ),
              ),
              _TagPill(
                text: data.tag,
                bg: data.tagColor,
                fg: data.tagTextColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
            data.subtitle,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF4B5563),
                height: 1.43,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (data.meta.isNotEmpty)
            Row(
              children: [
                Text(
                  data.meta,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const Spacer(),
                if (data.showTrash)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 14,
                          color: Color(0xFFED4C5C),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InProgressSection extends StatelessWidget {
  const _InProgressSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 148,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 11, 16, 0),
            child: Text(
              'Service in-progress',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tyre Replacement',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
          Text(
                        'Professional tyre replacement service for all vehicle types',
            style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF4B5563),
                          height: 1.43,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
            ),
          ),
                _TagPill(
                  text: 'Tyre Repair',
                  bg: const Color(0xFFDBEAFE),
                  fg: const Color(0xFF1E40AF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ----------------------- Timeline ----------------------- */

enum StepStatus { done, active, todo }

class TaskStep {
  final String title;
  final String time;
  final StepStatus status;
  TaskStep(this.title, this.time, {required this.status});
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.steps});
  final List<TaskStep> steps;

  Color get doneColor => const Color(0xFF27AE60);
  Color get activeColor => const Color(0xFF3A7BD5);
  Color get lineColor => const Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Progress',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            return _TimelineRow(
              step: step,
              isFirst: i == 0,
              isLast: i == steps.length - 1,
              colors: (done: doneColor, active: activeColor, line: lineColor),
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.step,
    required this.isFirst,
    required this.isLast,
    required this.colors,
  });

  final TaskStep step;
  final bool isFirst;
  final bool isLast;
  final ({Color done, Color active, Color line}) colors;

  @override
  Widget build(BuildContext context) {
    final isDone = step.status == StepStatus.done;
    final isActive = step.status == StepStatus.active;
    final isTodo = step.status == StepStatus.todo;

    return SizedBox(
      height: 56,
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // timeline gutter
        SizedBox(
            width: 28,
            height: 56,
            child: Stack(
            children: [
                // Connector line (full height for middle items, partial for first/last)
                if (!isFirst && !isLast)
                  Positioned(
                    top: 0,
                    left: 12,
                    child: Container(
                      width: 4,
                      height: 56,
                      color: colors.line,
                    ),
                  )
                else if (isFirst && !isLast)
                  Positioned(
                    top: 28,
                    left: 12,
                    child: Container(
                      width: 4,
                      height: 28,
                      color: colors.line,
                    ),
                  )
                else if (!isFirst && isLast)
                  Positioned(
                    top: 0,
                    left: 12,
                    child: Container(
                      width: 4,
                      height: 28,
                      color: colors.line,
                    ),
                  ),
                // node (centered vertically)
                Center(
                  child: Container(
                    width: 28,
                    height: 28,
                  decoration: BoxDecoration(
                      color: isDone
                          ? colors.done
                          : isActive
                              ? Colors.white
                              : colors.line,
                    shape: BoxShape.circle,
                      border: isActive
                          ? Border.all(color: colors.active, width: 2)
                          : null,
                  ),
                  alignment: Alignment.center,
                    child: isDone
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                )
                        : isActive
                            ? Container(
                                width: 16,
                                height: 16,
                  decoration: BoxDecoration(
                                  color: colors.active,
                    shape: BoxShape.circle,
                  ),
                )
                            : Container(
                                width: 16,
                                height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colors.line,
                                    width: 1,
                                  ),
                  ),
                ),
                  ),
                ),
            ],
          ),
        ),

          const SizedBox(width: 16),

          // title + "Live" + time
        Expanded(
          child: Padding(
              padding: const EdgeInsets.only(top: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    step.title,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: isActive
                            ? FontWeight.w500
                            : isTodo
                                ? FontWeight.w500
                                : FontWeight.w500,
                        color: isActive
                            ? colors.active
                            : isTodo
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF1F2937),
                    ),
                  ),
                ),
                if (isActive)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                    'Live',
                    style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                      color: colors.active,
            ),
          ),
        ),
        SizedBox(
                    width: 53,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              step.time,
              style: GoogleFonts.poppins(
                fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: step.time == '-'
                              ? const Color(0xFFBDBDBD)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
    );
  }
}
