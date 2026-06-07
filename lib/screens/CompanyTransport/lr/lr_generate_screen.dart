import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/lr_model.dart';
import '../../../services/lr_service.dart';

// ── Design tokens (match Trips / Fleet) ────────────────────────────────────────
const _primary = Color(0xFFF36969);
const _primaryLt = Color(0xFFFFF1F1);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _green = Color(0xFF22C55E);
const _orange = Color(0xFFF59E0B);

enum LrFormMode { generate, update }

/// Fleet-owner Lorry Receipt form — generate a new LR (draft trip) or update a
/// rejected LR and resend it to the driver.
///
/// Posts the backend-correct nested payload
/// `{ consignor, consignee, cargo, charges }` to:
///   POST  /trips/:id/lr/generate   (generate)
///   PATCH /trips/:id/lr            (update)
class LrGenerateScreen extends StatefulWidget {
  final String tripId;
  final LrFormMode mode;
  const LrGenerateScreen({
    super.key,
    required this.tripId,
    this.mode = LrFormMode.generate,
  });

  @override
  State<LrGenerateScreen> createState() => _LrGenerateScreenState();
}

class _LrGenerateScreenState extends State<LrGenerateScreen> {
  final _service = LrService();
  final _formKey = GlobalKey<FormState>();

  // Consignor
  final _cnrName = TextEditingController();
  final _cnrPerson = TextEditingController();
  final _cnrPhone = TextEditingController();
  final _cnrAddress = TextEditingController();
  final _cnrGstin = TextEditingController();
  final _cnrEmail = TextEditingController();

  // Consignee
  final _cneName = TextEditingController();
  final _cnePerson = TextEditingController();
  final _cnePhone = TextEditingController();
  final _cneAddress = TextEditingController();
  final _cneGstin = TextEditingController();
  final _cneEmail = TextEditingController();

  // Cargo
  final _cargoDesc = TextEditingController();
  final _cargoWeight = TextEditingController();
  final _cargoQty = TextEditingController();
  final _cargoPackaging = TextEditingController();
  final _cargoValue = TextEditingController();
  final _cargoNotes = TextEditingController();

  // Charges
  final _freight = TextEditingController();
  final _gst = TextEditingController();
  final _other = TextEditingController();
  String _paymentMode = 'to-pay';

  bool _loadingExisting = false;
  bool _submitting = false;
  String? _rejectionReason;

  bool get _isUpdate => widget.mode == LrFormMode.update;

  @override
  void initState() {
    super.initState();
    for (final c in [_freight, _gst, _other]) {
      c.addListener(() => setState(() {}));
    }
    if (_isUpdate) _prefillFromExisting();
  }

