import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../models/fleet_models.dart';
import '../../models/transport/lease_models.dart';
import '../../utils/app_logger.dart';
import '../../widgets/custom_snackbar.dart';

class LeaseController extends GetxController {
  // ── My listings (lessor view) ──────────────────────────────────────────────
  final myListings = <LeaseListing>[].obs;
  final isListingsLoading = false.obs;

  // ── Incoming bookings (lessor view) ───────────────────────────────────────
  final incomingBookings = <LeaseBooking>[].obs;
  final isIncomingLoading = false.obs;

  // ── My booked leases (lessee view) ────────────────────────────────────────
  final myBookings = <LeaseBooking>[].obs;
  final isMyBookingsLoading = false.obs;

  // ── Listing detail ────────────────────────────────────────────────────────
  final currentListing = Rxn<LeaseListing>();
  final listingBookings = <LeaseBooking>[].obs;
  final isDetailLoading = false.obs;

  // ── Marketplace (lessee browse) ───────────────────────────────────────────
  final marketplaceListings = <LeaseListing>[].obs;
  final isMarketplaceLoading = false.obs;
  final marketplacePaginationTotal = 0.obs;
  final marketplacePage = 1.obs;
  final currentMarketplaceListing = Rxn<LeaseListing>();
  final isMarketplaceDetailLoading = false.obs;

