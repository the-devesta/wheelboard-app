import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../controllers/ServiceProvider/service_earnings_controller.dart';
import '../../theme/design_system.dart';
import '../../widgets/custom_snackbar.dart';

/// Register a manual (offline) payment — mirrors wheelboard-fe
/// `RegisterPaymentModal`. Posts to `/services/payments/manual` via the
/// earnings controller.
class RegisterPaymentScreen extends StatefulWidget {
  const RegisterPaymentScreen({super.key});

  @override
  State<RegisterPaymentScreen> createState() => _RegisterPaymentScreenState();
}

class _RegisterPaymentScreenState extends State<RegisterPaymentScreen> {
  late final ServiceEarningsController _c;

  final _purposeCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _serviceId;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _c = Get.isRegistered<ServiceEarningsController>()
        ? Get.find<ServiceEarningsController>()
        : Get.put(ServiceEarningsController());
    _c.fetchUserServices();
    ever(_c.userServices, (services) {
      if (services.isNotEmpty && _serviceId == null && mounted) {
        setState(() => _serviceId = services.first['serviceId']);
      }
    });
  }

  @override
  void dispose() {
    _purposeCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        backgroundColor: AppPalette.card,
        elevation: 0.5,
        leading: const BackButton(color: AppPalette.textDark),
        centerTitle: false,
        title: Text('Register Payment', style: AppText.h2),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(Iconsax.wallet_money, 'Payment Details'),
                AppSpacing.vGapLg,
                _label('Purpose of Payment *'),
                _input(_purposeCtrl, hint: 'e.g., Tyre fitting charge'),
                AppSpacing.vGapLg,
                _label('Payment Amount *'),
                _input(_amountCtrl,
                    hint: '0.00',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 14, right: 4),
                      child: Text('₹',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.primary)),
                    )),
              ],
            ),
          ),
          AppSpacing.vGapLg,
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(Iconsax.setting_4, 'Service Information'),
                AppSpacing.vGapLg,
                _label('Linked Service *'),
                _serviceDropdown(),
                AppSpacing.vGapLg,
                _label('Payment Date'),
                _dateField(),
              ],
            ),
          ),
          AppSpacing.vGapLg,
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(Iconsax.note_1, 'Notes'),
                AppSpacing.vGapLg,
                _label('Payment Notes (optional)'),
                _input(_notesCtrl,
                    hint: 'Add any additional notes…', maxLines: 4),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: AppPalette.card,
          border: Border(top: BorderSide(color: AppPalette.border)),
        ),
        child: Obx(() => AppPrimaryButton(
              label: 'Save Payment',
              icon: Iconsax.tick_circle,
              loading: _c.isRecordingPayment.value,
              onPressed: _save,
            )),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(children: [
      Icon(icon, size: 18, color: AppPalette.primary),
      AppSpacing.hGapSm,
      Text(title, style: AppText.title),
    ]);
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: AppText.label),
      );

  Widget _input(
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? prefix,
  }) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
        borderRadius: AppRadius.rLg, borderSide: BorderSide(color: c));
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppText.body.on(AppPalette.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.body.on(AppPalette.textFaint),
        prefixIcon: prefix,
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: AppPalette.bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: border(AppPalette.border),
        enabledBorder: border(AppPalette.border),
        focusedBorder: border(AppPalette.primary),
      ),
    );
  }

  Widget _serviceDropdown() {
    return Obx(() {
      final services = _c.userServices;
      final fallback = _c.dashboardData.value?.serviceBreakdown ?? const [];
      final items = services.isNotEmpty
          ? services
              .map((s) => DropdownMenuItem(
                    value: s['serviceId'],
                    child: Text(s['serviceTitle'] ?? 'Service',
                        style: AppText.body.on(AppPalette.textDark),
                        overflow: TextOverflow.ellipsis),
                  ))
              .toList()
          : fallback
              .map((s) => DropdownMenuItem(
                    value: s.serviceId,
                    child: Text(s.serviceTitle,
                        style: AppText.body.on(AppPalette.textDark),
                        overflow: TextOverflow.ellipsis),
                  ))
              .toList();

      if (items.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppPalette.bg, borderRadius: AppRadius.rLg),
          child: Text('No services available. Add a service first.',
              style: AppText.caption),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppPalette.bg,
          borderRadius: AppRadius.rLg,
          border: Border.all(color: AppPalette.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _serviceId,
            isExpanded: true,
            icon: const Icon(Iconsax.arrow_down_1, size: 18),
            hint: Text('Select service',
                style: AppText.body.on(AppPalette.textFaint)),
            onChanged: (v) => setState(() => _serviceId = v),
            items: items,
          ),
        ),
      );
    });
  }

  Widget _dateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppPalette.bg,
          borderRadius: AppRadius.rLg,
          border: Border.all(color: AppPalette.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd MMM yyyy').format(_date),
                style: AppText.body.on(AppPalette.textDark)),
            const Icon(Iconsax.calendar_1,
                size: 18, color: AppPalette.textFaint),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_purposeCtrl.text.trim().isEmpty ||
        _amountCtrl.text.trim().isEmpty ||
        _serviceId == null) {
      SnackBarHelper.error('Please fill in all required fields.');
      return;
    }
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      SnackBarHelper.error('Please enter a valid payment amount.');
      return;
    }

    final ok = await _c.recordPayment(
      serviceId: _serviceId!,
      amount: amount,
      purpose: _purposeCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      date: _date,
    );

    if (ok && mounted) Navigator.of(context).pop();
  }
}
