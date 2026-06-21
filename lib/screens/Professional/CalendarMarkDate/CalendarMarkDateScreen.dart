import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/Professional/calendar_controller.dart';
import '../../../models/Professional/calendar_event_model.dart';
import '../../../theme/design_system.dart';

/// Mark Your Calendar — a 1:1 port of the web `/professional/calendar/mark`
/// page. By default it marks the day's availability (Active/Inactive); adding an
/// event name or a Trip/Job category instead creates a typed event. Editing an
/// existing event (PATCH) is supported via [event].
class CalendarMarkDateScreen extends StatefulWidget {
  final DateTime? initialDate;
  final CalendarEvent? event;

  const CalendarMarkDateScreen({super.key, this.initialDate, this.event});

  @override
  State<CalendarMarkDateScreen> createState() => _CalendarMarkDateScreenState();
}

class _CalendarMarkDateScreenState extends State<CalendarMarkDateScreen> {
  final CalendarController c = Get.isRegistered<CalendarController>()
      ? Get.find<CalendarController>()
      : Get.put(CalendarController());

  final _eventNameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();

  late DateTime _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _category = ''; // '' | trip | job
  bool _isActive = true;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now();
    final e = widget.event;
    if (e != null) {
      _date = e.start ?? _date;
      _eventNameCtrl.text =
          (e.title == 'Available' || e.title == 'Unavailable') ? '' : e.title;
      _noteCtrl.text = e.description;
      _category = (e.isTrip || e.isJob) ? e.type.toLowerCase() : '';
      _isActive = e.isActive;
      _fromCtrl.text = e.metadata['from']?.toString() ?? '';
      _toCtrl.text = e.metadata['to']?.toString() ?? '';
      _startTime = _parseClock(e.startClock);
      _endTime = _parseClock(e.endClock);
    }
  }

  @override
  void dispose() {
    _eventNameCtrl.dispose();
    _noteCtrl.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        backgroundColor: AppPalette.card,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppPalette.textDark),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_isEditing ? 'Edit Event' : 'Mark Your Calendar',
                style: AppText.h2),
            Text('Set your availability and schedule events',
                style: AppText.caption.on(AppPalette.textGrey)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _card('Select Date', required: true, child: _dateSelector()),
          AppSpacing.vGapMd,
          _card('Event name (optional)',
              child: _input(_eventNameCtrl, 'e.g., Delhi to Mumbai Trip')),
          AppSpacing.vGapMd,
          _card('Note (optional)',
              child: _input(_noteCtrl, 'Add any additional details…',
                  maxLines: 3)),
          AppSpacing.vGapMd,
          Row(children: [
            Expanded(
                child: _card('Start time (optional)',
                    child: _timeSelector(true))),
            AppSpacing.hGapMd,
            Expanded(
                child:
                    _card('End time (optional)', child: _timeSelector(false))),
          ]),
          if (_category == 'trip') ...[
            AppSpacing.vGapMd,
            Row(children: [
              Expanded(
                  child:
                      _card('From', child: _input(_fromCtrl, 'Start location'))),
              AppSpacing.hGapMd,
              Expanded(
                  child: _card('To', child: _input(_toCtrl, 'Destination'))),
            ]),
          ],
          AppSpacing.vGapMd,
          _card('Select Category (optional)', child: _categorySelector()),
          AppSpacing.vGapMd,
          _card('Mark the date as', child: _availabilityToggle()),
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
                    label: _isEditing ? 'Update Event' : 'Mark the Date',
                    icon: Iconsax.calendar_tick,
                    loading: c.isSaving.value,
                    onPressed: _submit,
                  )),
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Pieces ──────────────────────────────────────────────────────────────────
  Widget _card(String title, {required Widget child, bool required = false}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppPalette.card,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(title, style: AppText.label.on(AppPalette.textDark)),
          if (required)
            Text(' *', style: AppText.label.on(AppPalette.primary)),
        ]),
        AppSpacing.vGapSm,
        child,
      ]),
    );
  }

  Widget _input(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: AppText.body.on(AppPalette.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.bodySm.on(AppPalette.textFaint),
        filled: true,
        fillColor: AppPalette.bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  Widget _dateSelector() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => _date = picked);
      },
      child: _pickerBox(
          Iconsax.calendar, _formatDate(_date), AppPalette.textDark),
    );
  }

  Widget _timeSelector(bool isStart) {
    final t = isStart ? _startTime : _endTime;
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
            context: context, initialTime: t ?? TimeOfDay.now());
        if (picked != null) {
          setState(() {
            if (isStart) {
              _startTime = picked;
            } else {
              _endTime = picked;
            }
          });
        }
      },
      child: _pickerBox(
          Iconsax.clock,
          t != null ? _formatTime(t) : 'Select time',
          t != null ? AppPalette.textDark : AppPalette.textFaint),
    );
  }

  Widget _pickerBox(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppPalette.bg,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: AppPalette.textGrey),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppText.bodySm.on(color))),
      ]),
    );
  }

  Widget _categorySelector() {
    return Row(children: [
      Expanded(child: _catChip('trip', 'Trip', AppPalette.primary)),
      AppSpacing.hGapMd,
      Expanded(child: _catChip('job', 'Job', const Color(0xFF14B8A6))),
    ]);
  }

  Widget _catChip(String value, String label, Color color) {
    final sel = _category == value;
    return GestureDetector(
      onTap: () => setState(() => _category = sel ? '' : value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sel ? color.withValues(alpha: 0.1) : AppPalette.card,
          borderRadius: AppRadius.rLg,
          border: Border.all(
              color: sel ? color : AppPalette.border, width: sel ? 1.5 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: sel ? color : AppPalette.textFaint,
                shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: AppText.label
                  .on(sel ? color : AppPalette.textMid)
                  .weight(FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _availabilityToggle() {
    return Column(children: [
      Row(children: [
        Expanded(
          child: Text(
            _isActive
                ? 'Available — visible to companies & businesses'
                : 'Unavailable on this date',
            style: AppText.bodySm.on(AppPalette.textMid),
          ),
        ),
        Switch(
          value: _isActive,
          onChanged: (v) => setState(() => _isActive = v),
          activeTrackColor: AppPalette.green,
          activeThumbColor: Colors.white,
        ),
      ]),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
            color: AppPalette.bg, borderRadius: AppRadius.rMd),
        child: Row(children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: _isActive ? AppPalette.green : AppPalette.textGrey,
                shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(_isActive ? 'Active' : 'Inactive',
              style: AppText.label
                  .on(_isActive ? AppPalette.green : AppPalette.textGrey)
                  .weight(FontWeight.w600)),
        ]),
      ),
    ]);
  }

  // ── Submit (web parity) ─────────────────────────────────────────────────────
  Future<void> _submit() async {
    final dateStr = _key(_date);
    final allDay =
        DateTime.utc(_date.year, _date.month, _date.day).toIso8601String();
    final startIso = _startTime != null
        ? '${dateStr}T${_two(_startTime!.hour)}:${_two(_startTime!.minute)}:00'
        : allDay;
    final endIso = _endTime != null
        ? '${dateStr}T${_two(_endTime!.hour)}:${_two(_endTime!.minute)}:00'
        : allDay;

    final eventName = _eventNameCtrl.text.trim();
    final hasTyped = _category.isNotEmpty || eventName.isNotEmpty;

    final Map<String, dynamic> payload = hasTyped
        ? {
            'title': eventName.isNotEmpty ? eventName : 'Calendar Event',
            'description': _noteCtrl.text.trim(),
            'startDate': startIso,
            'endDate': endIso,
            'type': _category.isNotEmpty ? _category : 'reminder',
            'metadata': {
              'from': _fromCtrl.text.trim(),
              'to': _toCtrl.text.trim(),
            },
          }
        : {
            'title': _isActive ? 'Available' : 'Unavailable',
            'startDate': allDay,
            'endDate': allDay,
            'type': 'availability',
            'status': _isActive ? 'active' : 'cancelled',
          };

    final ok = _isEditing
        ? await c.updateEvent(widget.event!.id, payload)
        : await c.createEvent(payload);
    if (ok) Get.back();
  }

  // ── Formatting helpers ──────────────────────────────────────────────────────
  String _two(int n) => n.toString().padLeft(2, '0');

  String _key(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatTime(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';

  TimeOfDay? _parseClock(String clock) {
    if (clock.isEmpty || !clock.contains(':')) return null;
    final parts = clock.split(':');
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }
}
