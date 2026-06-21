import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/Transport/fleet_controller.dart';
import '../../../controllers/Transport/lease_controller.dart';
import '../../../models/get_vehicle_model.dart';
import '../../../widgets/custom_loader.dart';
import '../../../widgets/custom_snackbar.dart';

const _primary = Color(0xFFF36969);
const _primaryLight = Color(0xFFFFF1F1);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);

class CreateLeaseWizard extends StatefulWidget {
  const CreateLeaseWizard({super.key});

  @override
  State<CreateLeaseWizard> createState() => _CreateLeaseWizardState();
}

class _CreateLeaseWizardState extends State<CreateLeaseWizard> {
  final _ctrl = Get.find<LeaseController>();
  final _fleet = Get.find<DriverController>();

  int _step = 1;
  bool _submitting = false;

  // Step 1 — vehicle selection
  Vehicle? _selectedVehicle;

  // Step 2 — details
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _termsCtrl = TextEditingController();
  final _odomCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  // Step 3 — pricing
  String _pricingType = 'flat'; // flat | on_request
  String _priceUnit = 'daily';  // daily | weekly | monthly
  final _priceCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  bool _deliveryAvailable = false;
  final _radiusCtrl = TextEditingController();
  final _deliveryFeeCtrl = TextEditingController();

  // Step 4 — availability
  DateTime? _availableFrom;
  DateTime? _availableUntil;
  final _minDaysCtrl = TextEditingController(text: '7');
  final _maxDaysCtrl = TextEditingController(text: '90');

