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
        tagColor: Color(0xFFE6EBFF),
        tagTextColor: Color(0xFF5A78FF),
        meta: 'Updated 2 days ago',
      ),
      const ServiceCardData(
        title: 'Engine Diagnostics',
        subtitle: 'Complete engine diagnostic and repair services',
        tag: 'Engine',
        tagColor: Color(0xFFF2E9FF),
        tagTextColor: Color(0xFF8C5CF6),
        meta: 'Updated 1 day ago',
      ),
      const ServiceCardData(
        title: 'Oil Change Service',
        subtitle: 'Quick and efficient oil change for all vehicles',
        tag: 'Oil',
        tagColor: Color(0xFFFFF7D9),
        tagTextColor: Color(0xFFC49A00),
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
            Text(
              'My Assigned Services',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0E141B),
              ),
            ),
            Text(
              'Track your Services here',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: const Color(0xFF9AA4B2),
                height: 1.3,
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
                    trailing: _ChipButton(
                      icon: Icons.tune_rounded,
                      onTap: () {},
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _DropdownPill(value: 'All', onTap: () {}),
              ],
            ),
            const SizedBox(height: 14),

            // Assigned services list
            ...services.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ServiceCard(data: s),
              ),
            ),

            // In-progress block
            _SectionCard(
              borderColor: const Color(0xFF2E89FF),
              header: 'Service in-progress',
              child: ServiceCard(
                data: const ServiceCardData(
                  title: 'Tyre Replacement',
                  subtitle:
                      'Professional tyre replacement service for all vehicle types',
                  tag: 'Tyre Repair',
                  tagColor: Color(0xFFE6EBFF),
                  tagTextColor: Color(0xFF5A78FF),
                  meta: '',
                  showTrash: false,
                ),
                dense: true,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Task Progress',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0E141B),
              ),
            ),
            const SizedBox(height: 8),

            _TimelineCard(steps: timeline),
          ],
        ),
      ),

      // Bottom CTA
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF36D781),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: onBack,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: const Color(0xFF0E141B),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: const Color(0xFF9AA4B2),
              fontSize: 12,
              height: 1.1,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFC5C65),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications, color: Colors.white),
              ),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFF317873),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: onBell,
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.5),
        child: Container(height: 2, color: const Color(0xFF2E89FF)),
      ),
    );
  }
}

/* ----------------------- Search Row ----------------------- */

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.hint,
    required this.onChanged,
    this.trailing,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.search),
            hintStyle: GoogleFonts.poppins(color: const Color(0xFF9AA4B2)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF5A78FF),
                width: 1.8,
              ),
            ),
          ),
        ),
        if (trailing != null) Positioned(right: 8, child: trailing!),
      ],
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEFF2F8),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20, color: const Color(0xFF5A78FF)),
        ),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF0E141B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.expand_more, size: 18),
            ],
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E7EF)),
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
          // title row with chip and trash
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: GoogleFonts.poppins(
                    fontSize: dense ? 15 : 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0E141B),
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
          const SizedBox(height: 6),
          Text(
            data.subtitle,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              color: const Color(0xFF3A4656),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          if (data.meta.isNotEmpty)
            Row(
              children: [
                Text(
                  data.meta,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF9AA4B2),
                  ),
                ),
                const Spacer(),
                if (data.showTrash)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.delete, color: Color(0xFFED4C5C)),
                    onPressed: () {},
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: fg,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.header,
    required this.child,
    this.borderColor,
  });
  final String header;
  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? const Color(0xFFE3E7EF),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text(
            header,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0E141B),
            ),
          ),
          const SizedBox(height: 8),
          child,
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

  Color get doneColor => const Color(0xFF36D781);
  Color get activeColor => const Color(0xFF2E89FF);
  Color get lineColor => const Color(0xFFE0E5EF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E7EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _TimelineRow(
              step: steps[i],
              isFirst: i == 0,
              isLast: i == steps.length - 1,
              colors: (done: doneColor, active: activeColor, line: lineColor),
            ),
            if (i != steps.length - 1) const SizedBox(height: 4),
          ],
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // timeline gutter
        SizedBox(
          width: 26,
          child: Column(
            children: [
              // top connector
              if (!isFirst) Container(height: 10, width: 2, color: colors.line),
              // node
              if (isDone)
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: colors.done.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.check_circle, size: 18, color: colors.done),
                )
              else if (isActive)
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.active, width: 3),
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                )
              else
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.line, width: 2),
                  ),
                ),
              // bottom connector
              if (!isLast) Container(height: 22, width: 2, color: colors.line),
            ],
          ),
        ),

        const SizedBox(width: 6),

        // title + "Live"
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    step.title,
                    style: GoogleFonts.poppins(
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: const Color(0xFF0E141B),
                    ),
                  ),
                ),
                if (isActive)
                  Text(
                    'Live',
                    style: GoogleFonts.poppins(
                      color: colors.active,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // time
        SizedBox(
          width: 80,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              step.time,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF9AA4B2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
