import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/Transport/job_controller.dart';
import '../../models/job_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../enums/job_enums.dart';
import 'package:wheelboard/core/auth/auth_service.dart';

// Design tokens
const _primary = Color(0xFFF36969);
const _primaryLt = Color(0xFFFFF1F1);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _green = Color(0xFF22C55E);
const _amber = Color(0xFFF59E0B);

class PostJobScreen extends StatefulWidget {
  final JobModel? jobToEdit;
  const PostJobScreen({super.key, this.jobToEdit});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final JobController _ctrl = Get.put(JobController());

  JobDuration? _duration;
  JobType? _jobType;
  JobRole _role = JobRole.technician;
  bool _isEditMode = false;
  bool _isServiceProvider = false;
  bool _isUrgent = false;
  bool _isSubmitting = false;

  // Edit-mode status (Active / Paused / Closed)
  String? _status;

  final _titleCtrl = TextEditingController();
  final _openingCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.jobToEdit != null;
    _isServiceProvider = AuthService.to.isServiceProvider;

    if (_isEditMode) {
      final job = widget.jobToEdit!;
      _role = JobRole.fromString(job.type);
      _duration = JobDuration.fromString(job.duration);
      _jobType = JobType.fromString(job.type);
      _status = job.status.isNotEmpty ? job.status : 'Active';
      _isUrgent = job.urgent;

      _titleCtrl.text = job.title;
      _openingCtrl.text = job.openings.toString();
      _salaryCtrl.text = job.salary;
      _cityCtrl.text = job.city;
      _stateCtrl.text = job.state ?? '';
      _descCtrl.text = job.description;
    } else {
      if (_isServiceProvider && _role == JobRole.driver) {
        _role = JobRole.technician;
      }
      _jobType = JobType.fromString(_role.value);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _openingCtrl.dispose();
    _salaryCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _syncJobType() {
    setState(() => _jobType = JobType.fromString(_role.value));
  }

  Future<void> _submit() async {
    // Validate
    if (_titleCtrl.text.trim().isEmpty) {
      SnackBarHelper.error('Please enter a job title');
      return;
    }
    if (_duration == null) {
      SnackBarHelper.error('Please select job duration');
      return;
    }
    final openingsParsed = int.tryParse(_openingCtrl.text.trim());
    if (openingsParsed == null || openingsParsed < 1) {
      SnackBarHelper.error('Please enter a valid number of openings (minimum 1)');
      return;
    }
    if (_salaryCtrl.text.trim().isEmpty) {
      SnackBarHelper.error('Please enter salary');
      return;
    }
    if (_cityCtrl.text.trim().isEmpty) {
      SnackBarHelper.error('Please enter city');
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      SnackBarHelper.error('Please enter a description');
      return;
    }

    final title = _titleCtrl.text.trim();
    final openings = openingsParsed;
    final salaryText = _salaryCtrl.text.trim();
    final salaryMin =
        int.tryParse(salaryText.replaceAll(RegExp(r'[^\d]'), ''));
    final city = _cityCtrl.text.trim();
    final state = _stateCtrl.text.trim();

    // FE pattern: `location` = state (if provided) else city
    final locationValue = state.isNotEmpty ? state : city;

    setState(() => _isSubmitting = true);
    try {
      bool success;
      if (_isEditMode && widget.jobToEdit != null) {
        success = await _ctrl.updateJob(
          jobId: widget.jobToEdit!.jobId,
          title: title,
          duration: _duration!.value,
          openings: openings,
          salary: salaryText,
          salaryMin: salaryMin,
          city: city,
          location: locationValue,
          state: state.isEmpty ? null : state,
          type: _jobType!.value,
          description: _descCtrl.text.trim(),
          requirements: widget.jobToEdit!.requirements,
          benefits: widget.jobToEdit!.benefits,
          skills: widget.jobToEdit!.skills,
          urgent: _isUrgent,
          status: _status,
        );
      } else {
        success = await _ctrl.createJob(
          title: title,
          duration: _duration!.value,
          openings: openings,
          salary: salaryText,
          salaryMin: salaryMin,
          city: city,
          location: locationValue,
          state: state.isEmpty ? null : state,
          type: _jobType!.value,
          description: _descCtrl.text.trim(),
          requirements: const [],
          benefits: const [],
          skills: const [],
          urgent: _isUrgent,
        );
      }
      if (success && mounted) {
        await _ctrl.refreshJobs();
        if (mounted) Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _isEditMode ? 'Edit Job' : 'Post a Job',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Role selection ────────────────────────────────────────────────
            _sectionCard(
              icon: Iconsax.briefcase,
              title: 'Job Role',
              child: Row(
                children: [
                  if (!_isServiceProvider) ...[
                    _roleBtn(JobRole.driver, Iconsax.car),
                    const SizedBox(width: 10),
                  ],
                  _roleBtn(JobRole.technician, Iconsax.setting_2),
                  const SizedBox(width: 10),
                  _roleBtn(JobRole.helper, Iconsax.user),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Job details ───────────────────────────────────────────────────
            _sectionCard(
              icon: Iconsax.document_text,
              title: 'Job Details',
              child: Column(
                children: [
                  _field(
                    label: 'Job Title',
                    hint: 'e.g. Truck Driver, Bike Mechanic',
                    controller: _titleCtrl,
                  ),
                  const SizedBox(height: 14),
                  _dropdownField(
                    label: 'Job Duration',
                    hint: 'Select duration',
                    value: _duration?.value,
                    items: JobDuration.allValues,
                    onChanged: (v) => setState(() {
                      _duration = v != null ? JobDuration.fromString(v) : null;
                    }),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: _field(
                        label: 'Openings',
                        hint: 'No. of positions',
                        controller: _openingCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        label: 'Salary',
                        hint: 'e.g. ₹25,000/month',
                        controller: _salaryCtrl,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: _field(
                        label: 'City',
                        hint: 'Enter city',
                        controller: _cityCtrl,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        label: 'State (optional)',
                        hint: 'Enter state',
                        controller: _stateCtrl,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _multilineField(
                    label: 'Description',
                    hint: 'Describe the role, responsibilities and expectations…',
                    controller: _descCtrl,
                    minLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),



            // ── Settings ──────────────────────────────────────────────────────
            _sectionCard(
              icon: Iconsax.setting,
              title: 'Settings',
              child: Column(
                children: [
                  // Urgent toggle
                  _toggleRow(
                    icon: Iconsax.flash,
                    label: 'Mark as Urgent',
                    subtitle: 'Highlight this job to attract faster applicants',
                    value: _isUrgent,
                    onChanged: (v) => setState(() => _isUrgent = v),
                  ),
                  // Status (edit mode only)
                  if (_isEditMode) ...[
                    const Divider(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Job Status',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: ['Active', 'Paused', 'Closed'].map((s) {
                            final isSelected = _status == s;
                            Color statusColor;
                            switch (s) {
                              case 'Active':
                                statusColor = _green;
                                break;
                              case 'Paused':
                                statusColor = _amber;
                                break;
                              default:
                                statusColor = _textGrey;
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _status = s),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? statusColor.withValues(alpha: 0.12)
                                        : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? statusColor
                                          : _border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSelected) ...[
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                              color: statusColor,
                                              shape: BoxShape.circle),
                                        ),
                                        const SizedBox(width: 5),
                                      ],
                                      Text(
                                        s,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? statusColor
                                              : _textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),



            // ── Submit button ─────────────────────────────────────────────────
            Obx(() => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _ctrl.isLoading.value || _isSubmitting
                    ? null
                    : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  disabledBackgroundColor:
                      _primary.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _ctrl.isLoading.value || _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isEditMode ? Iconsax.edit : Iconsax.add_circle,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isEditMode ? 'Update Job' : 'Post Job',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  // ── Role button ─────────────────────────────────────────────────────────────

  Widget _roleBtn(JobRole role, IconData icon) {
    final isSelected = _role == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _role = role);
          _syncJobType();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _primary : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? _primary : _border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 20, color: isSelected ? Colors.white : _textGrey),
              const SizedBox(height: 4),
              Text(
                role.value,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : _textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section card ────────────────────────────────────────────────────────────

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _primaryLt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: _primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ── Form field ──────────────────────────────────────────────────────────────

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textGrey,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w500, color: _textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(fontSize: 13, color: _textGrey),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _multilineField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int minLines = 3,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textGrey,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            minLines: minLines,
            style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w500, color: _textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(fontSize: 13, color: _textGrey),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final validValue = (value != null && items.contains(value)) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textGrey,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: validValue,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                size: 20, color: _textGrey),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(fontSize: 13, color: _textGrey),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _primaryLt,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: _primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              Text(
                subtitle,
                style:
                    GoogleFonts.poppins(fontSize: 11, color: _textGrey),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: _primary,
          activeTrackColor: _primary.withValues(alpha: 0.25),
        ),
      ],
    );
  }


}
