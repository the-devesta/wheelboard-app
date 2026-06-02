import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/subscription_controller.dart';
import '../../models/subscription_model.dart';

// ── Theme per role ────────────────────────────────────────────────────────────

class _RoleTheme {
  final Color primary;
  final Color primaryLight;
  final Color accent;
  final String title;
  final String subtitle;
  final List<_Benefit> benefits;
  final List<_Faq> faqs;

  const _RoleTheme({
    required this.primary,
    required this.primaryLight,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.benefits,
    required this.faqs,
  });
}

class _Benefit {
  final IconData icon;
  final String title;
  final String desc;
  const _Benefit(this.icon, this.title, this.desc);
}

class _Faq {
  final String q;
  final String a;
  const _Faq(this.q, this.a);
}

const _themes = {
  'professional': _RoleTheme(
    primary: Color(0xFFF36969),
    primaryLight: Color(0xFFFFF1F1),
    accent: Color(0xFFE84545),
    title: 'Professional Career Plans',
    subtitle:
        'Stand out from the crowd, get priority access to opportunities, and accelerate your professional growth.',
    benefits: [
      _Benefit(Iconsax.medal, 'Verified Badge', 'Stand out to employers'),
      _Benefit(Iconsax.briefcase, 'Priority Jobs', 'Apply to exclusive opportunities'),
      _Benefit(Iconsax.wallet_3, 'Lower Commission', 'Keep more of your earnings'),
      _Benefit(Iconsax.star, 'Profile Boost', 'Get featured in searches'),
    ],
    faqs: [
      _Faq('How does the subscription help my career?',
          'Premium subscriptions give you priority access to job postings, increased visibility to fleet owners, and analytics to track your performance and earnings.'),
      _Faq('Can I cancel my subscription?',
          'Yes, you can cancel your subscription at any time. Your benefits will continue until the end of your billing period.'),
      _Faq('What payment methods are accepted?',
          'We accept all major credit/debit cards, UPI, net banking, and popular wallets through Razorpay.'),
      _Faq('What happens when my subscription expires?',
          'Your premium badge will be removed but your profile remains active. You can resubscribe anytime to regain premium status.'),
    ],
  ),
  'fleet_owner': _RoleTheme(
    primary: Color(0xFF3B82F6),
    primaryLight: Color(0xFFEFF6FF),
    accent: Color(0xFF1D4ED8),
    title: 'Fleet Management Plans',
    subtitle:
        'Scale your operations, manage more vehicles and drivers, and grow your transport business.',
    benefits: [
      _Benefit(Iconsax.truck, 'Unlimited Vehicles', 'Add as many vehicles as you need'),
      _Benefit(Iconsax.profile_2user, 'More Drivers', 'Manage a larger driver network'),
      _Benefit(Iconsax.routing_2, 'More Trips', 'Handle higher trip volumes'),
      _Benefit(Iconsax.chart_2, 'Analytics', 'Deep business insights'),
    ],
    faqs: [
      _Faq('How does premium help my fleet business?',
          'Premium plans unlock higher vehicle/driver limits, advanced analytics, and priority customer support.'),
      _Faq('Can I upgrade my plan later?',
          'Yes, you can upgrade at any time. The difference in price will be prorated.'),
      _Faq('What happens to my data if I downgrade?',
          'Your data is always kept safe. Some limits may apply on the lower plan.'),
      _Faq('Is there a free trial?',
          'Some plans include a trial period. Check the plan details for trial availability.'),
    ],
  ),
  'service_provider': _RoleTheme(
    primary: Color(0xFF8B5CF6),
    primaryLight: Color(0xFFF5F3FF),
    accent: Color(0xFF6D28D9),
    title: 'Business Growth Plans',
    subtitle:
        'Expand your service offerings, reach more clients, and grow your business revenue.',
    benefits: [
      _Benefit(Iconsax.shop, 'More Listings', 'Post unlimited service listings'),
      _Benefit(Iconsax.people, 'More Clients', 'Reach a wider customer base'),
      _Benefit(Iconsax.chart_2, 'Earnings Analytics', 'Track revenue and performance'),
      _Benefit(Iconsax.verify, 'Verified Business', 'Build trust with customers'),
    ],
    faqs: [
      _Faq('How does premium grow my business?',
          'Premium unlocks higher listing limits, analytics, and priority placement in search results.'),
      _Faq('Are payments secure?',
          'All transactions are processed through Razorpay\'s PCI-DSS compliant payment gateway.'),
      _Faq('Can I cancel anytime?',
          'Yes. Your benefits continue until end of the billing period after cancellation.'),
      _Faq('What commission rate applies?',
          'Commission rates vary by plan — premium plans have significantly lower rates.'),
    ],
  ),
};

