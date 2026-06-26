/// Wallet domain models for the Earnings & Withdrawal feature.
///
/// Mirrors the NestJS `/wallet` contract (wheelboard-be `modules/wallet`),
/// which is the same contract consumed by wheelboard-fe and wheelboard-admin.
library;

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString())?.toLocal();
}

/// Summary returned by `GET /wallet`.
class WalletSummary {
  final double availableBalance;
  final double pendingWithdrawals;
  final double totalEarned;
  final double totalWithdrawn;
  final String currency;
  final String userType;

  const WalletSummary({
    this.availableBalance = 0,
    this.pendingWithdrawals = 0,
    this.totalEarned = 0,
    this.totalWithdrawn = 0,
    this.currency = 'INR',
    this.userType = '',
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) => WalletSummary(
        availableBalance: _toDouble(json['availableBalance']),
        pendingWithdrawals: _toDouble(json['pendingWithdrawals']),
        totalEarned: _toDouble(json['totalEarned']),
        totalWithdrawn: _toDouble(json['totalWithdrawn']),
        currency: (json['currency'] ?? 'INR').toString(),
        userType: (json['userType'] ?? '').toString(),
      );

  static const empty = WalletSummary();
}

/// A single wallet ledger entry (`GET /wallet/transactions`).
class WalletTransaction {
  final String id;
  final String type;
  final double amount;
  final String description;
  final String status;
  final String? referenceId;
  final double? balanceAfter;
  final DateTime? createdAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.status,
    this.referenceId,
    this.balanceAfter,
    this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: (json['id'] ?? json['transactionId'] ?? '').toString(),
        type: (json['type'] ?? '').toString(),
        amount: _toDouble(json['amount']),
        description: (json['description'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        referenceId: json['referenceId']?.toString(),
        balanceAfter:
            json['balanceAfter'] == null ? null : _toDouble(json['balanceAfter']),
        createdAt: _toDate(json['createdAt']),
      );

  bool get isCredit => amount >= 0;

  /// Human label for the transaction type.
  String get typeLabel {
    switch (type) {
      case 'TRIP_EARNING':
        return 'Trip Earnings';
      case 'SERVICE_EARNING':
        return 'Service Earnings';
      case 'WITHDRAWAL_REQUEST':
        return 'Withdrawal Requested';
      case 'WITHDRAWAL_APPROVED':
        return 'Withdrawal Approved';
      case 'WITHDRAWAL_REJECTED':
        return 'Withdrawal Rejected';
      case 'WITHDRAWAL_PAID':
        return 'Withdrawal Paid';
      case 'ADMIN_ADJUSTMENT':
        return 'Adjustment';
      default:
        return type;
    }
  }
}

/// A withdrawal request (`GET/POST /wallet/withdrawals`).
class WithdrawalRequest {
  final String id;
  final double amount;
  final String withdrawalMethod; // BANK | UPI
  final String status; // Pending | Approved | Rejected | Paid
  final String? accountHolderName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? upiId;
  final String? notes;
  final String? remarks;
  final DateTime? createdAt;

  const WithdrawalRequest({
    required this.id,
    required this.amount,
    required this.withdrawalMethod,
    required this.status,
    this.accountHolderName,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.upiId,
    this.notes,
    this.remarks,
    this.createdAt,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) =>
      WithdrawalRequest(
        id: (json['id'] ?? json['withdrawalId'] ?? '').toString(),
        amount: _toDouble(json['amount']),
        withdrawalMethod: (json['withdrawalMethod'] ?? 'BANK').toString(),
        status: (json['status'] ?? 'Pending').toString(),
        accountHolderName: json['accountHolderName']?.toString(),
        bankName: json['bankName']?.toString(),
        accountNumber: json['accountNumber']?.toString(),
        ifscCode: json['ifscCode']?.toString(),
        upiId: json['upiId']?.toString(),
        notes: json['notes']?.toString(),
        remarks: json['remarks']?.toString(),
        createdAt: _toDate(json['createdAt']),
      );
}
