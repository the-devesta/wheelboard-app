import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/Transport/job_controller.dart';
import '../../models/hired_professional_model.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/ui/app_ui.dart';

/// Employer view of professionals hired across their jobs.
///
/// Mirrors the FE hired-professionals management: list + stats + per-record
/// status changes (onboarding → active → completed) and removal.
class HiredProfessionalsScreen extends StatefulWidget {
  const HiredProfessionalsScreen({super.key});

  @override
  State<HiredProfessionalsScreen> createState() =>
      _HiredProfessionalsScreenState();
}

class _HiredProfessionalsScreenState extends State<HiredProfessionalsScreen> {
  late final JobController jobController;
  final RxString _statusFilter = 'All'.obs;

  static const _filters = ['All', 'onboarding', 'active', 'completed'];

  @override
  void initState() {
    super.initState();
    jobController = Get.isRegistered<JobController>()
        ? Get.find<JobController>()
        : Get.put(JobController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      jobController.fetchHiredProfessionals();
    });
  }

  void _applyFilter(String status) {
    _statusFilter.value = status;
    jobController.fetchHiredProfessionals(
      status: status == 'All' ? null : status,
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppUi.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Hired Professionals',
          style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Stats banner
          Obx(() {
            final s = jobController.hiredStats.value;
            if (s == null) return const SizedBox.shrink();
            return AppCard(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatTile(value: '${s.total}', label: 'Total'),
                  StatTile(value: '${s.onboarding}', label: 'Onboarding', color: AppUi.amber),
                  StatTile(value: '${s.active}', label: 'Active', color: AppUi.blue),
                  StatTile(value: '${s.completed}', label: 'Completed', color: AppUi.green),
                ],
              ),
            );
          }),
          // Filter chips
          Obx(
            () => AppFilterChips(
              options: _filters,
              selected: _statusFilter.value,
              labelOf: (f) => f == 'All' ? 'All' : _cap(f),
              onSelected: _applyFilter,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (jobController.isHiredLoading.value &&
                  jobController.hiredProfessionals.isEmpty) {
                return const CustomLoader(message: 'Loading...');
              }
              if (jobController.hiredProfessionals.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.groups_outlined,
                  title: 'No hired professionals yet',
                  subtitle: 'Hire candidates from your job applications to see them here.',
                );
              }
              return RefreshIndicator(
                onRefresh: () => jobController.fetchHiredProfessionals(
                  status: _statusFilter.value == 'All'
                      ? null
                      : _statusFilter.value,
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: jobController.hiredProfessionals.length,
                  itemBuilder: (_, i) =>
                      _card(jobController.hiredProfessionals[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _card(HiredProfessional pro) {
    final info = pro.hiredJobInfo;
    final status = info?.status ?? 'onboarding';
    final color = status == 'completed'
        ? Colors.green
        : status == 'active'
            ? const Color(0xFF2563EB)
            : Colors.orange;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE5E7EB),
                backgroundImage:
                    (pro.profile.avatar != null && pro.profile.avatar!.isNotEmpty)
                        ? NetworkImage(pro.profile.avatar!)
                        : null,
                child: (pro.profile.avatar == null ||
                        pro.profile.avatar!.isEmpty)
                    ? Text(
                        pro.profile.fullName.isNotEmpty
                            ? pro.profile.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pro.profile.fullName.isNotEmpty
                          ? pro.profile.fullName
                          : pro.email,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (info != null)
                      Text(
                        info.jobTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                  ],
                ),
              ),
              StatusPill(text: _cap(status), color: color),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: info == null
                      ? null
                      : () => _changeStatus(pro, info),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF36969),
                    side: const BorderSide(color: Color(0xFFF36969)),
                  ),
                  child: const Text('Update Status'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: 'Remove',
                onPressed: info == null
                    ? null
                    : () => _confirmRemove(pro, info),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _changeStatus(HiredProfessional pro, HiredJobInfo info) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['onboarding', 'active', 'completed']
              .map(
                (s) => ListTile(
                  title: Text(_cap(s)),
                  trailing: info.status == s
                      ? const Icon(Icons.check, color: Color(0xFFF36969))
                      : null,
                  onTap: () {
                    Get.back();
                    jobController.updateHiredStatus(
                      professionalId: pro.id,
                      jobId: info.jobId,
                      status: s,
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _confirmRemove(HiredProfessional pro, HiredJobInfo info) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove professional'),
        content: Text(
          'Remove ${pro.profile.fullName.isNotEmpty ? pro.profile.fullName : 'this professional'} from the hired list?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              jobController.removeHiredProfessional(
                professionalId: pro.id,
                jobId: info.jobId,
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
