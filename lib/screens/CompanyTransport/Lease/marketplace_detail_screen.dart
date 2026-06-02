import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/Transport/lease_controller.dart';
import '../../../models/fleet_models.dart';
import '../../../widgets/custom_loader.dart';
import '../../../widgets/custom_snackbar.dart';

const _primary = Color(0xFFF36969);
const _primaryLight = Color(0xFFFFF1F1);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);

class MarketplaceDetailScreen extends StatefulWidget {
  final String listingId;
  final LeaseListing? listing;
  const MarketplaceDetailScreen({super.key, required this.listingId, this.listing});

  @override
  State<MarketplaceDetailScreen> createState() => _MarketplaceDetailScreenState();
}

class _MarketplaceDetailScreenState extends State<MarketplaceDetailScreen> {
  final LeaseController _ctrl = Get.find<LeaseController>();

  LeaseListing? _listing;
  bool _loading = false;

  // Booking form
  DateTime? _startDate;
  DateTime? _endDate;
  final _messageCtrl = TextEditingController();
  bool _needsDelivery = false;
  bool _bookingSuccess = false;

  @override
  void initState() {
    super.initState();
    _listing = widget.listing;
    if (_listing == null) _loadDetail();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() => _loading = true);
    final result = await _ctrl.fetchMarketplaceDetail(widget.listingId);
    setState(() {
      _listing = result;
      _loading = false;
    });
  }

  int get _durationDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays;
  }

  double get _estimatedTotal {
    final l = _listing;
    if (l == null || l.pricingType == 'on_request' || l.priceAmount == null) return 0;
    final days = _durationDays;
    if (days <= 0) return 0;
    double dailyRate = l.priceAmount!;
    if (l.priceUnit == 'weekly') dailyRate = l.priceAmount! / 7;
    if (l.priceUnit == 'monthly') dailyRate = l.priceAmount! / 30;
    return dailyRate * days + (l.securityDeposit ?? 0);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now)
        : (_endDate ?? (_startDate?.add(const Duration(days: 7)) ?? now.add(const Duration(days: 7))));
    final first = isStart ? now : (_startDate ?? now).add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(colorScheme: const ColorScheme.light(primary: _primary)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) _endDate = null;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_startDate == null || _endDate == null) {
      SnackBarHelper.warning('Please select start and end dates');
      return;
    }
    if (_durationDays < (_listing?.minDurationDays ?? 1)) {
      SnackBarHelper.warning('Minimum duration is ${_listing?.minDurationDays} days');
      return;
    }
    if (_listing?.maxDurationDays != null && _durationDays > _listing!.maxDurationDays!) {
      SnackBarHelper.warning('Maximum duration is ${_listing!.maxDurationDays} days');
      return;
    }

    final ok = await _ctrl.createBookingWithDates(
      listingId: widget.listingId,
      startDate: _dateOnly(_startDate!),
      endDate: _dateOnly(_endDate!),
      requestMessage: _messageCtrl.text.trim(),
      needsDelivery: _needsDelivery,
    );
    if (ok) setState(() => _bookingSuccess = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CustomLoader()),
      );
    }

    if (_listing == null) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(backgroundColor: _card, elevation: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _textDark), onPressed: () => Get.back())),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Iconsax.truck, size: 48, color: _textGrey),
            const SizedBox(height: 12),
            const Text('Listing not found', style: TextStyle(fontSize: 16, color: _textDark, fontFamily: 'Poppins')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadDetail, style: ElevatedButton.styleFrom(backgroundColor: _primary), child: const Text('Retry', style: TextStyle(color: Colors.white))),
          ]),
        ),
      );
    }

    if (_bookingSuccess) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildQuickStats(),
                  const SizedBox(height: 16),
                  if (_listing!.description?.isNotEmpty == true) ...[
                    _buildSection('About this vehicle', _listing!.description!),
                    const SizedBox(height: 16),
                  ],
                  _buildPricingCard(),
                  const SizedBox(height: 16),
                  _buildLocationCard(),
                  const SizedBox(height: 16),
                  _buildAvailabilityCard(),
                  const SizedBox(height: 16),
                  if (_listing!.terms?.isNotEmpty == true) ...[
                    _buildTermsCard(),
                    const SizedBox(height: 16),
                  ],
                  _buildBookingForm(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: _card,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)]),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textDark),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _listing!.vehicleImage != null
            ? Image.network(_listing!.vehicleImage!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imgPlaceholder())
            : _imgPlaceholder(),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: Text(_listing!.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark, fontFamily: 'Poppins')),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
              const SizedBox(width: 5),
              const Text('Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF22C55E), fontFamily: 'Poppins')),
            ]),
          ),
        ]),
        if (_listing!.vehicleName != null) ...[
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Iconsax.truck, size: 14, color: _textGrey),
            const SizedBox(width: 5),
            Text(
              [_listing!.vehicleName, _listing!.vehicleYear?.toString(), _listing!.vehicleRegistration]
                  .whereType<String>().join(' · '),
              style: const TextStyle(fontSize: 13, color: _textGrey, fontFamily: 'Poppins'),
            ),
          ]),
        ],
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(children: [
      _statCard('${_listing!.views}', 'Views', Iconsax.eye, const Color(0xFF3B82F6)),
      const SizedBox(width: 10),
      _statCard('${_listing!.bookingsCount}', 'Bookings', Iconsax.receipt_1, const Color(0xFF8B5CF6)),
      const SizedBox(width: 10),
      _statCard(
        _listing!.deliveryAvailable ? 'Yes' : 'No',
        'Delivery',
        Iconsax.truck_fast,
        _listing!.deliveryAvailable ? const Color(0xFF22C55E) : _textGrey,
      ),
    ]);
  }

  Widget _statCard(String val, String label, IconData icon, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 5),
            Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color, fontFamily: 'Poppins')),
            Text(label, style: const TextStyle(fontSize: 10, color: _textGrey, fontFamily: 'Poppins')),
          ]),
        ),
      );

  Widget _buildSection(String title, String content) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
            child: Text(content, style: const TextStyle(fontSize: 13, color: _textDark, height: 1.5, fontFamily: 'Poppins')),
          ),
        ],
      );

  Widget _buildPricingCard() {
    final l = _listing!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Pricing'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
          child: Column(children: [
            _pricingRow(
              Iconsax.wallet_3,
              'Lease Rate',
              l.pricingType == 'on_request'
                  ? 'On Request'
                  : '₹${l.priceAmount?.toStringAsFixed(0) ?? '0'} / ${_unitFull(l.priceUnit)}',
              _primary,
              isMain: true,
            ),
            if (l.securityDeposit != null && l.securityDeposit! > 0)
              _pricingRow(Iconsax.shield_tick, 'Security Deposit', '₹${l.securityDeposit!.toStringAsFixed(0)}', const Color(0xFF3B82F6)),
            if (l.deliveryAvailable && l.deliveryFee != null && l.deliveryFee! > 0)
              _pricingRow(Iconsax.truck_fast, 'Delivery Fee', '₹${l.deliveryFee!.toStringAsFixed(0)}', const Color(0xFF22C55E)),
            if (l.odometerReading != null)
              _pricingRow(Iconsax.speedometer, 'Odometer', '${l.odometerReading} km', _textGrey),
          ]),
        ),
      ],
    );
  }

  Widget _pricingRow(IconData icon, String label, String value, Color color, {bool isMain = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: _textGrey, fontFamily: 'Poppins'))),
          Text(value,
              style: TextStyle(
                  fontSize: isMain ? 16 : 13,
                  fontWeight: isMain ? FontWeight.w800 : FontWeight.w600,
                  color: isMain ? _primary : _textDark,
                  fontFamily: 'Poppins')),
        ]),
      );

  Widget _buildLocationCard() {
    final l = _listing!;
    if (l.pickupLocation?.isEmpty != false && !l.deliveryAvailable) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Location & Delivery'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
          child: Column(children: [
            if (l.pickupLocation?.isNotEmpty == true)
              _infoRow(Iconsax.location, 'Pickup', l.pickupLocation!, const Color(0xFF3B82F6)),
            if (l.deliveryAvailable) ...[
              _infoRow(Iconsax.truck_fast, 'Delivery', 'Available', const Color(0xFF22C55E)),
              if (l.deliveryRadius != null)
                _infoRow(Iconsax.radar, 'Radius', '${l.deliveryRadius!.toStringAsFixed(0)} km', _textGrey),
            ],
          ]),
        ),
      ],
    );
  }

  Widget _buildAvailabilityCard() {
    final l = _listing!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Availability'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
          child: Column(children: [
            if (l.availableFrom != null) _infoRow(Iconsax.calendar, 'From', _fmtDate(l.availableFrom), const Color(0xFF3B82F6)),
            if (l.availableUntil != null) _infoRow(Iconsax.calendar_remove, 'Until', _fmtDate(l.availableUntil), const Color(0xFFF59E0B)),
            if (l.minDurationDays != null) _infoRow(Iconsax.clock, 'Min Duration', '${l.minDurationDays} days', const Color(0xFF8B5CF6)),
            if (l.maxDurationDays != null) _infoRow(Iconsax.clock_1, 'Max Duration', '${l.maxDurationDays} days', _textGrey),
          ]),
        ),
      ],
    );
  }

  Widget _buildTermsCard() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Terms & Conditions'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Iconsax.info_circle, size: 16, color: Color(0xFFD97706)),
              const SizedBox(width: 8),
              Expanded(child: Text(_listing!.terms!, style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.5, fontFamily: 'Poppins'))),
            ]),
          ),
        ],
      );

  Widget _infoRow(IconData icon, String label, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13, color: _textGrey, fontFamily: 'Poppins')),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark, fontFamily: 'Poppins')),
        ]),
      );

  Widget _buildBookingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Book This Vehicle'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date pickers
              Row(children: [
                Expanded(child: _datePicker('Start Date', _startDate, () => _pickDate(isStart: true))),
                const SizedBox(width: 10),
                Expanded(child: _datePicker('End Date', _endDate, () => _pickDate(isStart: false))),
              ]),

              // Duration & cost estimate
              if (_startDate != null && _endDate != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(children: [
                    const Icon(Iconsax.calendar_1, size: 16, color: _primary),
                    const SizedBox(width: 8),
                    Text('$_durationDays days',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _primary, fontFamily: 'Poppins')),
                    const Spacer(),
                    if (_listing!.pricingType != 'on_request' && _estimatedTotal > 0)
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        const Text('Estimated total', style: TextStyle(fontSize: 10, color: _textGrey, fontFamily: 'Poppins')),
                        Text('₹${_estimatedTotal.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _primary, fontFamily: 'Poppins')),
                      ]),
                  ]),
                ),
              ],

              const SizedBox(height: 14),

              // Delivery toggle
              if (_listing!.deliveryAvailable) ...[
                GestureDetector(
                  onTap: () => setState(() => _needsDelivery = !_needsDelivery),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _needsDelivery ? const Color(0xFF22C55E).withValues(alpha: 0.08) : _bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _needsDelivery ? const Color(0xFF22C55E) : _border),
                    ),
                    child: Row(children: [
                      Icon(Iconsax.truck_fast, size: 18,
                          color: _needsDelivery ? const Color(0xFF22C55E) : _textGrey),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('Request Delivery',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark, fontFamily: 'Poppins'))),
                      Switch.adaptive(
                        value: _needsDelivery,
                        onChanged: (v) => setState(() => _needsDelivery = v),
                        activeThumbColor: Colors.white,
                        activeTrackColor: const Color(0xFF22C55E),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Message
              const Text('Message (optional)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _textGrey, fontFamily: 'Poppins')),
              const SizedBox(height: 6),
              TextField(
                controller: _messageCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tell the owner about your use case…',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF), fontFamily: 'Poppins'),
                  filled: true, fillColor: _bg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primary, width: 1.5)),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(fontSize: 13, color: _textDark, fontFamily: 'Poppins'),
              ),

              const SizedBox(height: 18),

              // Submit button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _ctrl.isActionLoading.value ? null : _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _ctrl.isActionLoading.value
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Text(
                              'Send Booking Request',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins'),
                            ),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _datePicker(String label, DateTime? date, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _textGrey, fontFamily: 'Poppins')),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: date != null ? _primaryLight : _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: date != null ? _primary.withValues(alpha: 0.4) : _border),
              ),
              child: Row(children: [
                Icon(Iconsax.calendar, size: 15, color: date != null ? _primary : _textGrey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date != null ? _fmtDate(date.toIso8601String()) : 'Select',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: date != null ? _primary : _textGrey, fontFamily: 'Poppins'),
                  ),
                ),
              ]),
            ),
          ],
        ),
      );

  Widget _buildSuccessScreen() => Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 90, height: 90,
                decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                child: const Icon(Iconsax.tick_circle, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text('Booking Request Sent!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textDark, fontFamily: 'Poppins')),
              const SizedBox(height: 10),
              const Text(
                'Your request has been sent to the vehicle owner.\nYou\'ll be notified once they respond.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _textGrey, height: 1.6, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                  ),
                  child: const Text('Back to Marketplace',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                },
                child: const Text('View My Leases', style: TextStyle(color: _textGrey, fontFamily: 'Poppins')),
              ),
            ]),
          ),
        ),
      );

  Widget _sectionTitle(String title) => Text(title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins'));

  Widget _imgPlaceholder() => Container(
        height: 260, width: double.infinity,
        color: const Color(0xFFF3F4F6),
        child: const Center(child: Icon(Iconsax.truck, size: 56, color: _textGrey)),
      );

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtDate(String? raw) {
    if (raw == null) return '—';
    try {
      final d = DateTime.parse(raw).toLocal();
      const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) { return raw; }
  }

  String _unitFull(String? unit) {
    switch (unit) {
      case 'daily': return 'day';
      case 'weekly': return 'week';
      case 'monthly': return 'month';
      default: return 'day';
    }
  }
}