// ── Screen ────────────────────────────────────────────────────────────────────

class SubscriptionScreen extends StatelessWidget {
  /// One of: 'professional' | 'fleet_owner' | 'service_provider'
  final String category;

  const SubscriptionScreen({super.key, required this.category});

  _RoleTheme get _theme =>
      _themes[category] ?? _themes['professional']!;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      SubscriptionController(category),
      tag: category,
    );
    final t = _theme;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Obx(() {
        if (ctrl.isLoading.value) return _LoadingView(color: t.primary);
        if (ctrl.errorMessage.value.isNotEmpty && ctrl.plans.isEmpty) {
          return _ErrorView(
            message: ctrl.errorMessage.value,
            color: t.primary,
            onRetry: ctrl.fetchData,
          );
        }
        return _Content(ctrl: ctrl, theme: t);
      }),
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _Content extends StatefulWidget {
  final SubscriptionController ctrl;
  final _RoleTheme theme;
  const _Content({required this.ctrl, required this.theme});

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  int? _expandedFaq;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final ctrl = widget.ctrl;

    return CustomScrollView(
      slivers: [
        // ── App bar ──────────────────────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: const Color(0xFFE5E7EB),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Color(0xFF111827)),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Subscription Plans',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: t.primary,
                fontFamily: 'Poppins'),
          ),
          centerTitle: true,
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Current subscription banner ──────────────────────────
                Obx(() {
                  final sub = ctrl.currentSubscription.value;
                  if (sub == null || !sub.isActive) return const SizedBox.shrink();
                  return _ActiveSubscriptionBanner(
                    sub: sub,
                    color: t.primary,
                    onCancel: () => ctrl.cancelSubscription(context),
                  );
                }),

                // ── Hero ─────────────────────────────────────────────────
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: t.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.star, size: 14, color: t.primary),
                        const SizedBox(width: 6),
                        Text(
                          _heroTag(widget.ctrl.category),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: t.primary,
                              fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    t.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        fontFamily: 'Poppins',
                        height: 1.25),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    t.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        fontFamily: 'Poppins',
                        height: 1.5),
                  ),
                ),

                // ── Plans ────────────────────────────────────────────────
                const SizedBox(height: 24),
                Obx(() {
                  if (ctrl.plans.isEmpty) {
                    return _EmptyPlans(color: t.primary);
                  }
                  return Column(
                    children: ctrl.plans
                        .map((plan) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _PlanCard(
                                plan: plan,
                                theme: t,
                                isCurrent: ctrl.isCurrentPlan(plan.id),
                                isProcessing:
                                    ctrl.processingPlanId.value == plan.id,
                                onSubscribe: () => ctrl.subscribe(plan),
                              ),
                            ))
                        .toList(),
                  );
                }),

                // ── Why go premium ───────────────────────────────────────
                const SizedBox(height: 8),
                _WhyPremium(theme: t),
                const SizedBox(height: 20),

                // ── FAQ ──────────────────────────────────────────────────
                _FaqSection(
                  faqs: t.faqs,
                  expandedIndex: _expandedFaq,
                  color: t.primary,
                  onToggle: (i) =>
                      setState(() => _expandedFaq = _expandedFaq == i ? null : i),
                ),
                const SizedBox(height: 20),

                // ── Support banner ───────────────────────────────────────
                _SupportBanner(theme: t),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _heroTag(String category) {
    switch (category) {
      case 'fleet_owner':
        return 'Scale your fleet business';
      case 'service_provider':
        return 'Grow your business';
      default:
        return 'Boost your professional career';
    }
  }
}

// ── Active subscription banner ────────────────────────────────────────────────

class _ActiveSubscriptionBanner extends StatelessWidget {
  final UserSubscription sub;
  final Color color;
  final VoidCallback? onCancel;

  const _ActiveSubscriptionBanner({
    required this.sub,
    required this.color,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final expiring = sub.expiringSoon;
    final accentColor =
        expiring ? const Color(0xFFF59E0B) : const Color(0xFF22C55E);
    final bgColor =
        expiring ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4);
    final textColor =
        expiring ? const Color(0xFF92400E) : const Color(0xFF14532D);
    final subTextColor =
        expiring ? const Color(0xFF92400E) : const Color(0xFF166534);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  expiring ? Iconsax.warning_2 : Iconsax.shield_tick,
                  size: 22,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Active Subscription',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              fontFamily: 'Poppins'),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            sub.status.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${sub.daysRemaining} days remaining  •  Expires ${_fmt(sub.endDate)}',
                      style: TextStyle(
                          fontSize: 11,
                          color: subTextColor,
                          fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onCancel != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Iconsax.close_circle,
                    size: 15, color: Color(0xFFEF4444)),
                label: const Text('Cancel Subscription',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFEF4444),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: Color(0xFFEF4444), width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]} ${d.year}';
}

