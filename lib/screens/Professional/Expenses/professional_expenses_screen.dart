import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/Transport/dashboard_controller.dart';
import '../../../models/expense_model.dart';
import '../../../services/expense_service.dart';
import '../../../theme/design_system.dart';
import '../../CompanyTransport/add_expense_screen.dart';

/// Expense tracking page — mirrors web `/professional/expenses` AND
/// `/company/expenses` (the two are identical: stat overview, category
/// breakdown, search + filter, add + delete). Shared by both the Professional
/// and the Company (transport) personas; [isProfessional] only routes the
/// Add-Expense screen to the correct trip controller.
class ProfessionalExpensesScreen extends StatefulWidget {
  final bool isProfessional;
  const ProfessionalExpensesScreen({super.key, this.isProfessional = true});

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
  String _status = 'all';
  String _search = '';

  /// Selected trip keys. Empty means "all trips".
  final Set<String> _tripKeys = <String>{};

  ExpenseSortField _sortField = ExpenseSortField.date;
  bool _sortAscending = false;
  bool _groupByTrip = false;

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

  /// Filtered AND sorted. Everything runs over the already-loaded list so a
  /// chip tap is instant and never re-hits the API.
  List<Expense> get _filtered {
    final q = _search.toLowerCase();
    final matched = _expenses.where((e) {
      final matchCat = _category == 'all' || e.category == _category;
      final matchStatus = _status == 'all' || e.status == _status;
      final matchTrip = _tripKeys.isEmpty || _tripKeys.contains(e.tripKey);
      final matchSearch = q.isEmpty ||
          e.description.toLowerCase().contains(q) ||
          (e.vehicle?.toLowerCase().contains(q) ?? false) ||
          e.category.toLowerCase().contains(q) ||
          (e.hasTrip && e.tripKey.toLowerCase().contains(q)) ||
          (e.tripRouteLabel?.toLowerCase().contains(q) ?? false);
      return matchCat && matchStatus && matchTrip && matchSearch;
    }).toList();

    return sortExpenses(matched,
        field: _sortField, ascending: _sortAscending);
  }

  List<ExpenseTripOption> get _tripOptions =>
      buildExpenseTripOptions(_expenses);

  int get _activeFilterCount =>
      (_category != 'all' ? 1 : 0) +
      (_status != 'all' ? 1 : 0) +
      (_tripKeys.isNotEmpty ? 1 : 0) +
      (_search.trim().isNotEmpty ? 1 : 0);

  void _clearFilters() {
    setState(() {
      _category = 'all';
      _status = 'all';
      _tripKeys.clear();
      _search = '';
      _searchCtrl.clear();
    });
  }

  double _sum(Iterable<Expense> xs) =>
      xs.fold(0.0, (s, e) => s + e.amount);

  Future<void> _add() async {
    await Get.to(() => AddExpenseScreen(isProfessional: widget.isProfessional));
    _fetch();
  }

