import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/ServiceProvider/service_provider_home_controller.dart';
import '../../controllers/Transport/service_provider_controller.dart';
import '../../models/service_model.dart';
import '../../theme/design_system.dart';
import '../../utils/constants.dart';
import '../../utils/share_service.dart';
import '../../widgets/custom_snackbar.dart';
import 'add_service_screen.dart';
import 'booking_details_screen.dart';

/// Service detail — mirrors the wheelboard-fe `business/listings/[id]` page:
/// hero gallery, pricing, about + tags, contact (tap-to-call/email),
/// availability, stats, and View Assigns. Reads the real backend keys
/// (nested `pricing` / `availability` / `contactInfo`) — the previous version
/// read legacy flat keys, so pricing/hours/contact came back empty.
class ServiceDetailsScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailsScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  late final ServiceProviderHomeController _home;
  final ServiceProviderController _serviceCtrl =
      Get.put(ServiceProviderController(), permanent: false);

  int _activeImage = 0;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _home = Get.isRegistered<ServiceProviderHomeController>()
        ? Get.find<ServiceProviderHomeController>()
        : Get.put(ServiceProviderHomeController());
    _home.fetchServiceDetails(widget.serviceId);
  }

  Map<String, dynamic> get _s => _home.serviceDetails.value ?? const {};

  // ── typed accessors over the raw service map ───────────────────────────────
  String get _title =>
      (_s['title'] ?? _s['serviceTitle'] ?? 'Service').toString();
  String get _category =>
      (_s['category'] ?? _s['businessType'] ?? _s['serviceCategory'] ?? '')
          .toString();
  String get _status {
    final raw = _s['status']?.toString();
    if (raw != null && raw.isNotEmpty) return raw;
    return _s['isAvailable'] == true ? 'Published' : 'Draft';
  }

  List<String> get _images =>
      (_s['images'] as List?)?.map((e) => e.toString()).toList() ?? const [];

  Map<String, dynamic> get _pricing =>
      _s['pricing'] is Map ? Map<String, dynamic>.from(_s['pricing']) : const {};
  Map<String, dynamic> get _availability => _s['availability'] is Map
      ? Map<String, dynamic>.from(_s['availability'])
      : const {};
  Map<String, dynamic> get _contact => _s['contactInfo'] is Map
      ? Map<String, dynamic>.from(_s['contactInfo'])
      : const {};

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_home.isLoadingServiceDetails.value) {
        return const Scaffold(
            backgroundColor: AppPalette.bg,
            body: AppLoading(message: 'Loading service details…'));
      }
      if (_home.serviceDetails.value == null) {
        return Scaffold(
          backgroundColor: AppPalette.bg,
          appBar: AppBar(
            backgroundColor: AppPalette.primary,
            leading: const BackButton(color: Colors.white),
          ),
          body: const AppErrorState(message: 'Service details not found'),
        );
      }

      return Scaffold(
        backgroundColor: AppPalette.bg,
        body: CustomScrollView(
          slivers: [
            _heroAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_images.length > 1) _thumbnails(),
                  if (_images.length > 1) AppSpacing.vGapLg,
                  _statsCard(),
                  AppSpacing.vGapLg,
                  _pricingCard(),
                  AppSpacing.vGapLg,
                  _aboutCard(),
                  AppSpacing.vGapLg,
                  _contactCard(),
                  AppSpacing.vGapLg,
                  _availabilityCard(),
                  AppSpacing.vGapLg,
                  _actionRow(),
                ]),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _viewAssignsBar(),
      );
    });
  }

  // ── Hero ────────────────────────────────────────────────────────────────
  Widget _heroAppBar() {
    final img = _images.isNotEmpty ? _images[_activeImage] : null;
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppPalette.primary,
      leading: const BackButton(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Iconsax.share, color: Colors.white),
          onPressed: _share,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            img != null
                ? Image.network(img,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Image.asset(AppImages.service, fit: BoxFit.cover))
                : Image.asset(AppImages.service, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statusPill(),
                  AppSpacing.vGapSm,
                  Text(_title,
                      style: AppText.h1.on(Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  if (_category.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(_category, style: AppText.bodySm.on(Colors.white70)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill() {
    final flagged = _status.toLowerCase() == 'flagged';
    final published = _status.toLowerCase() == 'published';
    final color = flagged
        ? AppPalette.danger
        : published
            ? AppPalette.green
            : AppPalette.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.rPill),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
            flagged
                ? Iconsax.warning_2
                : published
                    ? Iconsax.tick_circle
                    : Iconsax.clock,
            color: Colors.white,
            size: 13),
        const SizedBox(width: 5),
        Text(_status, style: AppText.micro.on(Colors.white)),
      ]),
    );
  }

  Widget _thumbnails() {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        separatorBuilder: (_, __) => AppSpacing.hGapSm,
        itemBuilder: (_, i) {
          final selected = i == _activeImage;
          return GestureDetector(
            onTap: () => setState(() => _activeImage = i),
            child: Container(
              width: 70,
              decoration: BoxDecoration(
                borderRadius: AppRadius.rMd,
                border: Border.all(
                    color: selected ? AppPalette.primary : AppPalette.border,
                    width: selected ? 2 : 1),
              ),
              child: ClipRRect(
                borderRadius: AppRadius.rMd,
                child: Image.network(_images[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppPalette.border)),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Stats ─────────────────────────────────────────────────────────────────
  Widget _statsCard() {
    final rating = (_s['rating'] as num?)?.toDouble() ?? 0;
    final reviews = (_s['reviewCount'] as num?)?.toInt() ?? 0;
    final jobs = (_s['completedJobs'] as num?)?.toInt() ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        gradient: AppPalette.brandGradient,
        borderRadius: AppRadius.rXl,
      ),
      child: Row(
        children: [
          _stat(Iconsax.briefcase, '$jobs', 'Jobs Done'),
          _statDivider(),
          _stat(Iconsax.star1, rating > 0 ? rating.toStringAsFixed(1) : '—',
              'Rating'),
          _statDivider(),
          _stat(Iconsax.profile_2user, '$reviews', 'Reviews'),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Expanded(
      child: Column(children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 6),
        Text(value, style: AppText.h2.on(Colors.white)),
        Text(label, style: AppText.caption.on(Colors.white70)),
      ]),
    );
  }

  Widget _statDivider() =>
      Container(width: 1, height: 40, color: Colors.white24);

  // ── Pricing ─────────────────────────────────────────────────────────────
  Widget _pricingCard() {
    final amount = _pricing['amount'] ?? _s['amount'] ?? _s['price'];
    final type = (_pricing['type'] ?? _s['pricingOption'])?.toString();
    final currency = (_pricing['currency'] ?? '₹').toString();
    final details = _pricing['details']?.toString();
    final amountNum =
        amount is num ? amount : double.tryParse(amount?.toString() ?? '');
    final onRequest = (type?.toLowerCase().contains('request') ?? false) ||
        amountNum == null ||
        amountNum == 0;

    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppPalette.primaryLight, borderRadius: AppRadius.rLg),
            child: const Icon(Iconsax.money_4, color: AppPalette.primary),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pricing', style: AppText.label),
                const SizedBox(height: 2),
                Text(
                  onRequest
                      ? 'On Request'
                      : '$currency${amountNum % 1 == 0 ? amountNum.toInt() : amountNum}',
                  style: AppText.h2.on(AppPalette.primary),
                ),
                Text(
                  onRequest
                      ? 'Pay after completion'
                      : (type?.toLowerCase() == 'hourly'
                          ? 'Per hour'
                          : 'Fixed rate'),
                  style: AppText.caption,
                ),
                if (details != null && details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(details, style: AppText.caption),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── About ─────────────────────────────────────────────────────────────────
  Widget _aboutCard() {
    final desc = (_s['detailedDescription']?.toString().isNotEmpty == true)
        ? _s['detailedDescription'].toString()
        : (_s['description']?.toString() ?? 'No description available');
    final tags =
        (_s['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About this Service', style: AppText.h3),
          AppSpacing.vGapMd,
          Text(desc, style: AppText.body),
          if (tags.isNotEmpty) ...[
            AppSpacing.vGapMd,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: AppPalette.bg,
                            borderRadius: AppRadius.rPill),
                        child: Text('#$t', style: AppText.caption),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ── Contact ─────────────────────────────────────────────────────────────
  Widget _contactCard() {
    final phone = (_contact['phone'] ?? _s['contactNumber'])?.toString();
    final email = _contact['email']?.toString();
    final location = (_s['location'] ??
            [_s['fullAddress'], _s['city']]
                .where((e) => (e?.toString().isNotEmpty ?? false))
                .join(', '))
        .toString();

    final rows = <Widget>[];
    if (phone != null && phone.isNotEmpty) {
      rows.add(_contactRow(Iconsax.call, AppPalette.green, 'Phone', phone,
          () => _launch('tel:$phone')));
    }
    if (email != null && email.isNotEmpty) {
      rows.add(_contactRow(Iconsax.sms, AppPalette.blue, 'Email', email,
          () => _launch('mailto:$email')));
    }
    if (location.isNotEmpty) {
      rows.add(_contactRow(
          Iconsax.location, AppPalette.danger, 'Location', location, null));
    }
    if (rows.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Information', style: AppText.h3),
          AppSpacing.vGapMd,
          ...rows,
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, Color color, String label, String value,
      VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rMd,
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.rPill),
            child: Icon(icon, color: color, size: 18),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.caption),
                Text(value, style: AppText.subtitle, maxLines: 2),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Iconsax.arrow_right_3,
                size: 16, color: AppPalette.textFaint),
        ]),
      ),
    );
  }

  // ── Availability ──────────────────────────────────────────────────────────
  Widget _availabilityCard() {
    final hours = (_availability['hours'] ??
            '${_s['businessHoursFrom'] ?? _s['businessFrom'] ?? ''} - ${_s['businessHoursTo'] ?? _s['businessTo'] ?? ''}')
        .toString()
        .trim();
    final days = (_availability['days'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        (_s['daysOpen']?.toString().split(',').map((e) => e.trim()).toList() ??
            const []);
    final hasHours = hours.isNotEmpty && hours != '-';
    if (!hasHours && days.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Availability', style: AppText.h3),
          if (hasHours) ...[
            AppSpacing.vGapMd,
            Row(children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                    color: AppPalette.purple.withValues(alpha: 0.12),
                    borderRadius: AppRadius.rPill),
                child: const Icon(Iconsax.clock,
                    color: AppPalette.purple, size: 18),
              ),
              AppSpacing.hGapMd,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Working Hours', style: AppText.caption),
                  Text(hours, style: AppText.subtitle),
                ],
              ),
            ]),
          ],
          if (days.isNotEmpty) ...[
            AppSpacing.vGapMd,
            Text('Available Days', style: AppText.caption),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: days
                  .where((d) => d.isNotEmpty)
                  .map((d) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppPalette.greenBg,
                            borderRadius: AppRadius.rPill),
                        child: Text(
                            d.length >= 3 ? d.substring(0, 3) : d,
                            style: AppText.micro.on(AppPalette.green)),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────
  Widget _actionRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppPrimaryButton(
                label: 'Edit',
                icon: Iconsax.edit,
                color: AppPalette.blue,
                onPressed: () => Get.to(
                    () => AddServiceScreen(service: ServiceModel.fromJson(_s))),
              ),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: AppPrimaryButton(
                label: 'Delete',
                icon: Iconsax.trash,
                color: AppPalette.danger,
                onPressed: _confirmDelete,
              ),
            ),
          ],
        ),
        AppSpacing.vGapMd,
        Row(
          children: [
            Expanded(
              child: AppSecondaryButton(
                label: 'Share',
                icon: Iconsax.share,
                color: AppPalette.textGrey,
                onPressed: _share,
              ),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: AppSecondaryButton(
                label: _saved ? 'Saved' : 'Save',
                icon: _saved ? Iconsax.heart5 : Iconsax.heart,
                color: _saved ? AppPalette.primary : AppPalette.textGrey,
                onPressed: () {
                  setState(() => _saved = !_saved);
                  SnackBarHelper.success(_saved
                      ? 'Service saved to favorites'
                      : 'Removed from favorites');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _viewAssignsBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16,
          12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppPalette.card,
        border: Border(top: BorderSide(color: AppPalette.border)),
      ),
      child: AppPrimaryButton(
        label: 'View Assignments',
        icon: Iconsax.task_square,
        onPressed: () =>
            Get.to(() => BookingDetailsScreen(serviceId: widget.serviceId)),
      ),
    );
  }

  // ── Behaviour ─────────────────────────────────────────────────────────────
  Future<void> _launch(String uri) async {
    final u = Uri.parse(uri);
    if (await canLaunchUrl(u)) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    }
  }

  void _share() {
    ShareService.shareService(
      serviceId: widget.serviceId,
      title: _title,
      businessName: (_s['businessName'] ?? '').toString(),
      category: _category.isEmpty ? 'Service' : _category,
      description: (_s['description'] ?? '').toString(),
      location: (_s['location'] ??
              '${_s['fullAddress'] ?? ''}, ${_s['city'] ?? ''}')
          .toString(),
      price: '₹${_pricing['amount'] ?? _s['amount'] ?? _s['price'] ?? 0}',
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rXl),
        title: Text('Delete service?', style: AppText.title),
        content: Text(
            'Are you sure you want to delete "$_title"? This cannot be undone.',
            style: AppText.bodySm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: AppText.subtitle.on(AppPalette.textGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await _serviceCtrl.deleteService(widget.serviceId);
              if (ok) {
                await _home.fetchMyServices();
                if (mounted) Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
            ),
            child: Text('Delete', style: AppText.subtitle.on(Colors.white)),
          ),
        ],
      ),
    );
  }
}
