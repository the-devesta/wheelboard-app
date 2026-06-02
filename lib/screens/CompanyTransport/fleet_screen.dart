import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/Transport/fleet_controller.dart';
import '../../controllers/Transport/lease_controller.dart';
import '../../models/get_driver_model.dart';
import '../../models/get_vehicle_model.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/custom_snackbar.dart';
import 'Lease/lease_listings_screen.dart';
import 'Lease/incoming_bookings_screen.dart';
import 'Lease/my_booked_leases_screen.dart';
import 'Lease/create_lease_wizard.dart';
import 'Lease/marketplace_screen.dart';
import 'vehicle_detail_screen.dart';
import 'driver_profile.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _primary = Color(0xFFF36969);
const _primaryLight = Color(0xFFFFF1F1);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);

class FleetVehiclesScreen extends StatefulWidget {
  const FleetVehiclesScreen({super.key});

  @override
  State<FleetVehiclesScreen> createState() => _FleetVehiclesScreenState();
}

class _FleetVehiclesScreenState extends State<FleetVehiclesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final DriverController _ctrl = Get.put(DriverController());

  String _vehicleQuery = '';
  String _vehicleFilter = 'All';
  String _driverQuery = '';
  String _driverFilter = 'All';

  @override
  void initState() {
    super.initState();
    Get.put(LeaseController());
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildLeaseBar(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _VehiclesTab(
                  ctrl: _ctrl,
                  query: _vehicleQuery,
                  filter: _vehicleFilter,
                  onQueryChanged: (q) => setState(() => _vehicleQuery = q),
                  onFilterChanged: (f) => setState(() => _vehicleFilter = f),
                  onAdd: () => _showVehicleModal(context),
                ),
                _DriversTab(
                  ctrl: _ctrl,
                  query: _driverQuery,
                  filter: _driverFilter,
                  onQueryChanged: (q) => setState(() => _driverQuery = q),
                  onFilterChanged: (f) => setState(() => _driverFilter = f),
                  onAdd: () => _showDriverModal(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _card,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: _border,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: _textDark),
        onPressed: () => Get.back(),
      ),
      title: const Text('Fleet Management',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _textDark,
              fontFamily: 'Poppins')),
      actions: [
        Obx(() {
          final busy =
              _ctrl.isLoading.value || _ctrl.isVehicleLoading.value;
          return busy
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child:
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _primary)),
                )
              : IconButton(
                  icon: const Icon(Iconsax.refresh, size: 20, color: _textGrey),
                  onPressed: _ctrl.refresh,
                );
        }),
      ],
    );
  }

  // ── Lease quick-access bar ─────────────────────────────────────────────────

  Widget _buildLeaseBar() {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lease Marketplace',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textGrey,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _leaseChip(Iconsax.receipt_text, 'My Listings', const Color(0xFF3B82F6),
                    () => Get.to(() => const LeaseListingsScreen())),
                const SizedBox(width: 8),
                _leaseChip(Iconsax.add_circle, 'List Vehicle', _primary,
                    () => Get.to(() => const CreateLeaseWizard())),
                const SizedBox(width: 8),
                _leaseChip(Iconsax.document_download, 'Incoming', const Color(0xFF22C55E),
                    () => Get.to(() => const IncomingBookingsScreen())),
                const SizedBox(width: 8),
                _leaseChip(Iconsax.shop, 'Marketplace', const Color(0xFF10B981),
                    () => Get.to(() => const MarketplaceScreen())),
                const SizedBox(width: 8),
                _leaseChip(Iconsax.shopping_cart, 'My Leases', const Color(0xFF8B5CF6),
                    () => Get.to(() => const MyBookedLeasesScreen())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _leaseChip(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: _card,
      child: TabBar(
        controller: _tabCtrl,
        labelColor: _primary,
        unselectedLabelColor: _textGrey,
        indicatorColor: _primary,
        indicatorWeight: 2,
        labelStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
        unselectedLabelStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
        tabs: [
          Tab(
            child: Obx(() => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.truck, size: 16),
                    const SizedBox(width: 6),
                    Text('Vehicles (${_ctrl.vehicles.length})'),
                  ],
                )),
          ),
          Tab(
            child: Obx(() => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.people, size: 16),
                    const SizedBox(width: 6),
                    Text('Drivers (${_ctrl.drivers.length})'),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  // ── Add/Edit modals ────────────────────────────────────────────────────────

  void _showVehicleModal(BuildContext context, [Vehicle? vehicle]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VehicleModal(ctrl: _ctrl, vehicle: vehicle),
    );
  }

  void _showDriverModal(BuildContext context, [Driver? driver]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DriverModal(ctrl: _ctrl, driver: driver),
    );
  }
}