  @override
  void dispose() {
    for (final c in [
      _cnrName, _cnrPerson, _cnrPhone, _cnrAddress, _cnrGstin, _cnrEmail,
      _cneName, _cnePerson, _cnePhone, _cneAddress, _cneGstin, _cneEmail,
      _cargoDesc, _cargoWeight, _cargoQty, _cargoPackaging, _cargoValue, _cargoNotes,
      _freight, _gst, _other,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _prefillFromExisting() async {
    setState(() => _loadingExisting = true);
    try {
      final lr = await _service.getLR(widget.tripId);
      final cnr = lr.consignor, cne = lr.consignee, cargo = lr.cargo, ch = lr.charges;
      if (cnr != null) {
        _cnrName.text = cnr.name;
        _cnrPerson.text = cnr.contactPerson;
        _cnrPhone.text = cnr.contactPhone;
        _cnrAddress.text = cnr.address;
        _cnrGstin.text = cnr.gstin ?? '';
        _cnrEmail.text = cnr.email ?? '';
      }
      if (cne != null) {
        _cneName.text = cne.name;
        _cnePerson.text = cne.contactPerson;
        _cnePhone.text = cne.contactPhone;
        _cneAddress.text = cne.address;
        _cneGstin.text = cne.gstin ?? '';
        _cneEmail.text = cne.email ?? '';
      }
      if (cargo != null) {
        _cargoDesc.text = cargo.description;
        _cargoWeight.text = _trimNum(cargo.totalWeight);
        _cargoQty.text = cargo.totalQuantity != null ? _trimNum(cargo.totalQuantity!) : '';
        _cargoPackaging.text = cargo.packagingType ?? '';
        _cargoValue.text = cargo.declaredValue != null ? _trimNum(cargo.declaredValue!) : '';
        _cargoNotes.text = cargo.specialInstructions ?? '';
      }
      if (ch != null) {
        _freight.text = _trimNum(ch.freightAmount);
        _gst.text = _trimNum(ch.gst);
        _other.text = ch.otherCharges != null ? _trimNum(ch.otherCharges!) : '';
        _paymentMode = ch.paymentMode;
      }
      _rejectionReason = lr.driverConfirmation?.rejectionReason;
    } catch (_) {
      // Non-fatal: start with an empty form if the existing LR can't be loaded.
    } finally {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  String _trimNum(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  double get _totalAmount {
    double p(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;
    return p(_freight) + p(_gst) + p(_other);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_totalAmount <= 0) {
      _toast('Enter valid freight charges', _orange);
      return;
    }
    setState(() => _submitting = true);

    final payload = GenerateLrPayload(
      consignor: LrParty(
        name: _cnrName.text.trim(),
        address: _cnrAddress.text.trim(),
        gstin: _cnrGstin.text.trim(),
        contactPerson: _cnrPerson.text.trim(),
        contactPhone: _cnrPhone.text.trim(),
        email: _cnrEmail.text.trim(),
      ),
      consignee: LrParty(
        name: _cneName.text.trim(),
        address: _cneAddress.text.trim(),
        gstin: _cneGstin.text.trim(),
        contactPerson: _cnePerson.text.trim(),
        contactPhone: _cnePhone.text.trim(),
        email: _cneEmail.text.trim(),
      ),
      cargo: LrCargo(
        description: _cargoDesc.text.trim(),
        totalWeight: double.tryParse(_cargoWeight.text.trim()) ?? 0,
        totalQuantity: double.tryParse(_cargoQty.text.trim()),
        declaredValue: double.tryParse(_cargoValue.text.trim()),
        packagingType: _cargoPackaging.text.trim(),
        specialInstructions: _cargoNotes.text.trim(),
      ),
      charges: LrCharges(
        freightAmount: double.tryParse(_freight.text.trim()) ?? 0,
        gst: double.tryParse(_gst.text.trim()) ?? 0,
        otherCharges: double.tryParse(_other.text.trim()),
        totalAmount: _totalAmount,
        paymentMode: _paymentMode,
      ),
    );

    try {
      if (_isUpdate) {
        await _service.updateLR(widget.tripId, payload);
      } else {
        await _service.generateLR(widget.tripId, payload);
      }
      _toast(_isUpdate ? 'LR updated and sent to driver' : 'LR generated and sent to driver', _green);
      Get.back(result: true);
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''), const Color(0xFFEF4444));
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _toast(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _header(),
          Expanded(
            child: _loadingExisting
                ? const Center(child: CircularProgressIndicator(color: _primary))
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        if (_isUpdate && (_rejectionReason?.isNotEmpty ?? false))
                          _rejectionBanner(),
                        _section(
                          icon: Iconsax.box,
                          title: 'Consignor (Shipper)',
                          children: [
                            _field(_cnrName, 'Business name', required: true),
                            _field(_cnrPerson, 'Contact person', required: true),
                            _field(_cnrPhone, 'Contact phone',
                                required: true, keyboard: TextInputType.phone),
                            _field(_cnrAddress, 'Pickup address',
                                required: true, maxLines: 2),
                            _field(_cnrGstin, 'GSTIN (optional)'),
                            _field(_cnrEmail, 'Email (optional)',
                                keyboard: TextInputType.emailAddress),
                          ],
                        ),
                        _section(
                          icon: Iconsax.location,
                          title: 'Consignee (Receiver)',
                          children: [
                            _field(_cneName, 'Business name', required: true),
                            _field(_cnePerson, 'Contact person', required: true),
                            _field(_cnePhone, 'Contact phone',
                                required: true, keyboard: TextInputType.phone),
                            _field(_cneAddress, 'Delivery address',
                                required: true, maxLines: 2),
                            _field(_cneGstin, 'GSTIN (optional)'),
                            _field(_cneEmail, 'Email (optional)',
                                keyboard: TextInputType.emailAddress),
                          ],
                        ),
                        _section(
                          icon: Iconsax.box_1,
                          title: 'Cargo Details',
                          children: [
                            _field(_cargoDesc, 'Goods description', required: true),
                            Row(children: [
                              Expanded(
                                  child: _field(_cargoWeight, 'Weight (kg)',
                                      required: true, keyboard: _numKb)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _field(_cargoQty, 'Quantity', keyboard: _numKb)),
                            ]),
                            _field(_cargoPackaging, 'Packaging type (optional)'),
                            _field(_cargoValue, 'Declared value ₹ (optional)',
                                keyboard: _numKb),
                            _field(_cargoNotes, 'Special instructions (optional)',
                                maxLines: 2),
                          ],
                        ),
                        _section(
                          icon: Iconsax.money_recive,
                          title: 'Freight Charges',
                          children: [
                            Row(children: [
                              Expanded(
                                  child: _field(_freight, 'Freight ₹',
                                      required: true, keyboard: _numKb)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _field(_gst, 'GST ₹',
                                      required: true, keyboard: _numKb)),
                            ]),
                            _field(_other, 'Other charges ₹ (optional)', keyboard: _numKb),
                            const SizedBox(height: 4),
                            _totalRow(),
                            const SizedBox(height: 14),
                            _paymentModeSelector(),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _submitButton(),
                      ],
                    ),
                  ),
          ),
        ]),
      ),
    );
  }

  TextInputType get _numKb =>
      const TextInputType.numberWithOptions(decimal: true);

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, Color(0xFFE85555)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_isUpdate ? 'Update Lorry Receipt' : 'Generate Lorry Receipt',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(_isUpdate
                ? 'Fix the details and resend to the driver'
                : 'Create the LR and send it to the driver',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
          ]),
        ),
      ]),
    );
  }

  Widget _rejectionBanner() => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Iconsax.warning_2, size: 18, color: Color(0xFFB91C1C)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Driver rejected this LR',
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFB91C1C))),
              const SizedBox(height: 2),
              Text(_rejectionReason!,
                  style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF991B1B))),
            ]),
          ),
        ]),
      );

  Widget _section({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: _primaryLt, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: _primary),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
        ]),
        const SizedBox(height: 14),
        ...children,
      ]),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        inputFormatters: keyboard == _numKb
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
            : null,
        style: GoogleFonts.poppins(fontSize: 13, color: _textDark),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 13, color: _textGrey),
          floatingLabelStyle: GoogleFonts.poppins(fontSize: 13, color: _primary),
          filled: true,
          fillColor: _bg,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _primary, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEF4444)),
          ),
        ),
      ),
    );
  }

  Widget _totalRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _primaryLt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Total amount',
            style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
        Text('₹${_trimNum(_totalAmount)}',
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w800, color: _primary)),
      ]),
    );
  }

  Widget _paymentModeSelector() {
    const modes = [
      ('to-pay', 'To Pay'),
      ('paid', 'Paid'),
      ('to-be-billed', 'To Bill'),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Payment mode',
          style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
      const SizedBox(height: 8),
      Row(
        children: [
          for (final m in modes) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _paymentMode = m.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _paymentMode == m.$1 ? _primary : _bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _paymentMode == m.$1 ? _primary : _border),
                  ),
                  child: Text(m.$2,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _paymentMode == m.$1 ? Colors.white : _textGrey)),
                ),
              ),
            ),
            if (m != modes.last) const SizedBox(width: 8),
          ],
        ],
      ),
    ]);
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _submitting ? null : _submit,
        icon: _submitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Iconsax.document_upload, size: 18),
        label: Text(_isUpdate ? 'Update & Resend LR' : 'Generate & Send LR',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }
}
