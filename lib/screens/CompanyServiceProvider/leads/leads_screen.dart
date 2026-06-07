import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/auth/auth_service.dart';
import '../../../models/lead_model.dart';
import '../../../services/lead_service.dart';
import '../../../theme/design_system.dart';
import 'lead_detail_screen.dart';
import 'lead_status_style.dart';

/// Service-provider Leads (CRM) — mirrors web `/company/leads`. Shows lead
/// stats, a status filter and the list of leads. Built on the design system.
class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final _service = LeadService();
  List<Lead> _leads = [];
  LeadStats _stats = LeadStats.empty;
  bool _loading = true;
  String? _error;
  String _filter = 'All';

  String get _providerId => AuthService.to.userId;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.getProviderLeads(_providerId),
        _service.getStats(_providerId),
      ]);
      if (!mounted) return;
      setState(() {
        _leads = results[0] as List<Lead>;
        _stats = results[1] as LeadStats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<Lead> get _filtered =>
      _filter == 'All' ? _leads : _leads.where((l) => l.status == _filter).toList();

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
        title: Text('Leads', style: AppText.h2),
      ),
      body: _loading
          ? const AppLoading(message: 'Loading leads…')
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
    final filtered = _filtered;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      children: [
        _statsStrip(),
        AppSpacing.vGapLg,
        _statusFilter(),
        AppSpacing.vGapLg,
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: AppEmptyState(
              icon: Iconsax.user_octagon,
              title: _filter == 'All' ? 'No leads yet' : 'No $_filter leads',
              subtitle: 'New leads from service enquiries will appear here.',
            ),
          )
        else
          ...filtered.map(_leadCard),
      ],
    );
  }

  Widget _statsStrip() {
    return Row(children: [
      _stat('Total', '${_stats.total}', Iconsax.people, AppPalette.blue),
      AppSpacing.hGapMd,
      _stat('Converted', '${_stats.converted}', Iconsax.tick_circle, AppPalette.green),
      AppSpacing.hGapMd,
      _stat('Conv. rate', '${_stats.conversionRate.toStringAsFixed(0)}%',
          Iconsax.chart_2, AppPalette.primary),
    ]);
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.rSm),
            child: Icon(icon, size: 16, color: color),
          ),
          AppSpacing.vGapSm,
          Text(value, style: AppText.h3.on(color)),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.micro.weight(FontWeight.w400)),
        ]),
      ),
    );
  }

  Widget _statusFilter() {
    final options = ['All', ...kLeadStatuses];
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: options.map((s) {
          final active = _filter == s;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppPalette.primary : AppPalette.card,
                  borderRadius: AppRadius.rPill,
                  border: Border.all(
                      color: active ? AppPalette.primary : AppPalette.border),
                ),
                child: Text(s,
                    style: AppText.label.on(
                        active ? Colors.white : AppPalette.textGrey)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _leadCard(Lead lead) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () async {
          await Get.to(() => LeadDetailScreen(leadId: lead.id));
          _fetch();
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(lead.companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitle),
            ),
            AppSpacing.hGapSm,
            LeadStatusStyle.badge(lead.status),
          ]),
          if (lead.serviceName != null && lead.serviceName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(lead.serviceName!, style: AppText.caption),
          ],
          AppSpacing.vGapSm,
          Row(children: [
            const Icon(Iconsax.routing, size: 12, color: AppPalette.textGrey),
            const SizedBox(width: 4),
            Text(lead.source, style: AppText.caption),
            const Spacer(),
            if (lead.estimatedValue != null && lead.estimatedValue! > 0)
              Text('₹${lead.estimatedValue!.toStringAsFixed(0)}',
                  style: AppText.label.on(AppPalette.green).weight(FontWeight.w700)),
          ]),
        ]),
      ),
    );
  }
}
