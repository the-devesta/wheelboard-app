import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Sentinel key for expenses that are not attached to any trip.
const String kUnassignedTripKey = '__unassigned__';

/// Expense model — mirrors wheelboard-fe `expensesApi.ts` `Expense`.
class Expense {
  final String id;
  final String category; // advance | fuel | challan | food | salary | enroute…
  final String description;
  final double amount;
  final DateTime? date;
  final String status; // paid | pending | overdue
  final String? vehicle;

  /// Human-readable trip id (e.g. `WS-TRIP-0001`), or null when unlinked.
  final String? tripId;

  /// The trip's uuid row id, when the API could resolve it.
  final String? tripRowId;

  /// Pickup / drop addresses of the linked trip, when known.
  final String? tripFrom;
  final String? tripTo;

  final String? paymentMethod;
  final String? receipt;

  const Expense({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    this.date,
    required this.status,
    this.vehicle,
    this.tripId,
    this.tripRowId,
    this.tripFrom,
    this.tripTo,
    this.paymentMethod,
    this.receipt,
  });

  /// Stable key used to group / filter by trip.
  ///
  /// Prefers the readable trip id so two expenses on the same trip group
  /// together even when one was created with the uuid and the other with the
  /// readable id — which is exactly how the web and app clients differ.
  String get tripKey {
    if (tripId != null && tripId!.isNotEmpty) return tripId!;
    if (tripRowId != null && tripRowId!.isNotEmpty) return tripRowId!;
    return kUnassignedTripKey;
  }

  bool get hasTrip => tripKey != kUnassignedTripKey;

  /// "From → To" when the trip route is known, otherwise null.
  String? get tripRouteLabel {
    final from = (tripFrom ?? '').trim();
    final to = (tripTo ?? '').trim();
    if (from.isEmpty && to.isEmpty) return null;
    return '${from.isEmpty ? '—' : from} → ${to.isEmpty ? '—' : to}';
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    // `tripId` arrives as a populated preview object, a bare identifier string,
    // or null. The flat `tripReference` / `tripRowId` fields are preferred when
    // present; the object form is still parsed so an older backend keeps working.
    String? tripLabel;
    String? tripRowId;
    String? tripFrom;
    String? tripTo;

    final t = json['tripId'];
    if (t is Map) {
      tripLabel = (t['tripId'])?.toString();
      tripRowId = (t['_id'] ?? t['id'])?.toString();
      final route = t['route'];
      if (route is Map) {
        final start = route['startLocation'];
        final end = route['endLocation'];
        if (start is Map) tripFrom = start['address']?.toString();
        if (end is Map) tripTo = end['address']?.toString();
      }
    } else if (t != null && t.toString().trim().isNotEmpty) {
      tripLabel = t.toString();
    }

    tripLabel = _firstNonEmpty([
      json['tripReference']?.toString(),
      json['tripLabel']?.toString(),
      tripLabel,
    ]);
    tripRowId = _firstNonEmpty([json['tripRowId']?.toString(), tripRowId]);

    final tripRoute = json['tripRoute'];
    if (tripRoute is Map) {
      tripFrom = _firstNonEmpty([tripRoute['from']?.toString(), tripFrom]);
      tripTo = _firstNonEmpty([tripRoute['to']?.toString(), tripTo]);
    }

    return Expense(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      category: (json['category'] ?? 'other').toString().toLowerCase(),
      description: (json['description'] ?? '').toString(),
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse('${json['amount']}') ?? 0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : (json['expenseDate'] != null
              ? DateTime.tryParse(json['expenseDate'].toString())
              : null),
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
      vehicle: json['vehicle']?.toString(),
      tripId: tripLabel,
      tripRowId: tripRowId,
      tripFrom: tripFrom,
      tripTo: tripTo,
      paymentMethod: json['paymentMethod']?.toString(),
      receipt: (json['receipt'] ?? json['receiptPath'])?.toString(),
    );
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty && value != 'null') {
        return value.trim();
      }
    }
    return null;
  }
}

/// A trip that at least one expense is attached to — drives the trip filter.
class ExpenseTripOption {
  final String key;
  final String label;
  final String? routeLabel;
  final int expenseCount;
  final double totalAmount;

  const ExpenseTripOption({
    required this.key,
    required this.label,
    this.routeLabel,
    required this.expenseCount,
    required this.totalAmount,
  });

  bool get isUnassigned => key == kUnassignedTripKey;
}

/// UI config (colour + label + icon) per expense category — mirrors the web
/// `categoryConfig`.
class ExpenseCategoryConfig {
  final String label;
  final Color color;
  final IconData icon;
  const ExpenseCategoryConfig(this.label, this.color, this.icon);

  /// All ten backend `ExpenseCategory` values.
  ///
  /// Maintenance / Toll / Parking / Other were previously missing, so expenses
  /// in those categories fell through to the "Other" fallback and — because the
  /// filter chips are built from these keys — could not be filtered for at all.
  static const _map = <String, ExpenseCategoryConfig>{
    'advance': ExpenseCategoryConfig('Advance', Color(0xFFF973A7), Iconsax.wallet_money),
    'fuel': ExpenseCategoryConfig('Fuel', Color(0xFFFB7185), Iconsax.gas_station),
    'challan': ExpenseCategoryConfig('Challan', Color(0xFF60A5FA), Iconsax.warning_2),
    'food': ExpenseCategoryConfig('Food', Color(0xFF34D399), Iconsax.cup),
    'salary': ExpenseCategoryConfig('Salary', Color(0xFFFBBF24), Iconsax.money_4),
    'enroute': ExpenseCategoryConfig('Enroute', Color(0xFFA78BFA), Iconsax.routing),
    'maintenance': ExpenseCategoryConfig('Maintenance', Color(0xFF6366F1), Iconsax.setting_2),
    'toll': ExpenseCategoryConfig('Toll', Color(0xFF14B8A6), Iconsax.card_pos),
    'parking': ExpenseCategoryConfig('Parking', Color(0xFFF97316), Iconsax.car),
    'other': ExpenseCategoryConfig('Other', Color(0xFF6B7280), Iconsax.box),
  };

