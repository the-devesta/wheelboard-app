import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../controllers/Professional/expense_controller.dart';
import '../../controllers/Transport/add_trip_controller.dart';
import '../../controllers/Professional/assigned_trip_controller.dart';
import '../../models/add_new_trip_model.dart';
import '../../models/assigned_trip_model.dart';
import '../../widgets/custom_snackbar.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import '../../services/media_service.dart';
import '../../utils/app_logger.dart';

/// Add Expense — rewritten to mirror wheelboard-fe `/professional/expenses/add`.
///
/// Same flow & payload as the web: pick a category (fixed enum), amount, date,
/// optional description, a trip, optional receipt → `POST /expenses` (JSON, via
/// [ExpenseController.saveExpense]). The web has no "hired" restriction, so the
/// old gate is removed — every user can add expenses.
class AddExpenseScreen extends StatefulWidget {
  final bool isProfessional;

  const AddExpenseScreen({super.key, this.isProfessional = false});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  static const _primary = Color(0xFFF36969);
  static const _primaryLt = Color(0xFFFFF1F1);
  static const _bg = Color(0xFFF9FAFB);
  static const _textDark = Color(0xFF111827);
  static const _textGrey = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);

  /// Category set mirrors the web add-expense page (ids = backend enum values).
  static const _categories = <_Cat>[
    _Cat('fuel', 'Fuel', '⛽'),
    _Cat('food', 'Food', '🍔'),
    _Cat('maintenance', 'Vehicle Repair', '🔧'),
    _Cat('toll', 'Toll', '🛣️'),
    _Cat('challan', 'Challan', '🚨'),
    _Cat('parking', 'Parking', '🅿️'),
    _Cat('advance', 'Advance', '💰'),
    _Cat('other', 'Others', '📦'),
  ];

  final ExpenseController _expenseController = Get.put(ExpenseController());
  late dynamic _tripController;
  bool _localIsProfessional = false;

  String? _selectedCategory;
  dynamic _selectedTrip; // AssignedTrip | Trip
  DateTime _selectedDate = DateTime.now();
  File? _receiptFile;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _localIsProfessional = widget.isProfessional;
    if (Get.find<AuthService>().isProfessional) _localIsProfessional = true;

    if (_localIsProfessional) {
      _tripController = Get.put(AssignedTripController());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        (_tripController as AssignedTripController).fetchAssignedTrips();
      });
    } else {
      _tripController = Get.put(TripController());
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCompanyTrips());
    }
  }

  Future<void> _fetchCompanyTrips() async {
    final userId = AuthService.to.currentUserId;
    if (userId.isNotEmpty && _tripController is TripController) {
      await (_tripController as TripController).fetchTrips(userId);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ── helpers ────────────────────────────────────────────────────────────────
  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
  }

  String? _tripLabel() {
    final t = _selectedTrip;
    if (t == null) return null;
    if (t is AssignedTrip) return '${t.pickupLocation} → ${t.deliveryLocation}';
    if (t is Trip) return '${t.pickupLocation} → ${t.deliveryLocation}';
    return null;
  }

  String? _tripIdOf(dynamic t) {
    if (t is AssignedTrip) return t.tripId;
    if (t is Trip) return t.id.isNotEmpty ? t.id : t.tripId;
    return null;
  }

  bool get _isValid =>
      _selectedCategory != null &&
      (double.tryParse(_amountController.text) ?? 0) > 0 &&
      _selectedTrip != null;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx)
            .copyWith(colorScheme: const ColorScheme.light(primary: _primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickReceipt() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() => _receiptFile = File(result.files.single.path!));
      }
    } catch (e) {
      AppLogger.d('Receipt pick failed: $e');
    }
  }

  Future<void> _save() async {
    if (_expenseController.isSaving.value) return;
    if (_selectedCategory == null) {
      SnackBarHelper.warning('Please select a category');
      return;
    }
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      SnackBarHelper.warning('Please enter a valid amount');
      return;
    }
    if (_selectedTrip == null) {
      SnackBarHelper.warning('Please choose a trip');
      return;
    }

    // Upload the receipt (if any) to Firebase via the unified /media endpoint
    // and persist the hosted URL. Previously only the file NAME was sent, so the
    // receipt was never actually stored (the Receipt column is 500 chars — a
    // base64 payload would not fit either).
    String? receiptUrl;
    if (_receiptFile != null) {
      try {
        final media = await MediaService.upload(
          _receiptFile!,
          folder: 'expense-receipts',
        );
        receiptUrl = media?.url;
      } catch (e) {
        AppLogger.e('Receipt upload failed: $e');
        SnackBarHelper.error('Failed to upload receipt. Please try again.');
        return;
      }
    }

    final ok = await _expenseController.saveExpense(
      category: _selectedCategory!,
      expenseDate: _selectedDate,
      amount: amount,
      description: _descriptionController.text.trim().isEmpty
          ? _categories.firstWhere((c) => c.id == _selectedCategory).name
          : _descriptionController.text.trim(),
      tripId: _tripIdOf(_selectedTrip),
      receipt: receiptUrl,
      paymentMethod: 'cash',
    );

    if (ok && mounted) Navigator.pop(context, true);
  }

  // ── trip selector (scrollable bottom sheet — no overflow) ───────────────────
  void _showTripSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (ctx, scrollCtrl) => Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Select Trip',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _textDark)),
              ),
            ),
            Expanded(
              child: Obx(() {
                final loading = _localIsProfessional
                    ? (_tripController as AssignedTripController).isLoading.value
                    : (_tripController as TripController).isTripsLoading.value;
                final List trips = _localIsProfessional
                    ? (_tripController as AssignedTripController).assignedTrips
                    : (_tripController as TripController).trips;

                if (loading) {
                  return const Center(
                      child: CircularProgressIndicator(color: _primary));
                }
                if (trips.isEmpty) {
                  return const Center(
                    child: Text('No trips available',
                        style: TextStyle(
                            fontFamily: 'Poppins', color: _textGrey)),
                  );
                }
                return ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: trips.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final t = trips[i];
                    final from = t is AssignedTrip
                        ? t.pickupLocation
                        : (t as Trip).pickupLocation;
                    final to = t is AssignedTrip
                        ? t.deliveryLocation
                        : (t as Trip).deliveryLocation;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedTrip = t);
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: Row(children: [
                          const Icon(Icons.local_shipping_outlined,
                              size: 20, color: _primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('$from → $to',
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _textDark)),
                          ),
                        ]),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: _textDark),
        title: const Text('Add Expense',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _textDark)),
        centerTitle: true,
        shape: const Border(bottom: BorderSide(color: _border)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              label: 'Category',
              required: true,
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 3,
                children: _categories.map((c) {
                  final sel = _selectedCategory == c.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = c.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: sel ? _primaryLt : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? _primary : _border,
                          width: sel ? 1.6 : 1,
                        ),
                      ),
                      child: Row(children: [
                        Text(c.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(c.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: sel ? _primary : _textDark)),
                        ),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              label: 'Amount',
              required: true,
              child: TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: _textDark),
                decoration: _inputDecoration('0.00', prefix: '₹  '),
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              label: 'Date',
              required: true,
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: _textGrey),
                    const SizedBox(width: 10),
                    Text(_fmtDate(_selectedDate),
                        style: const TextStyle(
                            fontFamily: 'Poppins', color: _textDark)),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              label: 'Description',
              optional: true,
              child: TextField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                style: const TextStyle(fontFamily: 'Poppins', color: _textDark),
                decoration:
                    _inputDecoration('Describe this expense... (optional)'),
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              label: 'Choose Trip',
              required: true,
              child: GestureDetector(
                onTap: _showTripSelector,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text(_tripLabel() ?? 'Select a trip...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: _selectedTrip != null
                                  ? _textDark
                                  : _textGrey)),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: _textGrey),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              label: 'Upload Receipt',
              optional: true,
              child: GestureDetector(
                onTap: _pickReceipt,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: Row(children: [
                    const Icon(Icons.attach_file, size: 18, color: _primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          _receiptFile != null
                              ? _receiptFile!.path
                                  .split(Platform.pathSeparator)
                                  .last
                              : 'Upload receipt (.jpg, .png, .pdf)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: _receiptFile != null
                                  ? _textDark
                                  : _textGrey)),
                    ),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: _border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: _textGrey)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() {
                  final saving = _expenseController.isSaving.value;
                  final enabled = _isValid && !saving;
                  return ElevatedButton(
                    onPressed: enabled ? _save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      disabledBackgroundColor: _primary.withValues(alpha: 0.4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save Expense',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700)),
                  );
                }),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String label,
    required Widget child,
    bool required = false,
    bool optional = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textDark)),
            if (required)
              const Text(' *', style: TextStyle(color: _primary)),
            if (optional)
              const Text('  (optional)',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 11, color: _textGrey)),
          ]),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      prefixStyle: const TextStyle(
          fontFamily: 'Poppins', color: _textGrey, fontWeight: FontWeight.w600),
      hintStyle: const TextStyle(fontFamily: 'Poppins', color: _textGrey),
      filled: true,
      fillColor: _bg,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
    );
  }
}

class _Cat {
  final String id;
  final String name;
  final String emoji;
  const _Cat(this.id, this.name, this.emoji);
}
