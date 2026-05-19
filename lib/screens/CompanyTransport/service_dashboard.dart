import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/controllers/Transport/service_dashboard_controller.dart';
import 'package:wheelboard/models/dashboard_model.dart';
import 'package:wheelboard/models/myassign_sevice_list.dart';

class ServiceDashboardScreen extends StatelessWidget {
  ServiceDashboardScreen({super.key});

  final controller = Get.put(ServiceDashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: const _DashboardAppBar(
        title: 'Service Dashboard',
        subtitle: 'Raise a new request or track your active services',
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Assigned Services',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your Services here',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SearchField(controller: controller.searchCtrl),
                      ),
                      const SizedBox(width: 10),
                      // const _DropdownPill(value: 'All'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: controller.filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = controller.filteredServices[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Obx(() {
                        final isExpanded =
                            controller.expandedIndex.value == index;

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => controller.toggleExpand(index),
                          child: ServiceCard(
                            data: mapToCard(service),
                            expanded: isExpanded,
                            controller: controller,
                          ),
                        );
                      }),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// ================= MAPPER =================

ServiceCardData mapToCard(AssignedServiceModel s) {
  return ServiceCardData(
    title: s.serviceTitle,
    subtitle: s.description,
    tag: s.category,
    tagColor: s.category == "" ? Colors.white : Colors.cyan.shade200,
    tagTextColor: Colors.black,
    meta: s.scheduledDate.toLocal().toString().split(' ').first,
    status: s.status,
    assignedId: s.assignmentId,
    model: s,
  );
}

/// ================= COMMON WIDGETS =================

class _DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DashboardAppBar({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search services...',
        prefixIcon: const Icon(Icons.search, size: 16),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _DropdownPill extends StatelessWidget {
  const _DropdownPill({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(value, style: GoogleFonts.inter(fontSize: 12)),
          const Icon(Icons.expand_more),
        ],
      ),
    );
  }
}

/// ================= SERVICE CARD =================

class ServiceCardData {
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final String meta;
  final String status;
  final bool showTrash;
  final String assignedId;
  final AssignedServiceModel? model;

  const ServiceCardData({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
    required this.status,
    required this.meta,
    required this.assignedId,
    this.model,
    this.showTrash = true,
  });
}

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.data,
    required this.expanded,
    required this.controller,
  });

  final ServiceCardData data;
  final bool expanded;
  final ServiceDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- TOP CONTENT ----------
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
          Text(
            data.subtitle,
            maxLines: expanded ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          /// ---------- EXPANDABLE TASK PROGRESS ----------
          AnimatedCrossFade(
            firstChild: const SizedBox(),
            secondChild: _TaskProgress(data: data, controller: controller),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),

          const SizedBox(height: 12),

          /// ---------- FOOTER ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Assigned Date: ${HttpHelper.formatDate(data.meta, format: 'dd.MM.yy')}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Delete Service?',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          'Are you sure you want to delete this service? This action cannot be undone.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              controller.deleteService(data.assignedId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Delete',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentGeometry.bottomRight,
            child: Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 12, color: fg)),
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
            color: Colors.black.withValues(alpha: 0.03),
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
                    child: Container(width: 4, height: 56, color: colors.line),
                  )
                else if (isFirst && !isLast)
                  Positioned(
                    top: 28,
                    left: 12,
                    child: Container(width: 4, height: 28, color: colors.line),
                  )
                else if (!isFirst && isLast)
                  Positioned(
                    top: 0,
                    left: 12,
                    child: Container(width: 4, height: 28, color: colors.line),
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
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
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
                              border: Border.all(color: colors.line, width: 1),
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

class _TaskProgress extends StatelessWidget {
  final ServiceCardData data;
  final ServiceDashboardController controller;

  const _TaskProgress({
    required this.data,
    required this.controller,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text(
          "Task Progress",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 12),
        if (data.status.toLowerCase().contains("assign") ||
            data.status.toLowerCase().contains("pending") ||
            data.status.toLowerCase().contains("inprogress") ||
            data.status.toLowerCase().contains("completed") ||
            data.status.toLowerCase().contains("start"))
          _progressItem("Service Assigned", true),
        if (data.status.toLowerCase().contains("inprogress") ||
            data.status.toLowerCase().contains("start"))
          _progressItem("Work In Progress", true),
        if (data.status.toLowerCase().contains("completed") ||
            data.status.toLowerCase().contains("paid"))
          _progressItem("Work Completed", true),
        if (data.status.toLowerCase().contains("paid"))
          _progressItem("Payment Success", true),
        if (data.status.toLowerCase().contains("completed") &&
            !data.status.toLowerCase().contains("paid"))
          _progressItem("Payment Pending", false, isPending: true),
        if (data.status.toLowerCase().contains("cancelled"))
          _progressItem("Cancelled", false),
        if (data.status.toLowerCase().contains("completed"))
          Column(
            children: [
              if (data.model?.paymentAmount != null &&
                  data.model!.paymentAmount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Actual Amount:",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        "₹${data.model!.paymentAmount}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00B894),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onTap: () {
                    if (data.model != null) {
                      controller.initiatePayment(data.model!);
                    }
                  },
                  child: Container(
                    width: Get.width,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Center(
                      child: Text(
                        'Complete payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _progressItem(String title, bool done, {bool isPending = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            isPending
                ? Icons.radio_button_unchecked
                : (done ? Icons.check_circle : Icons.cancel),
            size: 18,
            color: isPending
                ? Colors.grey
                : (done ? const Color(0xFF00B894) : Colors.red),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