  @override
  void initState() {
    super.initState();
    _fleet.fetchVehicles();
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl, _descCtrl, _termsCtrl, _odomCtrl, _locationCtrl,
      _priceCtrl, _depositCtrl, _radiusCtrl, _deliveryFeeCtrl,
      _minDaysCtrl, _maxDaysCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  bool get _canAdvance {
    switch (_step) {
      case 1: return _selectedVehicle != null;
      case 2:
        return _titleCtrl.text.trim().isNotEmpty && _locationCtrl.text.trim().isNotEmpty;
      case 3:
        return _pricingType == 'on_request' || _priceCtrl.text.trim().isNotEmpty;
      case 4: return _availableFrom != null;
      default: return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgress(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(),
            ),
          ),
          _buildNavBar(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: _card,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: _border,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _textDark),
          onPressed: () => _step == 1 ? Get.back() : setState(() => _step--),
        ),
        title: Text(_stepTitle(),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
      );

  String _stepTitle() {
    switch (_step) {
      case 1: return 'Select Vehicle';
      case 2: return 'Listing Details';
      case 3: return 'Pricing';
      case 4: return 'Availability';
      default: return '';
    }
  }

  // ── Progress bar ──────────────────────────────────────────────────────────

  Widget _buildProgress() {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Column(
        children: [
          Row(children: List.generate(4, (i) {
            final done = i + 1 < _step;
            final current = i + 1 == _step;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 3 ? 4 : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color: done || current ? _primary : _border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          })),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Step $_step of 4',
                  style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins')),
              Text(_stepTitle(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _primary, fontFamily: 'Poppins')),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step content ──────────────────────────────────────────────────────────

  Widget _buildStepContent() {
    switch (_step) {
      case 1: return _buildStep1();
      case 2: return _buildStep2();
      case 3: return _buildStep3();
      case 4: return _buildStep4();
      default: return const SizedBox.shrink();
    }
  }

  // Step 1 – Vehicle selection
  Widget _buildStep1() {
    return Obx(() {
      if (_fleet.isVehicleLoading.value) {
        return const Center(child: Padding(padding: EdgeInsets.all(32), child: CustomLoader()));
      }
      final owned = _fleet.vehicles.where((v) => v.ownershipType.toLowerCase() == 'owned').toList();
      if (owned.isEmpty) {
        return _noVehicles();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose which vehicle to list for lease:',
              style: TextStyle(fontSize: 13, color: _textGrey, fontFamily: 'Poppins')),
          const SizedBox(height: 16),
          ...owned.map((v) => _VehicleSelectCard(
                vehicle: v,
                selected: _selectedVehicle?.vehicleId == v.vehicleId,
                onTap: () => setState(() {
                  _selectedVehicle = v;
                  if (_titleCtrl.text.isEmpty) _titleCtrl.text = '${v.vehicleModel} for Lease';
                  if (_locationCtrl.text.isEmpty) _locationCtrl.text = '';
                  if (_odomCtrl.text.isEmpty) _odomCtrl.text = '';
                }),
              )),
        ],
      );
    });
  }

  Widget _noVehicles() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
        child: Column(children: [
          const Icon(Iconsax.truck, size: 48, color: _textGrey),
          const SizedBox(height: 12),
          const Text('No owned vehicles found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
          const SizedBox(height: 6),
          const Text('Add at least one vehicle with Ownership = "Owned" before creating a lease listing.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins')),
        ]),
      );

  // Step 2 – Details
  Widget _buildStep2() => Column(
        children: [
          _field('Listing Title *', _titleCtrl, hint: 'e.g. Tata Prima 2022 for Monthly Lease'),
          const SizedBox(height: 14),
          _field('Description', _descCtrl, hint: 'Describe the vehicle and lease terms…', maxLines: 4),
          const SizedBox(height: 14),
          _field('Odometer Reading (km)', _odomCtrl, hint: '50000', keyboard: TextInputType.number),
          const SizedBox(height: 14),
          _field('Terms & Conditions', _termsCtrl, hint: 'Any special conditions for lessees…', maxLines: 3),
          const SizedBox(height: 14),
          _field('Pickup Location *', _locationCtrl, hint: 'e.g. Mumbai, Maharashtra', prefix: Iconsax.location),
        ],
      );

  // Step 3 – Pricing
  Widget _buildStep3() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Pricing Type'),
          const SizedBox(height: 8),
          Row(children: [
            _typeCard('flat', 'Flat Price', Iconsax.wallet_3),
            const SizedBox(width: 10),
            _typeCard('on_request', 'On Request', Iconsax.message_question),
          ]),
          if (_pricingType == 'flat') ...[
            const SizedBox(height: 16),
            _sectionLabel('Price Unit'),
            const SizedBox(height: 8),
            Row(children: [
              _unitChip('daily', 'Per Day'),
              const SizedBox(width: 8),
              _unitChip('weekly', 'Per Week'),
              const SizedBox(width: 8),
              _unitChip('monthly', 'Per Month'),
            ]),
            const SizedBox(height: 14),
            _field('Price (₹) *', _priceCtrl, hint: '5000', keyboard: TextInputType.number, prefix: Iconsax.money_recive),
          ],
          const SizedBox(height: 16),
          _field('Security Deposit (₹)', _depositCtrl, hint: '10000 (optional)', keyboard: TextInputType.number),
          const SizedBox(height: 16),
          _sectionLabel('Delivery'),
          const SizedBox(height: 8),
          _toggleRow('Delivery Available', _deliveryAvailable, (v) => setState(() => _deliveryAvailable = v)),
          if (_deliveryAvailable) ...[
            const SizedBox(height: 12),
            _field('Delivery Radius (km)', _radiusCtrl, hint: '50', keyboard: TextInputType.number),
            const SizedBox(height: 12),
            _field('Delivery Fee (₹)', _deliveryFeeCtrl, hint: '2000', keyboard: TextInputType.number),
          ],
        ],
      );

  // Step 4 – Availability + summary
  Widget _buildStep4() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _datePicker('Available From *', _availableFrom, (d) => setState(() => _availableFrom = d)),
          const SizedBox(height: 14),
          _datePicker('Available Until (Optional)', _availableUntil, (d) => setState(() => _availableUntil = d)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _field('Min Duration (days)', _minDaysCtrl, hint: '7', keyboard: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: _field('Max Duration (days)', _maxDaysCtrl, hint: '90', keyboard: TextInputType.number)),
          ]),
          const SizedBox(height: 24),
          _buildSummary(),
        ],
      );

  Widget _buildSummary() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Iconsax.receipt_text, size: 18, color: _primary),
              const SizedBox(width: 8),
              const Text('Listing Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
            ]),
            const Divider(color: _border, height: 20),
            if (_selectedVehicle != null)
              _summaryRow('Vehicle', '${_selectedVehicle!.vehicleModel} (${_selectedVehicle!.vehicleNumber})'),
            _summaryRow('Title', _titleCtrl.text.isEmpty ? '—' : _titleCtrl.text),
            _summaryRow('Location', _locationCtrl.text.isEmpty ? '—' : _locationCtrl.text),
            _summaryRow('Pricing', _pricingType == 'on_request'
                ? 'On Request'
                : '₹${_priceCtrl.text} / $_priceUnit'),
            if (_availableFrom != null)
              _summaryRow('Available From', _fmtDate(_availableFrom!)),
            if (_availableUntil != null)
              _summaryRow('Until', _fmtDate(_availableUntil!)),
            _summaryRow('Duration', '${_minDaysCtrl.text}–${_maxDaysCtrl.text} days'),
          ],
        ),
      );

  Widget _summaryRow(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          SizedBox(width: 100, child: Text(k, style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins'))),
          Expanded(child: Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textDark, fontFamily: 'Poppins'))),
        ]),
      );

  // ── Nav bar ───────────────────────────────────────────────────────────────

  Widget _buildNavBar() {
    final isLast = _step == 4;
    return Container(
      color: _card,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      child: Row(children: [
        if (_step > 1)
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () => setState(() => _step--),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Back', style: TextStyle(color: _textDark, fontFamily: 'Poppins')),
            ),
          ),
        if (_step > 1) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: isLast
              ? Column(children: [
                  SizedBox(
                    width: double.infinity,
                    child: _PrimaryBtn(
                      label: 'Publish Listing',
                      loading: _submitting,
                      enabled: _canAdvance,
                      onTap: () => _submit(publish: true),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _submitting ? null : () => _submit(publish: false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Save as Draft', style: TextStyle(color: _textDark, fontFamily: 'Poppins')),
                    ),
                  ),
                ])
              : _PrimaryBtn(
                  label: 'Continue',
                  loading: false,
                  enabled: _canAdvance,
                  onTap: () => setState(() => _step++),
                ),
        ),
      ]),
    );
  }

  Future<void> _submit({required bool publish}) async {
    if (_selectedVehicle == null) return;
    setState(() => _submitting = true);

    final data = <String, dynamic>{
      'vehicleId': _selectedVehicle!.vehicleId,
      'title': _titleCtrl.text.trim(),
      if (_descCtrl.text.trim().isNotEmpty) 'description': _descCtrl.text.trim(),
      if (_termsCtrl.text.trim().isNotEmpty) 'terms': _termsCtrl.text.trim(),
      if (_odomCtrl.text.trim().isNotEmpty)
        'odometerReading': int.tryParse(_odomCtrl.text.trim()),
      'pricingType': _pricingType,
      if (_pricingType == 'flat') ...{
        'priceUnit': _priceUnit,
        if (_priceCtrl.text.trim().isNotEmpty)
          'priceAmount': double.tryParse(_priceCtrl.text.trim()),
      },
      if (_depositCtrl.text.trim().isNotEmpty)
        'securityDeposit': double.tryParse(_depositCtrl.text.trim()),
      'pickupLocation': _locationCtrl.text.trim(),
      'deliveryAvailable': _deliveryAvailable,
      if (_deliveryAvailable && _radiusCtrl.text.trim().isNotEmpty)
        'deliveryRadius': double.tryParse(_radiusCtrl.text.trim()),
      if (_deliveryAvailable && _deliveryFeeCtrl.text.trim().isNotEmpty)
        'deliveryFee': double.tryParse(_deliveryFeeCtrl.text.trim()),
      // Backend expects date-only: "YYYY-MM-DD"
      'availableFrom': _dateOnly(_availableFrom!),
      if (_availableUntil != null) 'availableUntil': _dateOnly(_availableUntil!),
      'minDurationDays': int.tryParse(_minDaysCtrl.text.trim()) ?? 7,
      'maxDurationDays': int.tryParse(_maxDaysCtrl.text.trim()) ?? 90,
      // Seed listing images from the vehicle's photo, mirroring wheelboard-fe
      // (listings/new → images: [selectedVehicle.image]).
      if (_selectedVehicle!.imageUrls.isNotEmpty)
        'images': [_selectedVehicle!.imageUrls.first],
      // Do NOT send 'status' — backend sets 'draft' by default
    };

    final id = await _ctrl.createListingAndGetId(data);
    if (id != null && publish) {
      await _ctrl.updateListingStatus(id, 'active');
    }
    setState(() => _submitting = false);

    if (id != null) {
      SnackBarHelper.success(publish ? 'Listing published!' : 'Saved as draft');
      Get.back();
    } else if (mounted) {
      SnackBarHelper.error('Failed to create listing. Please check all fields.');
    }
  }

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Field helpers ─────────────────────────────────────────────────────────

  Widget _field(String label, TextEditingController ctrl,
      {String? hint, TextInputType? keyboard, int maxLines = 1, IconData? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _textGrey, fontFamily: 'Poppins')),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF), fontFamily: 'Poppins'),
            prefixIcon: prefix != null ? Icon(prefix, size: 18, color: _textGrey) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            filled: true, fillColor: _bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primary, width: 1.5)),
          ),
          style: const TextStyle(fontSize: 14, color: _textDark, fontFamily: 'Poppins'),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) =>
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey, fontFamily: 'Poppins', letterSpacing: 0.3));

  Widget _typeCard(String type, String label, IconData icon) {
    final active = _pricingType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _pricingType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? _primaryLight : _bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? _primary : _border, width: active ? 1.5 : 1),
          ),
          child: Column(children: [
            Icon(icon, size: 22, color: active ? _primary : _textGrey),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? _primary : _textGrey, fontFamily: 'Poppins')),
          ]),
        ),
      ),
    );
  }

  Widget _unitChip(String unit, String label) {
    final active = _priceUnit == unit;
    return GestureDetector(
      onTap: () => setState(() => _priceUnit = unit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _primary : _bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? _primary : _border),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Colors.white : _textGrey, fontFamily: 'Poppins')),
      ),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) =>
      Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: _textDark, fontFamily: 'Poppins', fontWeight: FontWeight.w500))),
        Switch(value: value, onChanged: onChanged, activeTrackColor: _primary, activeThumbColor: Colors.white, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      ]);

  Widget _datePicker(String label, DateTime? value, ValueChanged<DateTime?> onPick) {
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          builder: (c, child) => Theme(
            data: Theme.of(c).copyWith(colorScheme: const ColorScheme.light(primary: _primary)),
            child: child!,
          ),
        );
        onPick(d);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _textGrey, fontFamily: 'Poppins')),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: value != null ? _primary : _border, width: value != null ? 1.5 : 1),
            ),
            child: Row(children: [
              Icon(Iconsax.calendar, size: 18, color: value != null ? _primary : _textGrey),
              const SizedBox(width: 10),
              Text(value == null ? 'Select date' : _fmtDate(value),
                  style: TextStyle(fontSize: 14, color: value == null ? const Color(0xFF9CA3AF) : _textDark, fontFamily: 'Poppins')),
            ]),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}