// ── Plan card ─────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final _RoleTheme theme;
  final bool isCurrent;
  final bool isProcessing;
  final VoidCallback onSubscribe;

  const _PlanCard({
    required this.plan,
    required this.theme,
    required this.isCurrent,
    required this.isProcessing,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final isFree = plan.pricing.amount == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent
              ? const Color(0xFF22C55E)
              : plan.isRecommended
                  ? t.primary
                  : const Color(0xFFE5E7EB),
          width: isCurrent || plan.isRecommended ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (plan.isRecommended ? t.primary : Colors.black)
                .withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge row
          if (plan.isRecommended || isCurrent)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isCurrent ? const Color(0xFF22C55E) : t.primary,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCurrent ? Icons.check_circle_rounded : Iconsax.star1,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isCurrent ? 'Current Plan' : 'Recommended',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + name
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isFree
                              ? [
                                  const Color(0xFFF3F4F6),
                                  const Color(0xFFE5E7EB)
                                ]
                              : [t.primary, t.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isFree
                            ? Iconsax.briefcase
                            : plan.isRecommended
                                ? Iconsax.medal
                                : Iconsax.crown,
                        size: 26,
                        color: isFree
                            ? const Color(0xFF6B7280)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.name,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                  fontFamily: 'Poppins')),
                          if (plan.description != null &&
                              plan.description!.isNotEmpty)
                            Text(plan.description!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                    fontFamily: 'Poppins')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isFree
                          ? 'Free'
                          : '₹${plan.pricing.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: isFree
                              ? const Color(0xFF6B7280)
                              : t.primary,
                          fontFamily: 'Poppins'),
                    ),
                    if (!isFree) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          '/${plan.pricing.duration}',
                          style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontFamily: 'Poppins'),
                        ),
                      ),
                    ],
                  ],
                ),
                if (plan.pricing.discount != null &&
                    plan.pricing.discount! > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Save ${plan.pricing.discount!.toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF22C55E),
                          fontFamily: 'Poppins'),
                    ),
                  ),

                // Limit chips
                if (_hasLimits(plan.limits)) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _limitChips(plan.limits, t),
                  ),
                ],

                // Features
                if (plan.features.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ...plan.features.take(5).map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: t.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check_rounded,
                                  size: 12, color: t.primary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(f,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF374151),
                                      fontFamily: 'Poppins')),
                            ),
                          ],
                        ),
                      )),
                  if (plan.features.length > 5)
                    Text(
                      '+ ${plan.features.length - 5} more features',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: t.primary,
                          fontFamily: 'Poppins'),
                    ),
                ],

                // CTA button
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isCurrent
                        ? _ctaButton(
                            key: const ValueKey('current'),
                            label: 'Current Plan',
                            icon: Icons.check_circle_rounded,
                            bg: const Color(0xFFF0FDF4),
                            fg: const Color(0xFF22C55E),
                            onTap: null,
                          )
                        : isProcessing
                            ? _ctaButton(
                                key: const ValueKey('processing'),
                                label: 'Processing…',
                                icon: null,
                                bg: t.primaryLight,
                                fg: t.primary,
                                loading: true,
                                onTap: null,
                              )
                            : _ctaButton(
                                key: ValueKey(plan.id),
                                label: isFree
                                    ? 'Get Started Free'
                                    : 'Subscribe Now',
                                icon: Icons.arrow_forward_rounded,
                                bg: plan.isRecommended
                                    ? t.primary
                                    : t.primaryLight,
                                fg: plan.isRecommended
                                    ? Colors.white
                                    : t.primary,
                                onTap: onSubscribe,
                              ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ctaButton({
    required Key key,
    required String label,
    required IconData? icon,
    required Color bg,
    required Color fg,
    bool loading = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: fg))
            else ...[
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: fg,
                      fontFamily: 'Poppins')),
              if (icon != null) ...[
                const SizedBox(width: 6),
                Icon(icon, size: 18, color: fg),
              ],
            ],
          ],
        ),
      ),
    );
  }

  bool _hasLimits(SubscriptionLimits l) =>
      l.maxJobPosts != null ||
      l.maxVehicles != null ||
      l.maxDrivers != null ||
      l.commissionRate != null ||
      l.maxListings != null ||
      l.maxServiceRequests != null;

  List<Widget> _limitChips(SubscriptionLimits l, _RoleTheme t) {
    final chips = <Widget>[];
    void add(IconData icon, String text, Color bg, Color fg) {
      chips.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: fg,
                  fontFamily: 'Poppins')),
        ]),
      ));
    }

    if (l.maxJobPosts != null) {
      add(Iconsax.briefcase, '${l.maxJobPosts} Applications', t.primaryLight,
          t.primary);
    }
    if (l.maxVehicles != null) {
      add(Iconsax.truck, '${l.maxVehicles} Vehicles',
          const Color(0xFFEFF6FF), const Color(0xFF3B82F6));
    }
    if (l.maxDrivers != null) {
      add(Iconsax.profile_2user, '${l.maxDrivers} Drivers',
          const Color(0xFFF0FDF4), const Color(0xFF22C55E));
    }
    if (l.commissionRate != null) {
      add(Iconsax.percentage_circle,
          '${l.commissionRate!.toStringAsFixed(0)}% Commission',
          const Color(0xFFFFFBEB), const Color(0xFFF59E0B));
    }
    if (l.maxListings != null) {
      add(Iconsax.receipt_1, '${l.maxListings} Listings',
          const Color(0xFFF5F3FF), const Color(0xFF8B5CF6));
    }
    if (l.maxServiceRequests != null) {
      add(Iconsax.setting_2, '${l.maxServiceRequests} Requests',
          const Color(0xFFF5F3FF), const Color(0xFF8B5CF6));
    }
    return chips;
  }
}