  static ExpenseCategoryConfig of(String category) =>
      _map[category.toLowerCase()] ??
      const ExpenseCategoryConfig('Other', Color(0xFF6B7280), Iconsax.box);

  static List<String> get keys => _map.keys.toList();
}

/// How a list of expenses is ordered.
enum ExpenseSortField { date, amount, category, status, trip }

extension ExpenseSortFieldLabel on ExpenseSortField {
  String get label => switch (this) {
        ExpenseSortField.date => 'Date',
        ExpenseSortField.amount => 'Amount',
        ExpenseSortField.category => 'Category',
        ExpenseSortField.status => 'Status',
        ExpenseSortField.trip => 'Trip',
      };
}

/// Build the trip filter options from a loaded expense list.
///
/// Derived from the expenses themselves rather than a separate trips call, so
/// the options always match exactly the trips the user has spend against.
/// "No trip" sorts last so it never displaces a real trip.
List<ExpenseTripOption> buildExpenseTripOptions(List<Expense> expenses) {
  final counts = <String, int>{};
  final totals = <String, double>{};
  final routes = <String, String?>{};

  for (final e in expenses) {
    final key = e.tripKey;
    counts[key] = (counts[key] ?? 0) + 1;
    totals[key] = (totals[key] ?? 0) + e.amount;
    routes[key] ??= e.tripRouteLabel;
  }

  final options = counts.keys.map((key) {
    return ExpenseTripOption(
      key: key,
      label: key == kUnassignedTripKey ? 'No trip' : key,
      routeLabel: routes[key],
      expenseCount: counts[key] ?? 0,
      totalAmount: totals[key] ?? 0,
    );
  }).toList();

  options.sort((a, b) {
    if (a.isUnassigned) return 1;
    if (b.isUnassigned) return -1;
    return a.label.compareTo(b.label);
  });

  return options;
}

/// A trip bucket for the "Trip-wise" view.
class ExpenseTripGroup {
  final String key;
  final String label;
  final String? routeLabel;
  final List<Expense> expenses;
  final double total;

  const ExpenseTripGroup({
    required this.key,
    required this.label,
    this.routeLabel,
    required this.expenses,
    required this.total,
  });

  bool get isUnassigned => key == kUnassignedTripKey;
}

/// Bucket expenses by trip, preserving the incoming sort order within each
/// bucket. Untripped expenses land in a single trailing "No trip" group rather
/// than disappearing from the view.
List<ExpenseTripGroup> groupExpensesByTrip(List<Expense> expenses) {
  final buckets = <String, List<Expense>>{};
  final routes = <String, String?>{};

  for (final e in expenses) {
    buckets.putIfAbsent(e.tripKey, () => <Expense>[]).add(e);
    routes[e.tripKey] ??= e.tripRouteLabel;
  }

  final groups = buckets.entries.map((entry) {
    return ExpenseTripGroup(
      key: entry.key,
      label: entry.key == kUnassignedTripKey ? 'No trip' : entry.key,
      routeLabel: routes[entry.key],
      expenses: entry.value,
      total: entry.value.fold<double>(0, (s, e) => s + e.amount),
    );
  }).toList();

  groups.sort((a, b) {
    if (a.isUnassigned) return 1;
    if (b.isUnassigned) return -1;
    return a.label.compareTo(b.label);
  });

  return groups;
}

/// Sort a copy of [expenses] by [field] / [ascending].
///
/// Untripped expenses always sort last under [ExpenseSortField.trip], in both
/// directions — they are not part of the trip ordering the user asked for, so
/// reversing the sort must not float them to the top.
List<Expense> sortExpenses(
  List<Expense> expenses, {
  required ExpenseSortField field,
  required bool ascending,
}) {
  final direction = ascending ? 1 : -1;
  final copy = [...expenses];

  int compare(Expense a, Expense b) {
    switch (field) {
      case ExpenseSortField.amount:
        return a.amount.compareTo(b.amount);
      case ExpenseSortField.category:
        return a.category.compareTo(b.category);
      case ExpenseSortField.status:
        return a.status.compareTo(b.status);
      case ExpenseSortField.trip:
        final left = a.hasTrip ? a.tripKey : '';
        final right = b.hasTrip ? b.tripKey : '';
        if (left.isEmpty && right.isEmpty) return 0;
        if (left.isEmpty) return 1 * direction;
        if (right.isEmpty) return -1 * direction;
        return left.compareTo(right);
      case ExpenseSortField.date:
        final ad = a.date?.millisecondsSinceEpoch ?? 0;
        final bd = b.date?.millisecondsSinceEpoch ?? 0;
        return ad.compareTo(bd);
    }
  }

  copy.sort((a, b) {
    final primary = compare(a, b);
    if (primary != 0) return primary * direction;
    // Deterministic tie-break so equal keys keep a stable order.
    final ad = a.date?.millisecondsSinceEpoch ?? 0;
    final bd = b.date?.millisecondsSinceEpoch ?? 0;
    return bd.compareTo(ad);
  });

  return copy;
}
