import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../controllers/ServiceProvider/service_earnings_controller.dart';
import '../../models/ServiceProvider/service_earnings_model.dart';
import '../../theme/design_system.dart';
import 'register_payment_screen.dart';

/// Earnings dashboard — mirrors wheelboard-fe `business/earnings`: summary,
/// service breakdown, an earnings chart, payment history and a period toggle.
class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  late final ServiceEarningsController _c;

  static const _periods = ['monthly', 'quarterly', 'yearly'];

  @override
  void initState() {
    super.initState();
    _c = Get.isRegistered<ServiceEarningsController>()
        ? Get.find<ServiceEarningsController>()
        : Get.put(ServiceEarningsController());
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
        title: Text('Earnings', style: AppText.h2),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppPalette.primary,
        icon: const Icon(Iconsax.wallet_add, color: Colors.white, size: 20),
        label: Text('Register Payment',
            style: AppText.subtitle.on(Colors.white)),
        onPressed: () => Get.to(() => const RegisterPaymentScreen()),
      ),
      body: Obx(() {
        if (_c.isLoading.value && _c.dashboardData.value == null) {
          return const AppLoading(message: 'Loading earnings…');
        }
        final data = _c.dashboardData.value;
        return RefreshIndicator(
          color: AppPalette.primary,
          onRefresh: () async {
            await _c.fetchEarningsDashboard();
            await _c.fetchMyPayments();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _periodToggle(),
              AppSpacing.vGapLg,
              _summaryCard(data),
              AppSpacing.vGapLg,
              _chartCard(data),
              AppSpacing.vGapLg,
              _breakdownCard(data),
              AppSpacing.vGapLg,
              _paymentHistoryCard(),
            ],
          ),
        );
      }),
    );
  }

  Widget _periodToggle() {
    return Obx(() {
      final sel = _c.selectedPeriod.value;
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: AppPalette.card,
            borderRadius: AppRadius.rLg,
            border: Border.all(color: AppPalette.border)),
        child: Row(
          children: _periods.map((p) {
            final active = sel == p;
            return Expanded(
              child: GestureDetector(
                onTap: () => _c.setPeriod(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? AppPalette.primary : Colors.transparent,
                    borderRadius: AppRadius.rMd,
                  ),
                  child: Text(
                    p[0].toUpperCase() + p.substring(1),
                    style: AppText.label
                        .on(active ? Colors.white : AppPalette.textGrey),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _summaryCard(ServiceEarningsModel? data) {
    final total = data?.totalEarnings ?? 0;
    final completed = data?.completedBookings ?? 0;
    final cash = data?.cashEarnings ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          gradient: AppPalette.brandGradient, borderRadius: AppRadius.rXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Iconsax.empty_wallet, color: Colors.white70, size: 18),
            AppSpacing.hGapSm,
            Text('Total Earnings', style: AppText.label.on(Colors.white70)),
          ]),
          AppSpacing.vGapSm,
          Text('₹${NumberFormat('#,##,###').format(total)}',
              style: AppText.h1.on(Colors.white).size(34)),
          AppSpacing.vGapLg,
          Row(children: [
            _summaryStat(Iconsax.task_square, '$completed', 'Completed'),
            Container(width: 1, height: 34, color: Colors.white24),
            _summaryStat(Iconsax.money_recive,
                '₹${NumberFormat('#,##,###').format(cash)}', 'Cash'),
          ]),
        ],
      ),
    );
  }

  Widget _summaryStat(IconData icon, String value, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 4, left: 4),
        child: Row(children: [
          Icon(icon, color: Colors.white, size: 18),
          AppSpacing.hGapSm,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: AppText.subtitle.on(Colors.white)),
            Text(label, style: AppText.caption.on(Colors.white70)),
          ]),
        ]),
      ),
    );
  }

  Widget _chartCard(ServiceEarningsModel? data) {
    final chart = data?.earningsChart ?? const [];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Earnings Trend', style: AppText.h3),
          AppSpacing.vGapLg,
          if (chart.isEmpty)
            SizedBox(
              height: 80,
              child: Center(
                  child: Text('No earnings data for this period',
                      style: AppText.caption)),
            )
          else
            _BarChart(data: chart),
        ],
      ),
    );
  }

  Widget _breakdownCard(ServiceEarningsModel? data) {
    final items = data?.serviceBreakdown ?? const [];
    final maxAmount = items.isEmpty
        ? 1.0
        : items.map((e) => e.totalAmount).reduce((a, b) => a > b ? a : b);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service Breakdown', style: AppText.h3),
          AppSpacing.vGapMd,
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No completed services yet', style: AppText.caption),
            )
          else
            ...items.map((s) => _breakdownRow(s, maxAmount)),
        ],
      ),
    );
  }

  Widget _breakdownRow(ServiceBreakdown s, double maxAmount) {
    final pct = maxAmount <= 0 ? 0.0 : (s.totalAmount / maxAmount).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                    s.serviceTitle.isEmpty ? 'Service' : s.serviceTitle,
                    style: AppText.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Text('₹${NumberFormat('#,##,###').format(s.totalAmount)}',
                  style: AppText.subtitle.on(AppPalette.primary)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: AppRadius.rPill,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 7,
                backgroundColor: AppPalette.bg,
                valueColor:
                    const AlwaysStoppedAnimation(AppPalette.primary),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('${s.bookingCount} booking${s.bookingCount == 1 ? '' : 's'}',
              style: AppText.caption),
        ],
      ),
    );
  }

  Widget _paymentHistoryCard() {
    return Obx(() {
      final payments = _c.myPayments;
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Payment History', style: AppText.h3),
              const Spacer(),
              TextButton.icon(
                onPressed: () => Get.to(() => const RegisterPaymentScreen()),
                icon:
                    const Icon(Iconsax.add, size: 16, color: AppPalette.primary),
                label:
                    Text('Add', style: AppText.label.on(AppPalette.primary)),
              ),
            ]),
            if (payments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child:
                    Text('No payments recorded yet', style: AppText.caption),
              )
            else
              ...payments.take(20).map(_paymentRow),
          ],
        ),
      );
    });
  }

  Widget _paymentRow(PaymentHistory p) {
    String date = p.paymentDate;
    final dt = DateTime.tryParse(date);
    if (dt != null) date = DateFormat('dd MMM yyyy').format(dt);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: AppPalette.greenBg, borderRadius: AppRadius.rMd),
            child: const Icon(Iconsax.money_recive,
                size: 18, color: AppPalette.green),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.serviceTitle,
                    style: AppText.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(date, style: AppText.caption),
              ],
            ),
          ),
          Text('+₹${NumberFormat('#,##,###').format(p.paymentAmount)}',
              style: AppText.subtitle.on(AppPalette.green)),
        ],
      ),
    );
  }
}

/// Simple animated bar chart for the earnings trend.
class _BarChart extends StatelessWidget {
  final List<EarningsChartData> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxVal =
        data.map((e) => e.totalAmount).fold<double>(0, (p, e) => e > p ? e : p);
    final shown = data.length > 12 ? data.sublist(data.length - 12) : data;
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: shown.map((d) {
          final ratio = maxVal <= 0 ? 0.0 : (d.totalAmount / maxVal);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    d.totalAmount >= 1000
                        ? '${(d.totalAmount / 1000).toStringAsFixed(0)}k'
                        : d.totalAmount.toStringAsFixed(0),
                    style: AppText.micro,
                  ),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => Container(
                      height: (110 * v).clamp(3.0, 110.0),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppPalette.primary, AppPalette.primaryDark],
                        ),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _label(d.monthName),
                    style: AppText.micro.weight(FontWeight.w400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt != null) return DateFormat('d/M').format(dt);
    return raw.length > 4 ? raw.substring(0, 3) : raw;
  }
}