// ── Vehicle select card ───────────────────────────────────────────────────────

class _VehicleSelectCard extends StatelessWidget {
  final Vehicle vehicle;
  final bool selected;
  final VoidCallback onTap;
  const _VehicleSelectCard({required this.vehicle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final img = vehicle.imageUrls.isNotEmpty ? vehicle.imageUrls.first : null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: selected ? _primaryLight : _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _primary : _border, width: selected ? 1.5 : 1),
          boxShadow: selected ? [BoxShadow(color: _primary.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: img != null
                  ? Image.network(img, width: 68, height: 68, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ph())
                  : _ph(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(vehicle.vehicleModel,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: selected ? _primary : _textDark, fontFamily: 'Poppins')),
                const SizedBox(height: 2),
                Text(vehicle.vehicleNumber, style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins')),
                const SizedBox(height: 4),
                Row(children: [
                  _chip(vehicle.vehicleType, selected ? _primary : const Color(0xFF8B5CF6)),
                  const SizedBox(width: 6),
                  if (vehicle.manufacturingYear > 0)
                    _chip('${vehicle.manufacturingYear}', _textGrey),
                ]),
              ]),
            ),
            if (selected)
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: _primary, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _ph() => Container(width: 68, height: 68, color: const Color(0xFFF3F4F6),
      child: const Center(child: Icon(Iconsax.truck, size: 28, color: _textGrey)));

  Widget _chip(String l, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
        child: Text(l, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c, fontFamily: 'Poppins')),
      );
}

// ── Primary button ────────────────────────────────────────────────────────────

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.loading, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (!enabled || loading) ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _border,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
      ),
    );
  }
}
