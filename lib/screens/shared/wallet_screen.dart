import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../controllers/shared/wallet_controller.dart';
import '../../models/wallet/wallet_models.dart';
import '../../theme/design_system.dart';

/// Shared Wallet & Earnings screen used by BOTH the Professional (Driver) and
/// Service Provider personas. The backend derives the earnings source from the
/// authenticated user, so the same screen serves both.
class WalletScreen extends StatefulWidget {
  final String title;
  const WalletScreen({super.key, this.title = 'My Earnings'});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late final WalletController c;
  final _tab = 0.obs;

  @override
  void initState() {
    super.initState();
    c = Get.put(WalletController());
  }

  @override
  void dispose() {
    Get.delete<WalletController>();
    super.dispose();
  }

  static final _money = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        backgroundColor: AppPalette.card,
        elevation: 0,
        title: Text(widget.title, style: AppText.h2),
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppPalette.textDark),
      ),
      body: Obx(() {
        if (c.isLoading.value && c.summary.value == WalletSummary.empty) {
          return const AppLoading(message: 'Loading your wallet…');
        }
        if (c.hasError.value && c.transactions.isEmpty) {
          return AppErrorState(
            message: c.errorMessage.value.isEmpty
                ? 'Could not load your wallet'
                : c.errorMessage.value,
            onRetry: c.loadAll,
          );
        }
        return RefreshIndicator(
          color: AppPalette.primary,
          onRefresh: c.loadAll,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _balanceHeader(),
              AppSpacing.vGapLg,
              _summaryRow(),
              AppSpacing.vGapLg,
              _claimButton(),
              AppSpacing.vGapXl,
              _tabsBar(),
              AppSpacing.vGapMd,
              _tabContent(),
            ],
          ),
        );
      }),
    );
  }

  Widget _balanceHeader() {
    final s = c.summary.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppPalette.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.wallet_3, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Available Balance',
                style: AppText.label.on(Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _money.format(s.availableBalance),
            style: AppText.h1.on(Colors.white).size(34).weight(FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Withdrawable to your bank or UPI',
            style: AppText.caption.on(Colors.white.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow() {
    final s = c.summary.value;
    return Row(
      children: [
        _statCard(
          'Total Earned',
          _money.format(s.totalEarned),
          Iconsax.money_recive,
          AppPalette.green,
          AppPalette.greenBg,
        ),
        const SizedBox(width: 12),
        _statCard(
          'Pending',
          _money.format(s.pendingWithdrawals),
          Iconsax.clock,
          AppPalette.amber,
          AppPalette.amberBg,
        ),
        const SizedBox(width: 12),
        _statCard(
          'Withdrawn',
          _money.format(s.totalWithdrawn),
          Iconsax.money_send,
          AppPalette.blue,
          AppPalette.blueBg,
        ),
      ],
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.subtitle.weight(FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppText.caption),
          ],
        ),
      ),
    );
  }

  Widget _claimButton() {
    final canClaim = c.summary.value.availableBalance > 0;
    return AppPrimaryButton(
      label: 'Claim Earnings',
      icon: Iconsax.money_send,
      onPressed: canClaim ? _openClaimSheet : null,
    );
  }

  Widget _tabsBar() {
    return Obx(() {
      Widget seg(int idx, String label) {
        final active = _tab.value == idx;
        return Expanded(
          child: GestureDetector(
            onTap: () => _tab.value = idx,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active ? AppPalette.card : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: active
                    ? AppText.subtitle.on(AppPalette.primary)
                    : AppText.subtitle.on(AppPalette.textGrey),
              ),
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppPalette.border.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            seg(0, 'Transactions'),
            seg(1, 'Withdrawals'),
          ],
        ),
      );
    });
  }

  Widget _tabContent() {
    return Obx(() {
      if (_tab.value == 0) {
        if (c.transactions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 32),
            child: AppEmptyState(
              icon: Iconsax.receipt_item,
              title: 'No transactions yet',
              subtitle:
                  'Earnings from completed trips and services will appear here.',
            ),
          );
        }
        return Column(
          children: c.transactions.map(_txTile).toList(),
        );
      }
      if (c.withdrawals.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(top: 32),
          child: AppEmptyState(
            icon: Iconsax.money_send,
            title: 'No withdrawals yet',
            subtitle: 'Tap “Claim Earnings” to request a payout.',
          ),
        );
      }
      return Column(
        children: c.withdrawals.map(_withdrawalTile).toList(),
      );
    });
  }

  Widget _txTile(WalletTransaction t) {
    final credit = t.isCredit;
    final color = credit ? AppPalette.green : AppPalette.danger;
    final bg = credit ? AppPalette.greenBg : AppPalette.dangerBg;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                credit ? Iconsax.arrow_down : Iconsax.arrow_up_3,
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.typeLabel, style: AppText.subtitle),
                  const SizedBox(height: 2),
                  Text(
                    t.description.isEmpty ? _fmtDate(t.createdAt) : t.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${credit ? '+' : '-'}${_money.format(t.amount.abs())}',
                  style: AppText.subtitle.on(color).weight(FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(_fmtDate(t.createdAt), style: AppText.micro),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _withdrawalTile(WithdrawalRequest w) {
    final sc = _statusColor(w.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _money.format(w.amount),
                  style: AppText.h3,
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    w.status,
                    style: AppText.micro.on(sc).weight(FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  w.withdrawalMethod == 'UPI' ? Iconsax.mobile : Iconsax.bank,
                  size: 14,
                  color: AppPalette.textGrey,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    w.withdrawalMethod == 'UPI'
                        ? (w.upiId ?? 'UPI')
                        : '${w.bankName ?? 'Bank'} • ****${_last4(w.accountNumber)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption,
                  ),
                ),
                Text(_fmtDate(w.createdAt), style: AppText.micro),
              ],
            ),
            if ((w.remarks ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Note: ${w.remarks}',
                style: AppText.caption.on(AppPalette.textGrey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return AppPalette.green;
      case 'Approved':
        return AppPalette.blue;
      case 'Rejected':
        return AppPalette.danger;
      default:
        return AppPalette.amber;
    }
  }

  String _last4(String? acct) {
    if (acct == null || acct.length < 4) return acct ?? '';
    return acct.substring(acct.length - 4);
  }

  String _fmtDate(DateTime? d) =>
      d == null ? '' : DateFormat('dd MMM, hh:mm a').format(d);

  void _openClaimSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClaimEarningsSheet(
        controller: c,
        available: c.summary.value.availableBalance,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Claim Earnings — withdrawal request form (Bank / UPI)
// ─────────────────────────────────────────────────────────────────────────────

class _ClaimEarningsSheet extends StatefulWidget {
  final WalletController controller;
  final double available;
  const _ClaimEarningsSheet({required this.controller, required this.available});

  @override
  State<_ClaimEarningsSheet> createState() => _ClaimEarningsSheetState();
}

class _ClaimEarningsSheetState extends State<_ClaimEarningsSheet> {
  final _formKey = GlobalKey<FormState>();
  String _method = 'BANK';

  final _amount = TextEditingController();
  final _holder = TextEditingController();
  final _bank = TextEditingController();
  final _account = TextEditingController();
  final _confirmAccount = TextEditingController();
  final _ifsc = TextEditingController();
  final _upi = TextEditingController();
  final _notes = TextEditingController();

  static final _money = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _amount.dispose();
    _holder.dispose();
    _bank.dispose();
    _account.dispose();
    _confirmAccount.dispose();
    _ifsc.dispose();
    _upi.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? _validateAmount(String? v) {
    final n = double.tryParse((v ?? '').trim());
    if (n == null || n <= 0) return 'Enter a valid amount';
    if (n > widget.available) return 'Amount exceeds available balance';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_method == 'BANK' &&
        _account.text.trim() != _confirmAccount.text.trim()) {
      return; // handled by validator below
    }
    final ok = await widget.controller.createWithdrawal(
      amount: double.parse(_amount.text.trim()),
      withdrawalMethod: _method,
      accountHolderName: _holder.text.trim(),
      bankName: _bank.text.trim(),
      accountNumber: _account.text.trim(),
      ifscCode: _ifsc.text.trim().toUpperCase(),
      upiId: _upi.text.trim(),
      notes: _notes.text.trim(),
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      icon: Iconsax.money_send,
      title: 'Claim Earnings',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available (read-only)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppPalette.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.wallet_3,
                      color: AppPalette.primary, size: 18),
                  const SizedBox(width: 10),
                  Text('Available Balance', style: AppText.label),
                  const Spacer(),
                  Text(
                    _money.format(widget.available),
                    style: AppText.h3.on(AppPalette.primary),
                  ),
                ],
              ),
            ),
            AppSpacing.vGapLg,

            _label('Withdrawal Amount'),
            TextFormField(
              controller: _amount,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              validator: _validateAmount,
              decoration: _dec('Enter amount', prefixText: '₹ '),
            ),
            AppSpacing.vGapLg,

            _label('Withdrawal Method'),
            Row(
              children: [
                _methodChip('Bank Account', 'BANK', Iconsax.bank),
                const SizedBox(width: 10),
                _methodChip('UPI ID', 'UPI', Iconsax.mobile),
              ],
            ),
            AppSpacing.vGapLg,

            if (_method == 'BANK') ..._bankFields() else _upiField(),

            AppSpacing.vGapLg,
            _label('Notes (optional)'),
            TextFormField(
              controller: _notes,
              maxLines: 2,
              decoration: _dec('Any note for the admin'),
            ),
            AppSpacing.vGapXl,

            Obx(
              () => AppPrimaryButton(
                label: 'Submit Request',
                icon: Iconsax.send_2,
                loading: widget.controller.isSubmitting.value,
                onPressed: widget.controller.isSubmitting.value ? null : _submit,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<Widget> _bankFields() => [
        _label('Account Holder Name'),
        TextFormField(
          controller: _holder,
          textCapitalization: TextCapitalization.words,
          validator: (v) =>
              (v ?? '').trim().isEmpty ? 'Required' : null,
          decoration: _dec('As per bank records'),
        ),
        AppSpacing.vGapMd,
        _label('Bank Name'),
        TextFormField(
          controller: _bank,
          validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
          decoration: _dec('e.g. HDFC Bank'),
        ),
        AppSpacing.vGapMd,
        _label('Account Number'),
        TextFormField(
          controller: _account,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) {
            final s = (v ?? '').trim();
            if (s.isEmpty) return 'Required';
            if (s.length < 6) return 'Invalid account number';
            return null;
          },
          decoration: _dec('Enter account number'),
        ),
        AppSpacing.vGapMd,
        _label('Confirm Account Number'),
        TextFormField(
          controller: _confirmAccount,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) {
            if ((v ?? '').trim() != _account.text.trim()) {
              return 'Account numbers do not match';
            }
            return null;
          },
          decoration: _dec('Re-enter account number'),
        ),
        AppSpacing.vGapMd,
        _label('IFSC Code'),
        TextFormField(
          controller: _ifsc,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
            LengthLimitingTextInputFormatter(11),
          ],
          validator: (v) {
            final s = (v ?? '').trim().toUpperCase();
            if (s.isEmpty) return 'Required';
            if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(s)) {
              return 'Invalid IFSC code';
            }
            return null;
          },
          decoration: _dec('e.g. HDFC0001234'),
        ),
      ];

  Widget _upiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('UPI ID'),
        TextFormField(
          controller: _upi,
          validator: (v) {
            final s = (v ?? '').trim();
            if (s.isEmpty) return 'Required';
            if (!RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$')
                .hasMatch(s)) {
              return 'Invalid UPI ID (e.g. name@okhdfcbank)';
            }
            return null;
          },
          decoration: _dec('name@okhdfcbank'),
        ),
      ],
    );
  }

  Widget _methodChip(String label, String value, IconData icon) {
    final active = _method == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _method = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppPalette.primaryLight : AppPalette.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: active ? AppPalette.primary : AppPalette.border,
              width: active ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: active ? AppPalette.primary : AppPalette.textGrey),
              const SizedBox(width: 8),
              Text(
                label,
                style: active
                    ? AppText.subtitle.on(AppPalette.primary)
                    : AppText.subtitle.on(AppPalette.textGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: AppText.label),
      );

  InputDecoration _dec(String hint, {String? prefixText}) => InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        hintStyle: AppText.body.on(AppPalette.textFaint),
        filled: true,
        fillColor: AppPalette.bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppPalette.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppPalette.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppPalette.danger, width: 1.4),
        ),
      );
}