// ── Why premium section ───────────────────────────────────────────────────────

class _WhyPremium extends StatelessWidget {
  final _RoleTheme theme;
  const _WhyPremium({required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [t.primary, t.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Iconsax.shield_tick,
                    size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Why Go Premium?',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          fontFamily: 'Poppins')),
                  Text('Accelerate your growth',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                          fontFamily: 'Poppins')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: t.benefits
                .map((b) => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: t.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                Icon(b.icon, size: 16, color: t.primary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(b.title,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                        fontFamily: 'Poppins'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Text(b.desc,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF6B7280),
                                        fontFamily: 'Poppins'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── FAQ section ───────────────────────────────────────────────────────────────

class _FaqSection extends StatelessWidget {
  final List<_Faq> faqs;
  final int? expandedIndex;
  final Color color;
  final void Function(int) onToggle;

  const _FaqSection({
    required this.faqs,
    required this.expandedIndex,
    required this.color,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(Iconsax.message_question, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Frequently Asked Questions',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          fontFamily: 'Poppins')),
                  Text('Everything you need to know',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                          fontFamily: 'Poppins')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...faqs.asMap().entries.map((entry) {
            final i = entry.key;
            final faq = entry.value;
            final expanded = expandedIndex == i;
            return Column(
              children: [
                if (i > 0)
                  const Divider(color: Color(0xFFE5E7EB), height: 1),
                GestureDetector(
                  onTap: () => onToggle(i),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(faq.q,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                  fontFamily: 'Poppins')),
                        ),
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF6B7280),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(faq.a,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            fontFamily: 'Poppins',
                            height: 1.5)),
                  ),
                  crossFadeState: expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Support banner ────────────────────────────────────────────────────────────

class _SupportBanner extends StatelessWidget {
  final _RoleTheme theme;
  const _SupportBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [t.primary, t.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Questions about your plan?',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Poppins')),
                SizedBox(height: 4),
                Text('Our team is available to help you anytime.',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Contact Us',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: t.primary,
                    fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}

// ── Loading / error / empty helpers ──────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final Color color;
  const _LoadingView({required this.color});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: color),
            const SizedBox(height: 16),
            const Text('Loading plans…',
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Poppins')),
          ],
        ),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Color color;
  final VoidCallback onRetry;
  const _ErrorView(
      {required this.message, required this.color, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.warning_2, size: 48, color: color),
              const SizedBox(height: 16),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Poppins')),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Iconsax.refresh, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ),
      );
}

class _EmptyPlans extends StatelessWidget {
  final Color color;
  const _EmptyPlans({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Icon(Iconsax.receipt_disscount, size: 48, color: color),
            const SizedBox(height: 12),
            const Text('No plans available right now.',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Poppins')),
          ],
        ),
      );
}
