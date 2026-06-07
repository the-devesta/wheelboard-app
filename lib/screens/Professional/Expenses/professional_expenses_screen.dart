import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/expense_model.dart';
import '../../../services/expense_service.dart';
import '../../../theme/design_system.dart';
import '../../CompanyTransport/add_expense_screen.dart';

/// Professional expense tracking page — mirrors web `/professional/expenses`:
/// stat overview, category breakdown, search + filter and the expense list.
/// Built on the design system.
class ProfessionalExpensesScreen extends StatefulWidget {
  const ProfessionalExpensesScreen({super.key});

  @override
  State<ProfessionalExpensesScreen> createState() =>
      _ProfessionalExpensesScreenState();
}

class _ProfessionalExpensesScreenState
    extends State<ProfessionalExpensesScreen> {
  final _service = ExpenseService();
  final _searchCtrl = TextEditingController();

  List<Expense> _expenses = [];
  bool _loading = true;
  String? _error;
  String _category = 'all';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.getExpenses();
      if (mounted) {
        setState(() {
          _expenses = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  List<Expense> get _filtered {
    final q = _search.toLowerCase();
    return _expenses.where((e) {
      final matchCat = _category == 'all' || e.category == _category;
      final matchSearch = q.isEmpty ||
          e.description.toLowerCase().contains(q) ||
          (e.vehicle?.toLowerCase().contains(q) ?? false);
      return matchCat && matchSearch;
    }).toList();
  }

  double _sum(Iterable<Expense> xs) =>
      xs.fold(0.0, (s, e) => s + e.amount);

  Future<void> _add() async {
    await Get.to(() => const AddExpenseScreen(isProfessional: true));
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        backgroundColor: AppPalette.card,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppPalette.textDark),
          onPressed: () => Get.back(),
        ),
        centerTitle: false,
        title: Text('Expenses', style: AppText.h2),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Iconsax.add, size: 20),
        label: Text('Add Expense', style: AppText.subtitle.on(Colors.white)),
      ),
      body: _loading
          ? const AppLoading(message: 'Loading expenses…')
          : _error != null
              ? AppErrorState(message: _error!, onRetry: _fetch)
              : RefreshIndicator(
                  color: AppPalette.primary,
                  onRefresh: _fetch,
                  child: _body(),
                ),
    );
  }

  Widget _body() {
    final now = DateTime.now();
    final thisMonth = _sum(_expenses.where((e) =>
        e.date != null &&
        e.date!.month == now.month &&
        e.date!.year == now.year));
    final lastMonthDate = DateTime(now.year, now.month - 1);
    final lastMonth = _sum(_expenses.where((e) =>
        e.date != null &&
        e.date!.month == lastMonthDate.month &&
        e.date!.year == lastMonthDate.year));
    final pending = _sum(_expenses.where((e) => e.status == 'pending'));

    final filtered = _filtered;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _totalCard(_sum(_expenses)),
        AppSpacing.vGapMd,
        Row(children: [
          _miniStat('This Month', thisMonth, AppPalette.blue, Iconsax.calendar_1),
          AppSpacing.hGapMd,
          _miniStat('Last Month', lastMonth, AppPalette.textGrey, Iconsax.chart),
          AppSpacing.hGapMd,
          _miniStat('Pending', pending, AppPalette.amber, Iconsax.clock),
        ]),
        AppSpacing.vGapLg,
        _categoryBreakdown(),
        AppSpacing.vGapLg,
        _searchBar(),
        AppSpacing.vGapMd,
        _categoryFilter(),
        AppSpacing.vGapLg,
        Text('Recent Expenses (${filtered.length})', style: AppText.title),
        AppSpacing.vGapMd,
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: AppEmptyState(
              icon: Iconsax.receipt_1,
              title: 'No expenses found',
              subtitle: 'Tap “Add Expense” to log your first one.',
            ),
          )
        else
          ...filtered.map(_expenseTile),
      ],
    );
  }

  Widget _totalCard(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppPalette.brandGradient,
        borderRadius: AppRadius.rXl,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: AppRadius.rMd),
            child: const Icon(Iconsax.money_recive, color: Colors.white, size: 22),
          ),
          AppSpacing.hGapMd,
          Text('Total Expenses', style: AppText.subtitle.on(Colors.white)),
        ]),
        AppSpacing.vGapMd,
        Text('₹${_fmt(total)}',
            style: AppText.h1.on(Colors.white).size(30)),
      ]),
    );
  }

  Widget _miniStat(String label, double value, Color color, IconData icon) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: color),
          AppSpacing.vGapSm,
          Text('₹${_fmt(value)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.subtitle.on(color)),
          Text(label, style: AppText.micro.weight(FontWeight.w400)),
        ]),
      ),
    );
  }

  Widget _categoryBreakdown() {
    final totals = <String, double>{};
    for (final e in _expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    final entries = totals.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.isEmpty) return const SizedBox.shrink();
    final maxVal = entries.first.value;

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Iconsax.chart_2, size: 16, color: AppPalette.primary),
          AppSpacing.hGapSm,
          Text('By Category', style: AppText.title),
        ]),
        AppSpacing.vGapMd,
        ...entries.map((e) {
          final cfg = ExpenseCategoryConfig.of(e.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(cfg.icon, size: 14, color: cfg.color),
                AppSpacing.hGapSm,
                Expanded(child: Text(cfg.label, style: AppText.label)),
                Text('₹${_fmt(e.value)}',
                    style: AppText.label.on(AppPalette.textDark).weight(FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: maxVal == 0 ? 0 : e.value / maxVal,
                  minHeight: 6,
                  backgroundColor: AppPalette.border,
                  valueColor: AlwaysStoppedAnimation(cfg.color),
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: _searchCtrl,
      onChanged: (v) => setState(() => _search = v),
      style: AppText.bodySm.on(AppPalette.textDark),
      decoration: InputDecoration(
        hintText: 'Search expenses…',
        hintStyle: AppText.caption,
        prefixIcon: const Icon(Iconsax.search_normal_1, size: 18, color: AppPalette.textGrey),
        filled: true,
        fillColor: AppPalette.card,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _categoryFilter() {
    final options = ['all', ...ExpenseCategoryConfig.keys];
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: options.map((c) {
          final active = _category == c;
          final label = c == 'all' ? 'All' : ExpenseCategoryConfig.of(c).label;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _category = c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppPalette.primary : AppPalette.card,
                  borderRadius: AppRadius.rPill,
                  border: Border.all(
                      color: active ? AppPalette.primary : AppPalette.border),
                ),
                child: Text(label,
                    style: AppText.label.on(
                        active ? Colors.white : AppPalette.textGrey)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _expenseTile(Expense e) {
    final cfg = ExpenseCategoryConfig.of(e.category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: cfg.color.withValues(alpha: 0.12),
                borderRadius: AppRadius.rMd),
            child: Icon(cfg.icon, color: cfg.color, size: 20),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(
                      e.description.isNotEmpty ? e.description : cfg.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.subtitle),
                ),
                _statusBadge(e.status),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Iconsax.calendar_1, size: 11, color: AppPalette.textGrey),
                const SizedBox(width: 4),
                Text(e.date != null ? _fmtDate(e.date!) : '—',
                    style: AppText.caption),
                if (e.tripId != null && e.tripId!.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  const Icon(Iconsax.routing, size: 11, color: AppPalette.textGrey),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(e.tripId!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption),
                  ),
                ],
              ]),
            ]),
          ),
          AppSpacing.hGapSm,
          Text('₹${_fmt(e.amount)}',
              style: AppText.subtitle.on(AppPalette.primary)),
        ]),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color c;
    switch (status) {
      case 'paid':
        c = AppPalette.green;
        break;
      case 'overdue':
        c = AppPalette.danger;
        break;
      default:
        c = AppPalette.amber;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: AppRadius.rPill,
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Text(
          status.isEmpty ? '' : '${status[0].toUpperCase()}${status.substring(1)}',
          style: AppText.micro.on(c)),
    );
  }

  String _fmt(double v) {
    final s = v.toStringAsFixed(0);
    // Indian-style grouping (e.g. 1,23,456).
    final buf = StringBuffer();
    final digits = s.split('');
    for (var i = 0; i < digits.length; i++) {
      final posFromEnd = digits.length - i;
      buf.write(digits[i]);
      if (posFromEnd > 1) {
        if (posFromEnd == 4 || (posFromEnd > 4 && (posFromEnd - 4) % 2 == 1)) {
          buf.write(',');
        }
      }
    }
    return buf.toString();
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final l = d.toLocal();
    return '${m[l.month - 1]} ${l.day}, ${l.year}';
  }
}