// ── Vehicles tab ──────────────────────────────────────────────────────────────

class _VehiclesTab extends StatelessWidget {
  final DriverController ctrl;
  final String query;
  final String filter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onAdd;

  const _VehiclesTab({
    required this.ctrl,
    required this.query,
    required this.filter,
    required this.onQueryChanged,
    required this.onFilterChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchFilterBar(
          query: query,
          onQueryChanged: onQueryChanged,
          filter: filter,
          filters: const ['All', 'Available', 'In-Transit', 'Assigned', 'Owned', 'Attached'],
          onFilterChanged: onFilterChanged,
          onAdd: onAdd,
          addLabel: 'Add Vehicle',
        ),
        Expanded(
          child: Obx(() {
            if (ctrl.isVehicleLoading.value && ctrl.vehicles.isEmpty) {
              return const Center(child: CustomLoader());
            }
            final list = ctrl.filteredVehicles(query, filter);
            if (list.isEmpty) {
              return _EmptyState(
                icon: Iconsax.truck,
                title: 'No vehicles found',
                subtitle: 'Add your first vehicle to get started',
                action: 'Add Vehicle',
                onAction: onAdd,
              );
            }
            return RefreshIndicator(
              color: _primary,
              onRefresh: ctrl.fetchVehicles,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _VehicleCard(
                  vehicle: list[i],
                  ctrl: ctrl,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final DriverController ctrl;
  const _VehicleCard({required this.vehicle, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final statusColor = _vehicleStatusColor(vehicle.status);
    final imgUrl = vehicle.imageUrls.isNotEmpty ? vehicle.imageUrls.first : null;

    return GestureDetector(
      onTap: () => Get.to(() => VehicleDetailScreen(vehicle: vehicle)),
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imgUrl != null
                    ? Image.network(imgUrl, width: 72, height: 72, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _VehiclePlaceholder())
                    : _VehiclePlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(vehicle.vehicleModel,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                  fontFamily: 'Poppins'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(vehicle.status.isEmpty ? 'Unknown' : vehicle.status,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                  fontFamily: 'Poppins')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(vehicle.vehicleNumber,
                        style: const TextStyle(
                            fontSize: 12, color: _textGrey, fontFamily: 'Poppins')),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _tag(vehicle.vehicleType, const Color(0xFF8B5CF6)),
                        const SizedBox(width: 6),
                        _tag(vehicle.ownershipType, const Color(0xFF3B82F6)),
                        if (vehicle.manufacturingYear > 0) ...[
                          const SizedBox(width: 6),
                          _tag('${vehicle.manufacturingYear}', const Color(0xFF6B7280)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  _IconBtn(
                    Iconsax.edit,
                    const Color(0xFF3B82F6),
                    () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _VehicleModal(ctrl: ctrl, vehicle: vehicle),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _IconBtn(
                    Iconsax.trash,
                    const Color(0xFFEF4444),
                    () => _confirmDelete(context, 'vehicle', vehicle.vehicleModel,
                        () => ctrl.deleteVehicle(vehicle.vehicleId)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _vehicleStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available': return const Color(0xFF22C55E);
      case 'in-transit': case 'in transit': return const Color(0xFF3B82F6);
      case 'assigned': return const Color(0xFFF59E0B);
      case 'maintenance': return const Color(0xFFEF4444);
      default: return _textGrey;
    }
  }
}

// ── Drivers tab ───────────────────────────────────────────────────────────────

class _DriversTab extends StatelessWidget {
  final DriverController ctrl;
  final String query;
  final String filter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onAdd;

  const _DriversTab({
    required this.ctrl,
    required this.query,
    required this.filter,
    required this.onQueryChanged,
    required this.onFilterChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchFilterBar(
          query: query,
          onQueryChanged: onQueryChanged,
          filter: filter,
          filters: const ['All', 'Available', 'On Trip', 'Hired'],
          onFilterChanged: onFilterChanged,
          onAdd: onAdd,
          addLabel: 'Add Driver',
        ),
        Expanded(
          child: Obx(() {
            if (ctrl.isLoading.value && ctrl.drivers.isEmpty) {
              return const Center(child: CustomLoader());
            }
            final list = ctrl.filteredDrivers(query, filter);
            if (list.isEmpty) {
              return _EmptyState(
                icon: Iconsax.people,
                title: 'No drivers found',
                subtitle: 'Add your first driver to get started',
                action: 'Add Driver',
                onAction: onAdd,
              );
            }
            return RefreshIndicator(
              color: _primary,
              onRefresh: ctrl.fetchDrivers,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _DriverCard(driver: list[i], ctrl: ctrl),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _DriverCard extends StatelessWidget {
  final Driver driver;
  final DriverController ctrl;
  const _DriverCard({required this.driver, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final imgUrl = driver.driverImagePath.isNotEmpty ? driver.driverImagePath : null;

    return GestureDetector(
      onTap: () => Get.to(() => DriverProfileScreen(driverId: driver.driverId)),
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _primaryLight, width: 2),
                ),
                child: ClipOval(
                  child: imgUrl != null
                      ? Image.network(imgUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _DriverPlaceholder(driver.fullName))
                      : _DriverPlaceholder(driver.fullName),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(driver.fullName,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                  fontFamily: 'Poppins'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (driver.status.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor(driver.status).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(driver.status,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _statusColor(driver.status),
                                    fontFamily: 'Poppins')),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(driver.contactNumber.isNotEmpty ? driver.contactNumber : '—',
                        style: const TextStyle(
                            fontSize: 12, color: _textGrey, fontFamily: 'Poppins')),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Iconsax.star1, size: 12, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        const Text('4.7',
                            style: TextStyle(
                                fontSize: 11,
                                color: _textGrey,
                                fontFamily: 'Poppins')),
                        const SizedBox(width: 10),
                        if (driver.vehicleType.isNotEmpty)
                          _tag(driver.vehicleType, const Color(0xFF8B5CF6)),
                        if (driver.experience.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _tag('${driver.experience} yrs', const Color(0xFF3B82F6)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  _IconBtn(
                    Iconsax.edit,
                    const Color(0xFF3B82F6),
                    () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _DriverModal(ctrl: ctrl, driver: driver),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _IconBtn(
                    Iconsax.trash,
                    const Color(0xFFEF4444),
                    () => _confirmDelete(context, 'driver', driver.fullName,
                        () => ctrl.deleteDriver(driver.driverId)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available': return const Color(0xFF22C55E);
      case 'on trip': case 'hired': return const Color(0xFF3B82F6);
      default: return _textGrey;
    }
  }
}

// ── Vehicle Add/Edit Modal ─────────────────────────────────────────────────────

class _VehicleModal extends StatefulWidget {
  final DriverController ctrl;
  final Vehicle? vehicle;
  const _VehicleModal({required this.ctrl, this.vehicle});

  @override
  State<_VehicleModal> createState() => _VehicleModalState();
}

class _VehicleModalState extends State<_VehicleModal> {
  final _modelCtrl = TextEditingController();
  final _regCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _ownership = 'Owned';
  String _category = 'Shipment';
  bool _saving = false;
  bool _verifying = false;
  final List<File> _images = [];

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    if (v != null) {
      _modelCtrl.text = v.vehicleModel;
      _regCtrl.text = v.vehicleNumber;
      _yearCtrl.text = v.manufacturingYear > 0 ? '${v.manufacturingYear}' : '';
      _descCtrl.text = v.description;
      _ownership = v.ownershipType.isEmpty ? 'Owned' : v.ownershipType;
      _category = v.vehicleType.isEmpty ? 'Shipment' : v.vehicleType;
    }
  }

  @override
  void dispose() {
    _modelCtrl.dispose();
    _regCtrl.dispose();
    _yearCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_regCtrl.text.trim().isEmpty) {
      SnackBarHelper.warning('Enter registration number first');
      return;
    }
    setState(() => _verifying = true);
    final data = await widget.ctrl.verifyVehicleRegistration(_regCtrl.text.trim());
    setState(() => _verifying = false);
    if (data != null) {
      _modelCtrl.text = data['model']?.toString() ?? _modelCtrl.text;
      _yearCtrl.text = data['year']?.toString() ?? _yearCtrl.text;
      SnackBarHelper.success('Vehicle details loaded');
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 75);
    if (picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _save() async {
    if (_modelCtrl.text.trim().isEmpty || _regCtrl.text.trim().isEmpty) {
      SnackBarHelper.warning('Model and registration are required');
      return;
    }
    setState(() => _saving = true);
    bool ok;
    if (widget.vehicle != null) {
      ok = await widget.ctrl.updateVehicle(
        vehicleId: widget.vehicle!.vehicleId,
        model: _modelCtrl.text.trim(),
        registrationNumber: _regCtrl.text.trim(),
        year: int.tryParse(_yearCtrl.text) ?? 0,
        ownership: _ownership,
        category: _category,
        description: _descCtrl.text.trim(),
        images: _images,
      );
    } else {
      ok = await widget.ctrl.createVehicle(
        model: _modelCtrl.text.trim(),
        registrationNumber: _regCtrl.text.trim(),
        year: int.tryParse(_yearCtrl.text) ?? 0,
        ownership: _ownership,
        category: _category,
        description: _descCtrl.text.trim(),
        images: _images,
      );
    }
    setState(() => _saving = false);
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.vehicle != null;
    return _ModalSheet(
      title: isEdit ? 'Edit Vehicle' : 'Add Vehicle',
      child: Column(
        children: [
          _ModalField('Model / Name', _modelCtrl, hint: 'e.g. Tata Prima', required: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ModalField('Registration No.', _regCtrl, hint: 'MH01AB1234', required: true)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _verifying ? null : _verify,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: _verifying ? _border : _primaryLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _primary.withValues(alpha: 0.3)),
                  ),
                  child: _verifying
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _primary))
                      : const Text('Verify', style: TextStyle(fontSize: 13, color: _primary, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ModalField('Year', _yearCtrl, hint: '2022', keyboard: TextInputType.number),
          const SizedBox(height: 12),
          _ModalDropdown('Ownership', _ownership, ['Owned', 'Attached', 'Rented'],
              (v) => setState(() => _ownership = v!)),
          const SizedBox(height: 12),
          _ModalDropdown('Category', _category, ['Shipment', 'Construction', 'Mining', 'Others'],
              (v) => setState(() => _category = v!)),
          const SizedBox(height: 12),
          _ModalField('Description', _descCtrl, hint: 'Optional notes', maxLines: 3),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Iconsax.gallery_add, color: _textGrey, size: 22),
                  const SizedBox(height: 6),
                  Text(_images.isEmpty ? 'Tap to add images' : '${_images.length} image(s) selected',
                      style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SaveButton(saving: _saving, onSave: _save),
        ],
      ),
    );
  }
}

// ── Driver Add/Edit Modal ──────────────────────────────────────────────────────

class _DriverModal extends StatefulWidget {
  final DriverController ctrl;
  final Driver? driver;
  const _DriverModal({required this.ctrl, this.driver});

  @override
  State<_DriverModal> createState() => _DriverModalState();
}

class _DriverModalState extends State<_DriverModal> {
  final _nameCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _dob;
  String _category = 'Shipment';
  String _status = 'Available';
  File? _image;
  bool _saving = false;

  static const _statusOptions = ['Available', 'On Trip', 'Off Duty'];

  @override
  void initState() {
    super.initState();
    final d = widget.driver;
    if (d != null) {
      _nameCtrl.text = d.fullName;
      _licenseCtrl.text = d.dlNo;
      _phoneCtrl.text = d.contactNumber;
      _expCtrl.text = d.experience;
      _descCtrl.text = d.description;
      _dob = d.dateOfBirth;
      _category = d.vehicleType.isEmpty ? 'Shipment' : d.vehicleType;
      // Normalize status to a valid enum value
      final rawStatus = d.status;
      _status = _statusOptions.contains(rawStatus) ? rawStatus : 'Available';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _licenseCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _expCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _pickDob() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(colorScheme: const ColorScheme.light(primary: _primary)),
        child: child!,
      ),
    );
    if (d != null) setState(() => _dob = d);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _licenseCtrl.text.trim().isEmpty || _dob == null) {
      SnackBarHelper.warning('Name, license, and date of birth are required');
      return;
    }
    setState(() => _saving = true);
    final dobIso = _dob!.toIso8601String();
    bool ok;
    if (widget.driver != null) {
      ok = await widget.ctrl.updateDriver(
        driverId: widget.driver!.driverId,
        name: _nameCtrl.text.trim(),
        licenseNumber: _licenseCtrl.text.trim(),
        dateOfBirth: dobIso,
        phoneNumber: _phoneCtrl.text.trim(),
        vehicleType: _category,
        experience: _expCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        status: _status,
        email: _emailCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        image: _image,
      );
    } else {
      ok = await widget.ctrl.createDriver(
        name: _nameCtrl.text.trim(),
        licenseNumber: _licenseCtrl.text.trim(),
        dateOfBirth: dobIso,
        phoneNumber: _phoneCtrl.text.trim(),
        vehicleType: _category,
        experience: _expCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        status: _status,
        email: _emailCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        image: _image,
      );
    }
    setState(() => _saving = false);
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.driver != null;
    return _ModalSheet(
      title: isEdit ? 'Edit Driver' : 'Add Driver',
      child: Column(
        children: [
          _ModalField('Full Name', _nameCtrl, hint: 'e.g. Rajesh Kumar', required: true),
          const SizedBox(height: 12),
          _ModalField('License Number', _licenseCtrl, hint: 'DL1234567890', required: true),
          const SizedBox(height: 12),
          _ModalField('Phone Number', _phoneCtrl, hint: '+91 9876543210',
              keyboard: TextInputType.phone),
          const SizedBox(height: 12),
          _ModalField('Email', _emailCtrl, hint: 'driver@example.com',
              keyboard: TextInputType.emailAddress),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickDob,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.calendar, size: 18, color: _textGrey),
                  const SizedBox(width: 10),
                  Text(
                    _dob == null ? 'Date of Birth (18+ required)' : _fmtDate(_dob!),
                    style: TextStyle(
                        fontSize: 14,
                        color: _dob == null ? const Color(0xFF9CA3AF) : _textDark,
                        fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ModalField('Experience (years)', _expCtrl, hint: '5', keyboard: TextInputType.number),
          const SizedBox(height: 12),
          _ModalDropdown('Status', _status, _statusOptions,
              (v) => setState(() => _status = v!)),
          const SizedBox(height: 12),
          _ModalDropdown('Vehicle Category', _category, ['Shipment', 'Construction', 'Mining', 'Others'],
              (v) => setState(() => _category = v!)),
          const SizedBox(height: 12),
          _ModalField('Location / Current City', _locationCtrl, hint: 'e.g. Mumbai'),
          const SizedBox(height: 12),
          _ModalField('Description / Notes', _descCtrl, hint: 'Optional notes', maxLines: 2),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _image != null ? Iconsax.tick_circle : Iconsax.camera,
                    size: 18, color: _image != null ? const Color(0xFF22C55E) : _textGrey,
                  ),
                  const SizedBox(width: 8),
                  Text(_image != null ? 'Photo selected' : 'Add driver photo',
                      style: TextStyle(
                          fontSize: 13,
                          color: _image != null ? const Color(0xFF22C55E) : _textGrey,
                          fontFamily: 'Poppins')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SaveButton(saving: _saving, onSave: _save),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Shared small widgets ───────────────────────────────────────────────────────

class _SearchFilterBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onQueryChanged;
  final String filter;
  final List<String> filters;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onAdd;
  final String addLabel;

  const _SearchFilterBar({
    required this.query,
    required this.onQueryChanged,
    required this.filter,
    required this.filters,
    required this.onFilterChanged,
    required this.onAdd,
    required this.addLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: TextField(
                    onChanged: onQueryChanged,
                    decoration: const InputDecoration(
                      hintText: 'Search…',
                      hintStyle: TextStyle(fontSize: 13, color: _textGrey, fontFamily: 'Poppins'),
                      prefixIcon: Icon(Iconsax.search_normal, size: 16, color: _textGrey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 13, color: _textDark, fontFamily: 'Poppins'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(addLabel,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Poppins')),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final f = filters[i];
                final active = filter == f;
                return GestureDetector(
                  onTap: () => onFilterChanged(f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: active ? _primary : _bg,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: active ? _primary : _border),
                    ),
                    child: Text(f,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? Colors.white : _textGrey,
                            fontFamily: 'Poppins')),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: _primary),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: _textGrey, fontFamily: 'Poppins')),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(action),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalSheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _ModalSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: _textGrey),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const Divider(color: _border),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String? hint;
  final TextInputType? keyboard;
  final int maxLines;
  final bool required;

  const _ModalField(this.label, this.ctrl,
      {this.hint, this.keyboard, this.maxLines = 1, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500, color: _textGrey, fontFamily: 'Poppins')),
            if (required) const Text(' *', style: TextStyle(color: _primary, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF), fontFamily: 'Poppins'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            filled: true,
            fillColor: _bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primary, width: 1.5)),
          ),
          style: const TextStyle(fontSize: 14, color: _textDark, fontFamily: 'Poppins'),
        ),
      ],
    );
  }
}

class _ModalDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _ModalDropdown(this.label, this.value, this.items, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: _textGrey, fontFamily: 'Poppins')),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: DropdownButton<String>(
            value: items.contains(value) ? value : items.first,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 14, fontFamily: 'Poppins')))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool saving;
  final VoidCallback onSave;
  const _SaveButton({required this.saving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: saving ? null : onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: saving
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : const Text('Save Changes',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn(this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _VehiclePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 72, height: 72,
        color: const Color(0xFFF3F4F6),
        child: const Icon(Iconsax.truck, size: 28, color: _textGrey),
      );
}

class _DriverPlaceholder extends StatelessWidget {
  final String name;
  const _DriverPlaceholder(this.name);

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'D';
    return Container(
      color: _primaryLight,
      alignment: Alignment.center,
      child: Text(initials,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _primary, fontFamily: 'Poppins')),
    );
  }
}

// ── Pure helpers ──────────────────────────────────────────────────────────────

Widget _tag(String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color, fontFamily: 'Poppins')),
    );

Future<void> _confirmDelete(
    BuildContext context, String type, String name, Future<bool> Function() onDelete) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Remove $type', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
      content: Text('Are you sure you want to remove "$name"?',
          style: const TextStyle(fontFamily: 'Poppins')),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel', style: TextStyle(color: _textGrey))),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('Remove', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  if (confirmed == true) await onDelete();
}
