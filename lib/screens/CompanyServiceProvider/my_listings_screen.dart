import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../theme/design_system.dart';
import '../../core/auth/auth_service.dart';
import '../../models/service_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../controllers/Transport/service_provider_controller.dart';
import '../../controllers/ServiceProvider/service_provider_home_controller.dart';
import 'add_service_screen.dart';
import 'service_details_screen.dart';

/// My Listings (Services) — rebuilt on the Wheelboard design system.
/// Fixes: delete previously failed for everyone (`_userId` was never set);
/// removed the fake hardcoded "Updated 2 days ago" line.
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ServiceProviderController _serviceProviderController =
      Get.put(ServiceProviderController(), permanent: false);
  late final ServiceProviderHomeController _homeController;
  String _selectedFilter = 'All';

  static const _filters = [
    'All',
    'Published',
    'Draft',
    'Flagged',
    'Unpublished',
  ];

  @override
  void initState() {
    super.initState();
    _homeController = Get.isRegistered<ServiceProviderHomeController>()
        ? Get.find<ServiceProviderHomeController>()
        : Get.put(ServiceProviderHomeController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeController.fetchMyServices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ServiceModel> get _filteredServices {
    var result = List<ServiceModel>.from(_homeController.services);

    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((s) {
        final t = s.serviceTitle.toLowerCase().contains(q);
        final d = (s.description ?? '').toLowerCase().contains(q);
        return t || d;
      }).toList();
    }

    if (_selectedFilter != 'All') {
      result = result
          .where((s) => _statusOf(s).toLowerCase() == _selectedFilter.toLowerCase())
          .toList();
    }
    return result;
  }

  /// Canonical status string for a service (Published/Draft/Flagged/Unpublished).
  String _statusOf(ServiceModel s) {
    final raw = s.status?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    return s.isAvailable ? 'Published' : 'Draft';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        backgroundColor: AppPalette.card,
        elevation: 0.5,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppPalette.textDark),
                onPressed: () => Get.back(),
              )
            : null,
        automaticallyImplyLeading: Navigator.canPop(context),
        centerTitle: false,
        title: Text('My Listings', style: AppText.h2),
      ),
      body: Column(
        children: [
          _searchAndFilter(),
          Expanded(
            child: Obx(() {
              if (_homeController.isLoadingServices.value) {
                return const AppLoading(message: 'Loading services…');
              }
              final services = _filteredServices;
              if (services.isEmpty) {
                return RefreshIndicator(
                  color: AppPalette.primary,
                  onRefresh: _homeController.fetchMyServices,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: AppEmptyState(
                          icon: Iconsax.box,
                          title: _selectedFilter == 'All'
                              ? 'No services yet'
                              : 'No $_selectedFilter services',
                          subtitle:
                              'Create a service with the + button to get started.',
                        ),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: AppPalette.primary,
                onRefresh: _homeController.fetchMyServices,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: services.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _serviceCard(services[i]),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _searchAndFilter() {
    return Container(
      color: AppPalette.card,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: AppText.bodySm,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search services…',
              hintStyle: AppText.caption,
              prefixIcon:
                  const Icon(Iconsax.search_normal, size: 18, color: AppPalette.textFaint),
              filled: true,
              fillColor: AppPalette.bg,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: AppRadius.rMd,
                  borderSide: const BorderSide(color: AppPalette.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.rMd,
                  borderSide: const BorderSide(color: AppPalette.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.rMd,
                  borderSide: const BorderSide(color: AppPalette.primary)),
            ),
          ),
          AppSpacing.vGapMd,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final active = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: active ? AppPalette.primary : AppPalette.card,
                        borderRadius: AppRadius.rPill,
                        border: Border.all(
                            color:
                                active ? AppPalette.primary : AppPalette.border),
                      ),
                      child: Text(f,
                          style: AppText.label
                              .on(active ? Colors.white : AppPalette.textGrey)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(ServiceModel service) {
    final category = (service.serviceCategory != null &&
            service.serviceCategory!.isNotEmpty)
        ? service.serviceCategory!
        : (service.businessType.isNotEmpty
            ? service.businessType
            : (service.city.isNotEmpty ? service.city : 'Service'));
    final status = _statusOf(service);

    return AppCard(
      onTap: () =>
          Get.to(() => ServiceDetailsScreen(serviceId: service.serviceId)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  service.serviceTitle.isNotEmpty
                      ? service.serviceTitle
                      : 'Untitled Service',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitle,
                ),
              ),
              AppSpacing.hGapSm,
              _statusBadge(status),
            ],
          ),
          AppSpacing.vGapSm,
          Row(
            children: [
              _categoryChip(category),
            ],
          ),
          if (status.toLowerCase() == 'flagged' &&
              (service.flagReason?.isNotEmpty ?? false)) ...[
            AppSpacing.vGapSm,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppPalette.dangerBg,
                borderRadius: AppRadius.rSm,
                border: Border.all(color: AppPalette.danger.withValues(alpha: 0.2)),
              ),
              child: Text('Reason: ${service.flagReason}',
                  style: AppText.caption.on(AppPalette.danger)),
            ),
          ],
          AppSpacing.vGapSm,
          Text(
            service.description ?? 'No description available',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption,
          ),
          AppSpacing.vGapMd,
          Row(
            children: [
              Expanded(
                child: _cardAction(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  color: AppPalette.blue,
                  onTap: () => Get.to(() => AddServiceScreen(service: service)),
                ),
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: _cardAction(
                  icon: service.isAvailable ? Iconsax.eye_slash : Iconsax.eye,
                  label: service.isAvailable ? 'Unpublish' : 'Publish',
                  color: service.isAvailable ? AppPalette.amber : AppPalette.green,
                  onTap: () =>
                      _homeController.togglePublishStatus(service.serviceId),
                ),
              ),
              AppSpacing.hGapSm,
              GestureDetector(
                onTap: () => _showDeleteDialog(service),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppPalette.dangerBg,
                    borderRadius: AppRadius.rMd,
                  ),
                  child: const Icon(Iconsax.trash,
                      size: 16, color: AppPalette.danger),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: AppRadius.rMd,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: AppText.label.on(color)),
        ]),
      ),
    );
  }

  Widget _categoryChip(String category) {
    Color bg;
    Color fg;
    switch (category.toLowerCase()) {
      case 'tyre repair':
      case 'tyre':
        bg = AppPalette.blueBg;
        fg = AppPalette.blue;
        break;
      case 'engine':
        bg = const Color(0xFFF3E8FF);
        fg = AppPalette.purple;
        break;
      case 'oil':
        bg = AppPalette.amberBg;
        fg = AppPalette.amber;
        break;
      case 'brake':
        bg = AppPalette.dangerBg;
        fg = AppPalette.danger;
        break;
      default:
        bg = AppPalette.primaryLight;
        fg = AppPalette.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rPill),
      child: Text(category, style: AppText.micro.on(fg)),
    );
  }

  Widget _statusBadge(String status) {
    late final Color bg;
    late final Color fg;
    late final IconData icon;
    switch (status.toLowerCase()) {
      case 'published':
        bg = AppPalette.greenBg;
        fg = AppPalette.green;
        icon = Icons.check_circle;
        break;
      case 'flagged':
        bg = AppPalette.dangerBg;
        fg = AppPalette.danger;
        icon = Iconsax.warning_2;
        break;
      case 'unpublished':
        bg = AppPalette.amberBg;
        fg = AppPalette.amber;
        icon = Iconsax.eye_slash;
        break;
      default: // Draft
        bg = AppPalette.bg;
        fg = AppPalette.textGrey;
        icon = Icons.access_time;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rSm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(status, style: AppText.micro.on(fg)),
        ],
      ),
    );
  }

  void _showDeleteDialog(ServiceModel service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rXl),
        title: Text('Delete service?', style: AppText.title),
        content: Text(
          'Are you sure you want to delete "${service.serviceTitle}"?',
          style: AppText.bodySm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                Text('Cancel', style: AppText.subtitle.on(AppPalette.textGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteService(service);
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

  Future<void> _deleteService(ServiceModel service) async {
    // The legacy code read userId from an unset field, so delete always failed
    // with "User ID not found". Use the authenticated session id instead.
    final userId = AuthService.to.userId;
    if (userId.isEmpty) {
      SnackBarHelper.error('User ID not found. Please login again.');
      return;
    }
    final ok =
        await _serviceProviderController.deleteService(service.serviceId, userId);
    if (ok) {
      await _homeController.fetchMyServices();
    }
  }
}
