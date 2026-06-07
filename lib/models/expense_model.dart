import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Expense model — mirrors wheelboard-fe `expensesApi.ts` `Expense`.
class Expense {
  final String id;
  final String category; // advance | fuel | challan | food | salary | enroute
  final String description;
  final double amount;
  final DateTime? date;
  final String status; // paid | pending | overdue
  final String? vehicle;
  final String? tripId;
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
    this.paymentMethod,
    this.receipt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    String? tripId;
    final t = json['tripId'];
    if (t is Map) {
      tripId = (t['tripId'] ?? t['_id'])?.toString();
    } else if (t != null) {
      tripId = t.toString();
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
      tripId: tripId,
      paymentMethod: json['paymentMethod']?.toString(),
      receipt: (json['receipt'] ?? json['receiptPath'])?.toString(),
    );
  }
}

/// UI config (colour + label + icon) per expense category — mirrors the web
/// `categoryConfig`.
class ExpenseCategoryConfig {
  final String label;
  final Color color;
  final IconData icon;
  const ExpenseCategoryConfig(this.label, this.color, this.icon);

  static const _map = <String, ExpenseCategoryConfig>{
    'advance': ExpenseCategoryConfig('Advance', Color(0xFFF973A7), Iconsax.wallet_money),
    'fuel': ExpenseCategoryConfig('Fuel', Color(0xFFFB7185), Iconsax.gas_station),
    'challan': ExpenseCategoryConfig('Challan', Color(0xFF60A5FA), Iconsax.warning_2),
    'food': ExpenseCategoryConfig('Food', Color(0xFF34D399), Iconsax.cup),
    'salary': ExpenseCategoryConfig('Salary', Color(0xFFFBBF24), Iconsax.money_4),
    'enroute': ExpenseCategoryConfig('Enroute', Color(0xFFA78BFA), Iconsax.routing),
  };

  static ExpenseCategoryConfig of(String category) =>
      _map[category.toLowerCase()] ??
      const ExpenseCategoryConfig('Other', Color(0xFF6B7280), Iconsax.box);

  static List<String> get keys => _map.keys.toList();
}