  /// Confirms + performs the delete. Returns whether the backend delete
  /// succeeded so the [Dismissible] only animates the row out on success
  /// (the actual list/stat/dashboard refresh happens in `onDismissed`).
  ///
  /// IMPORTANT: this must NOT mutate `_expenses` itself — doing so while also
  /// returning `true` to `confirmDismiss` removes the row twice and trips
  /// Flutter's "A dismissed Dismissible widget is still part of the tree"
  /// assertion, which is what made delete appear to "do nothing".
  Future<bool> _confirmDelete(Expense e) async {
    final ok = await Get.dialog<bool>(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete expense?', style: AppText.title),
      content: Text(
        'This will permanently remove "${e.description.isNotEmpty ? e.description : ExpenseCategoryConfig.of(e.category).label}".',
        style: AppText.body.on(AppPalette.textGrey),
      ),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false),
            child:
                Text('Cancel', style: AppText.label.on(AppPalette.textGrey))),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(backgroundColor: AppPalette.danger),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
    if (ok != true) return false;
    return _service.deleteExpense(e.id);
  }

  /// Called once the row has actually been dismissed (delete confirmed by the
  /// backend). Drops it from the in-memory list — which instantly updates the
  /// totals, category breakdown and chart, all derived from `_expenses` — and
  /// pushes the company dashboard totals back in sync.
  void _onDeleted(Expense e) {
    setState(() => _expenses.removeWhere((x) => x.id == e.id));
    DashboardController.refreshIfActive();
  }

  /// Mark an expense as Paid (PATCH /expenses/:id). Refreshes the list so the
  /// new status — and the Pending total — update immediately.
  Future<void> _markPaid(Expense e) async {
    final ok = await Get.dialog<bool>(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Mark as paid?', style: AppText.title),
      content: Text(
        'Update "${e.description.isNotEmpty ? e.description : ExpenseCategoryConfig.of(e.category).label}" to Paid.',
        style: AppText.body.on(AppPalette.textGrey),
      ),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false),
            child:
                Text('Cancel', style: AppText.label.on(AppPalette.textGrey))),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(backgroundColor: AppPalette.green),
          child: const Text('Mark Paid', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
    if (ok != true) return;
    final success = await _service.updateStatus(e.id, 'paid');
    if (success) {
      _fetch();
      DashboardController.refreshIfActive();
    }
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
        AppSpacing.vGapMd,
        _filterToolbar(),
        AppSpacing.vGapLg,
        Row(children: [
          Expanded(
            child: Text(
              _groupByTrip
                  ? 'Trip-wise (${filtered.length})'
                  : 'Expenses (${filtered.length})',
              style: AppText.title,
            ),
          ),
          if (_activeFilterCount > 0)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Iconsax.close_circle, size: 15),
              label: Text('Clear ($_activeFilterCount)',
                  style: AppText.label.on(AppPalette.primary)),
              style: TextButton.styleFrom(
                foregroundColor: AppPalette.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
            ),
        ]),
        AppSpacing.vGapMd,
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: AppEmptyState(
              icon: Iconsax.receipt_1,
              title: 'No expenses found',
              subtitle: _expenses.isEmpty
                  ? 'Tap “Add Expense” to log your first one.'
                  : 'Try adjusting your search or filters.',
            ),
          )
        else if (_groupByTrip)
          ...groupExpensesByTrip(filtered).map(_tripGroup)
        else
          ...filtered.map(_expenseTile),
      ],
    );
  }

  /// Status / trip / sort / grouping controls.
  ///
  /// Kept on one scrollable row so the whole set stays reachable on a narrow
  /// phone without pushing the list below the fold.
  Widget _filterToolbar() {
    final tripLabel = _tripKeys.isEmpty
        ? 'All trips'
        : _tripKeys.length == 1
            ? (_tripKeys.first == kUnassignedTripKey
                ? 'No trip'
                : _tripKeys.first)
            : '${_tripKeys.length} trips';

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _toolbarChip(
            icon: Iconsax.routing,
            label: tripLabel,
            active: _tripKeys.isNotEmpty,
            onTap: _openTripFilter,
          ),
          const SizedBox(width: 8),
          _toolbarChip(
            icon: Iconsax.tick_circle,
            label: _status == 'all' ? 'All statuses' : _statusLabel(_status),
            active: _status != 'all',
            onTap: _openStatusFilter,
          ),
          const SizedBox(width: 8),
          _toolbarChip(
            icon: _sortAscending ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
            label: 'Sort: ${_sortField.label}',
            active: _sortField != ExpenseSortField.date || _sortAscending,
            onTap: _openSortSheet,
          ),
          const SizedBox(width: 8),
          _toolbarChip(
            icon: _groupByTrip ? Iconsax.category : Iconsax.menu_1,
            label: _groupByTrip ? 'Trip-wise' : 'List',
            active: _groupByTrip,
            onTap: () => setState(() => _groupByTrip = !_groupByTrip),
          ),
        ],
      ),
    );
  }

  Widget _toolbarChip({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppPalette.primary : AppPalette.card,
          borderRadius: AppRadius.rPill,
          border: Border.all(
              color: active ? AppPalette.primary : AppPalette.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              size: 14, color: active ? Colors.white : AppPalette.textGrey),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.label
                    .on(active ? Colors.white : AppPalette.textGrey)),
          ),
        ]),
      ),
    );
  }

  String _statusLabel(String status) =>
      status.isEmpty ? status : '${status[0].toUpperCase()}${status.substring(1)}';

  /// Multi-select trip filter. Options come from the loaded expenses, so the
  /// list always matches the trips the user actually has spend against.
  Future<void> _openTripFilter() async {
    final options = _tripOptions;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppPalette.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(builder: (sheetContext, setSheetState) {
          void toggle(String key) {
            setSheetState(() {
              if (!_tripKeys.remove(key)) _tripKeys.add(key);
            });
            setState(() {});
          }

          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                  child: Row(children: [
                    Expanded(
                        child: Text('Filter by trip', style: AppText.title)),
                    if (_tripKeys.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setSheetState(() => _tripKeys.clear());
                          setState(() {});
                        },
                        child: Text('Clear',
                            style: AppText.label.on(AppPalette.primary)),
                      ),
                  ]),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        leading: Icon(
                          _tripKeys.isEmpty
                              ? Iconsax.tick_square
                              : Iconsax.stop,
                          color: _tripKeys.isEmpty
                              ? AppPalette.primary
                              : AppPalette.textGrey,
                          size: 20,
                        ),
                        title: Text('All trips', style: AppText.subtitle),
                        onTap: () {
                          setSheetState(() => _tripKeys.clear());
                          setState(() {});
                        },
                      ),
                      if (options.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text('No trips with expenses yet',
                                style: AppText.body.on(AppPalette.textGrey)),
                          ),
                        ),
                      ...options.map((option) {
                        final selected = _tripKeys.contains(option.key);
                        return ListTile(
                          leading: Icon(
                            selected ? Iconsax.tick_square : Iconsax.stop,
                            color: selected
                                ? AppPalette.primary
                                : AppPalette.textGrey,
                            size: 20,
                          ),
                          title: Text(option.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.subtitle),
                          subtitle: Text(
                            [
                              if (option.routeLabel != null)
                                option.routeLabel!,
                              '${option.expenseCount} expense'
                                  '${option.expenseCount == 1 ? '' : 's'} · '
                                  '₹${_fmt(option.totalAmount)}',
                            ].join('\n'),
                            style: AppText.caption,
                          ),
                          isThreeLine: option.routeLabel != null,
                          onTap: () => toggle(option.key),
                        );
                      }),
                    ],
                  ),
                ),
              ]),
            ),
          );
        });
      },
    );
  }

  Future<void> _openStatusFilter() async {
    const statuses = ['all', 'paid', 'pending', 'overdue'];
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppPalette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: Text('Filter by status', style: AppText.title)),
            ]),
          ),
          const Divider(height: 1),
          ...statuses.map((s) => ListTile(
                leading: Icon(
                  _status == s ? Iconsax.tick_circle : Iconsax.record,
                  color:
                      _status == s ? AppPalette.primary : AppPalette.textGrey,
                  size: 20,
                ),
                title: Text(s == 'all' ? 'All statuses' : _statusLabel(s),
                    style: AppText.subtitle),
                onTap: () {
                  setState(() => _status = s);
                  Navigator.of(sheetContext).pop();
                },
              )),
        ]),
      ),
    );
  }

  Future<void> _openSortSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppPalette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(builder: (sheetContext, setSheetState) {
          return SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Expanded(child: Text('Sort by', style: AppText.title)),
                  TextButton.icon(
                    onPressed: () {
                      setSheetState(() => _sortAscending = !_sortAscending);
                      setState(() {});
                    },
                    icon: Icon(
                        _sortAscending
                            ? Iconsax.arrow_up_3
                            : Iconsax.arrow_down,
                        size: 16),
                    label: Text(_sortAscending ? 'Ascending' : 'Descending',
                        style: AppText.label.on(AppPalette.primary)),
                    style:
                        TextButton.styleFrom(foregroundColor: AppPalette.primary),
                  ),
                ]),
              ),
              const Divider(height: 1),
              ...ExpenseSortField.values.map((field) => ListTile(
                    leading: Icon(
                      _sortField == field
                          ? Iconsax.tick_circle
                          : Iconsax.record,
                      color: _sortField == field
                          ? AppPalette.primary
                          : AppPalette.textGrey,
                      size: 20,
                    ),
                    title: Text(field.label, style: AppText.subtitle),
                    onTap: () {
                      setState(() => _sortField = field);
                      Navigator.of(sheetContext).pop();
                    },
                  )),
            ]),
          );
        });
      },
    );
  }

  /// One trip bucket in the trip-wise view.
  Widget _tripGroup(ExpenseTripGroup group) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: group.isUnassigned
              ? AppPalette.border.withValues(alpha: 0.3)
              : AppPalette.primary.withValues(alpha: 0.08),
          borderRadius: AppRadius.rMd,
        ),
        child: Row(children: [
          Icon(Iconsax.routing,
              size: 16,
              color: group.isUnassigned
                  ? AppPalette.textGrey
                  : AppPalette.primary),
          AppSpacing.hGapSm,
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(group.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitle),
              if (group.routeLabel != null)
                Text(group.routeLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption),
              Text(
                  '${group.expenses.length} expense'
                  '${group.expenses.length == 1 ? '' : 's'}',
                  style: AppText.micro.weight(FontWeight.w400)),
            ]),
          ),
          AppSpacing.hGapSm,
          Text('₹${_fmt(group.total)}',
              style: AppText.subtitle.on(AppPalette.primary)),
        ]),
      ),
      ...group.expenses.map(_expenseTile),
      AppSpacing.vGapMd,
    ]);
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
    // Denominator for each category's contribution = total of all categories.
    final grandTotal = entries.fold<double>(0, (sum, e) => sum + e.value);

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
                const SizedBox(width: 8),
                Text(
                  '${grandTotal == 0 ? '0' : (e.value / grandTotal * 100).toStringAsFixed(1)}%',
                  style: AppText.micro.on(cfg.color).weight(FontWeight.w600),
                ),
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
      child: Dismissible(
        key: ValueKey('exp-${e.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirmDelete(e),
        onDismissed: (_) => _onDeleted(e),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
              color: AppPalette.danger, borderRadius: AppRadius.rLg),
          child: const Icon(Iconsax.trash, color: Colors.white),
        ),
        child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
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
          // Explicit, always-visible action to settle a pending expense.
          if (e.status != 'paid') ...[
            AppSpacing.vGapSm,
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _markPaid(e),
                icon: const Icon(Iconsax.tick_circle, size: 15),
                label: const Text('Mark Paid'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppPalette.green,
                  side: BorderSide(
                      color: AppPalette.green.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
                ),
              ),
            ),
          ],
        ]),
        ),
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
    // Indian-style grouping: rightmost group of 3, then groups of 2
    // (e.g. 48,600 and 1,48,600).
    final s = v.abs().toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final right = s.length - i - 1; // digits still to the right
      if (right >= 3 && right.isOdd) buf.write(',');
    }
    return '${v < 0 ? '-' : ''}$buf';
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final l = d.toLocal();
    return '${m[l.month - 1]} ${l.day}, ${l.year}';
  }
}