  // ── Generic action loading ─────────────────────────────────────────────────
  final isActionLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyListings();
    fetchIncomingBookings();
    fetchMyBookings();
  }

  // ── My listings (lessor) ──────────────────────────────────────────────────

  Future<void> fetchMyListings() async {
    try {
      isListingsLoading.value = true;
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.lease.myListings,
      );
      final list = _unwrapList(raw);
      myListings.value =
          list.map((e) => LeaseListing.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.e('❌ fetchMyListings: $e');
    } finally {
      isListingsLoading.value = false;
    }
  }

  Future<LeaseListing?> fetchListingDetail(String id) async {
    try {
      isDetailLoading.value = true;
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.lease.listingDetails(id),
      );
      final map = _unwrapMap(raw);
      currentListing.value = LeaseListing.fromJson(map);
      return currentListing.value;
    } catch (e) {
      AppLogger.e('❌ fetchListingDetail: $e');
      return null;
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<bool> updateListingStatus(String listingId, String status) async {
    try {
      isActionLoading.value = true;
      await ApiClient.instance.patch(
        ApiEndpoints.lease.updateListingStatus(listingId),
        data: {'status': status},
      );
      // Update local state immediately
      final idx = myListings.indexWhere((l) => l.id == listingId);
      if (idx != -1) {
        // Rebuild the listing with new status
        final old = myListings[idx];
        myListings[idx] = LeaseListing(
          id: old.id,
          vehicleId: old.vehicleId,
          title: old.title,
          description: old.description,
          terms: old.terms,
          odometerReading: old.odometerReading,
          pricingType: old.pricingType,
          priceUnit: old.priceUnit,
          priceAmount: old.priceAmount,
          securityDeposit: old.securityDeposit,
          pickupLocation: old.pickupLocation,
          deliveryAvailable: old.deliveryAvailable,
          deliveryRadius: old.deliveryRadius,
          deliveryFee: old.deliveryFee,
          availableFrom: old.availableFrom,
          availableUntil: old.availableUntil,
          minDurationDays: old.minDurationDays,
          maxDurationDays: old.maxDurationDays,
          status: status,
          views: old.views,
          bookingsCount: old.bookingsCount,
          vehicleName: old.vehicleName,
          vehicleRegistration: old.vehicleRegistration,
          vehicleYear: old.vehicleYear,
          vehicleCategory: old.vehicleCategory,
          vehicleImage: old.vehicleImage,
        );
      }
      if (currentListing.value?.id == listingId) {
        await fetchListingDetail(listingId);
      }
      SnackBarHelper.success('Listing status updated');
      return true;
    } catch (e) {
      SnackBarHelper.error('Failed to update listing status');
      AppLogger.e('❌ updateListingStatus: $e');
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> createListing(Map<String, dynamic> data) async {
    try {
      isActionLoading.value = true;
      await ApiClient.instance.post(
        ApiEndpoints.lease.createListing,
        data: data,
      );
      await fetchMyListings();
      return true;
    } catch (e) {
      SnackBarHelper.error('Failed to create listing');
      AppLogger.e('❌ createListing: $e');
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<String?> createListingAndGetId(Map<String, dynamic> data) async {
    try {
      isActionLoading.value = true;
      final raw = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.lease.createListing,
        data: data,
      );
      final map = _unwrapMap(raw);
      final id = map['_id']?.toString() ?? map['id']?.toString();
      await fetchMyListings();
      return id;
    } catch (e) {
      AppLogger.e('❌ createListingAndGetId: $e');
      return null; // caller shows the error
    } finally {
      isActionLoading.value = false;
    }
  }

  // ── Listing-specific bookings ──────────────────────────────────────────────

  Future<void> fetchListingBookings(String listingId) async {
    try {
      isDetailLoading.value = true;
      // Try the listing-specific bookings endpoint
      final raw = await ApiClient.instance.get<dynamic>(
        '/lease/bookings/incoming',
        queryParameters: {'listingId': listingId},
      );
      final list = _unwrapList(raw);
      listingBookings.value =
          list.map((e) => LeaseBooking.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.e('❌ fetchListingBookings: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  // ── Incoming bookings (all lessor bookings) ────────────────────────────────

  Future<void> fetchIncomingBookings() async {
    try {
      isIncomingLoading.value = true;
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.lease.incomingBookings,
      );
      final list = _unwrapList(raw);
      incomingBookings.value =
          list.map((e) => LeaseBooking.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.e('❌ fetchIncomingBookings: $e');
    } finally {
      isIncomingLoading.value = false;
    }
  }

  Future<bool> confirmBooking(String bookingId, {String? ownerNote}) async {
    try {
      isActionLoading.value = true;
      await ApiClient.instance.patch(
        ApiEndpoints.lease.confirmBooking(bookingId),
        data: {if (ownerNote != null && ownerNote.isNotEmpty) 'ownerNote': ownerNote},
      );
      SnackBarHelper.success('Booking confirmed');
      await fetchIncomingBookings();
      return true;
    } catch (e) {
      SnackBarHelper.error('Failed to confirm booking');
      AppLogger.e('❌ confirmBooking: $e');
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> rejectBooking(String bookingId, {required String reason}) async {
    try {
      isActionLoading.value = true;
      await ApiClient.instance.patch(
        ApiEndpoints.lease.rejectBooking(bookingId),
        data: {'reason': reason},
      );
      SnackBarHelper.success('Booking rejected');
      await fetchIncomingBookings();
      return true;
    } catch (e) {
      SnackBarHelper.error('Failed to reject booking');
      AppLogger.e('❌ rejectBooking: $e');
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> startLease(String bookingId, {String? pickupLocation}) async {
    try {
      isActionLoading.value = true;
      await ApiClient.instance.patch(
        ApiEndpoints.lease.startBooking(bookingId),
        data: {if (pickupLocation != null) 'pickupLocation': pickupLocation},
      );
      SnackBarHelper.success('Lease started');
      await fetchIncomingBookings();
      return true;
    } catch (e) {
      SnackBarHelper.error('Failed to start lease');
      AppLogger.e('❌ startLease: $e');
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> completeLease(String bookingId, {String? returnLocation}) async {
    try {
      isActionLoading.value = true;
      await ApiClient.instance.patch(
        ApiEndpoints.lease.completeBooking(bookingId),
        data: {if (returnLocation != null) 'returnLocation': returnLocation},
      );
      SnackBarHelper.success('Lease completed');
      await fetchIncomingBookings();
      return true;
    } catch (e) {
      SnackBarHelper.error('Failed to complete lease');
      AppLogger.e('❌ completeLease: $e');
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  // ── My booked leases (lessee) ─────────────────────────────────────────────

  Future<void> fetchMyBookings() async {
    try {
      isMyBookingsLoading.value = true;
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.lease.myBookings,
      );
      final list = _unwrapList(raw);
      myBookings.value =
          list.map((e) => LeaseBooking.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.e('❌ fetchMyBookings: $e');
    } finally {
      isMyBookingsLoading.value = false;
    }
  }

  Future<bool> cancelBooking(String bookingId, {required String reason}) async {
    try {
      isActionLoading.value = true;
      await ApiClient.instance.patch(
        ApiEndpoints.lease.cancelBooking(bookingId),
        data: {'reason': reason},
      );
      SnackBarHelper.success('Booking cancelled');
      await fetchMyBookings();
      return true;
    } catch (e) {
      SnackBarHelper.error('Failed to cancel booking');
      AppLogger.e('❌ cancelBooking: $e');
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> applyForLease(String listingId, {String? message}) async {
    try {
      isActionLoading.value = true;
      await ApiClient.instance.post(
        ApiEndpoints.lease.createBooking,
        data: {
          'listingId': listingId,
          if (message != null && message.isNotEmpty) 'requestMessage': message,
        },
      );
      SnackBarHelper.success('Lease application submitted');
      await fetchMyBookings();
      return true;
    } catch (e) {
      SnackBarHelper.error('Failed to apply for lease');
      AppLogger.e('❌ applyForLease: $e');
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  // ── Computed views ─────────────────────────────────────────────────────────

  List<LeaseListing> get activeListings =>
      myListings.where((l) => l.isActive).toList();
  List<LeaseListing> get pausedListings =>
      myListings.where((l) => l.isPaused).toList();
  List<LeaseListing> get draftListings =>
      myListings.where((l) => l.isDraft).toList();
  List<LeaseListing> get visibleListings =>
      myListings.where((l) => l.status != 'removed').toList();

  List<LeaseBooking> get pendingIncoming =>
      incomingBookings.where((b) => b.isPending).toList();
  List<LeaseBooking> get readyToStart =>
      incomingBookings.where((b) => b.isApproved).toList();
  List<LeaseBooking> get activeLeases =>
      incomingBookings.where((b) => b.isActive).toList();
  List<LeaseBooking> get pastBookings =>
      incomingBookings.where((b) => b.isCompleted || b.isCancelled).toList();

  double get totalEarnings => incomingBookings
      .where((b) => b.isCompleted)
      .fold(0.0, (sum, b) => sum + (b.totalPrice ?? 0));

  // ── Marketplace ───────────────────────────────────────────────────────────

  Future<void> fetchMarketplace({
    int page = 1,
    String? category,
    double? priceMin,
    double? priceMax,
    String? location,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool reset = true,
  }) async {
    try {
      isMarketplaceLoading.value = true;
      if (reset) {
        marketplacePage.value = 1;
        marketplaceListings.clear();
      }
      final params = <String, dynamic>{
        'page': page,
        'limit': 12,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        if (category != null && category.isNotEmpty) 'category': category,
        if (priceMin != null) 'priceMin': priceMin,
        if (priceMax != null) 'priceMax': priceMax,
        if (location != null && location.isNotEmpty) 'location': location,
      };
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.lease.marketplace,
        queryParameters: params,
      );
      final map = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
      final data = map['listings'] ?? map['data'] ?? map;
      final list = data is List ? data : [];
      final total = (map['pagination'] as Map<String, dynamic>?)?['total'] ?? list.length;
      marketplacePaginationTotal.value = (total as num).toInt();
      marketplacePage.value = page;
      final parsed = list.map((e) => LeaseListing.fromJson(e as Map<String, dynamic>)).toList();
      if (reset) {
        marketplaceListings.value = parsed;
      } else {
        marketplaceListings.addAll(parsed);
      }
    } catch (e) {
      AppLogger.e('❌ fetchMarketplace: $e');
    } finally {
      isMarketplaceLoading.value = false;
    }
  }

  Future<LeaseListing?> fetchMarketplaceDetail(String id) async {
    try {
      isMarketplaceDetailLoading.value = true;
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.lease.marketplaceDetails(id),
      );
      final map = _unwrapMap(raw);
      currentMarketplaceListing.value = LeaseListing.fromJson(map);
      return currentMarketplaceListing.value;
    } catch (e) {
      AppLogger.e('❌ fetchMarketplaceDetail: $e');
      return null;
    } finally {
      isMarketplaceDetailLoading.value = false;
    }
  }

  Future<bool> createBookingWithDates({
    required String listingId,
    required String startDate,
    required String endDate,
    String? requestMessage,
    bool needsDelivery = false,
  }) async {
    try {
      isActionLoading.value = true;
      await ApiClient.instance.post(
        ApiEndpoints.lease.createBooking,
        data: {
          'listingId': listingId,
          'startDate': startDate,
          'endDate': endDate,
          if (requestMessage != null && requestMessage.isNotEmpty)
            'requestMessage': requestMessage,
          'needsDelivery': needsDelivery,
        },
      );
      SnackBarHelper.success('Booking request submitted');
      await fetchMyBookings();
      return true;
    } catch (e) {
      SnackBarHelper.error('Failed to submit booking request');
      AppLogger.e('❌ createBookingWithDates: $e');
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static List<dynamic> _unwrapList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map<String, dynamic>) {
      final inner = raw['data'] ?? raw['bookings'] ?? raw['listings'] ?? raw;
      if (inner is List) return inner;
    }
    return [];
  }

  static Map<String, dynamic> _unwrapMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final inner = raw['data'];
      if (inner is Map<String, dynamic>) return inner;
      return raw;
    }
    return {};
  }

  // ── Legacy compatibility shims ─────────────────────────────────────────────
  // Old screens (leased_vehicles_screen, applications_screen, lease_details_screen)
  // use these names/types unchanged. New screens use the modern API above.

  RxBool get isLoading => isListingsLoading;

  RxList<LeaseListItem> get leaseList {
    final result = <LeaseListItem>[].obs;
    result.value = myListings
        .map((l) => LeaseListItem(
              leaseId: l.id,
              vehicleTitle: l.title,
              vehicleNumber: l.vehicleRegistration,
              flatPrice: l.priceAmount,
              startDate: l.availableFrom,
              endDate: l.availableUntil,
              status: l.status,
              imageUrl: l.vehicleImage,
            ))
        .toList();
    return result;
  }

  RxList<LeaseListItem> get myBookedLeases {
    final result = <LeaseListItem>[].obs;
    result.value = myBookings
        .map((b) => LeaseListItem(
              leaseId: b.listingId,
              vehicleTitle: b.listingTitle,
              flatPrice: b.totalPrice,
              startDate: b.startDate,
              endDate: b.endDate,
              status: b.status,
              imageUrl: b.vehicleImage,
            ))
        .toList();
    return result;
  }

  final applications = <LeaseApplication>[].obs;

  Future<void> fetchLeaseApplications(String leaseId,
      {String status = 'Approved'}) async {
    await fetchListingBookings(leaseId);
    applications.value = listingBookings
        .map((b) => LeaseApplication(
              applicationId: b.id,
              vehicleTitle: b.listingTitle,
              fullName: b.lesseeName,
              appliedDate: b.createdAt,
              status: b.status,
            ))
        .toList();
  }

  final _compatLeaseDetails = Rxn<LeaseDetails>();
  Rxn<LeaseDetails> get leaseDetails => _compatLeaseDetails;

  Future<void> fetchLeaseDetails(String leaseId) async {
    final listing = await fetchListingDetail(leaseId);
    if (listing != null) {
      _compatLeaseDetails.value = LeaseDetails(
        leaseId: listing.id,
        vehicleTitle: listing.title,
        vehicleNumber: listing.vehicleRegistration,
        pricingType: listing.pricingType,
        flatPrice: listing.priceAmount,
        vehicleImage: listing.vehicleImage,
        status: listing.status,
      );
    }
  }

  Future<bool> togglePauseResume(String leaseId) =>
      updateListingStatus(leaseId, 'paused');

  Future<bool> offLease(String leaseId) =>
      updateListingStatus(leaseId, 'removed');

  Future<bool> updateLeaseApplicationStatus(
      String applicationId, String status) async {
    if (status.toLowerCase() == 'approved' ||
        status.toLowerCase() == 'accepted') {
      return confirmBooking(applicationId);
    }
    return rejectBooking(applicationId, reason: 'Rejected by owner');
  }

  Future<void> fetchLeaseList() => fetchMyListings();
  Future<void> fetchMyLeases() => fetchMyListings();
  Future<void> fetchMyBookedLeases() => fetchMyBookings();
}
