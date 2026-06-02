import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/professional_profile_model.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import '../../widgets/custom_snackbar.dart';

class ProfessionalListController extends GetxController {
  final professionals = <ProfessionalProfile>[].obs;
  final isLoading = false.obs;
  final isDetailsLoading = false.obs;
  final selectedFilter = 'ONBOARD'.obs;
  final searchQuery = ''.obs;
  final favoriteStatus = <String, bool>{}.obs;

  String? _companyId;

  @override
  void onInit() {
    super.onInit();
    _loadCompanyAndFetch();
  }

  Future<void> _loadCompanyAndFetch() async {
    final userId = AuthService.to.currentUserId;
    if (userId.isEmpty) {
      SnackBarHelper.error('User information missing. Please login again.');
      return;
    }
    _companyId = userId;
    await fetchProfessionalList();
  }

  Future<void> fetchProfessionalList() async {
    if (_companyId == null) return;

    try {
      isLoading.value = true;
      final data = await ApiClient.instance.get<List<dynamic>>(
        ApiEndpoints.fleet.professionalList(_companyId!),
      );

      final items = data
          .map(
            (json) =>
                ProfessionalProfile.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      professionals.assignAll(items);

      for (final professional in items) {
        favoriteStatus.putIfAbsent(professional.driverId, () => false);
      }
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load professionals';
      SnackBarHelper.error(msg);
    } catch (e) {
      SnackBarHelper.error('Unable to load professionals: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<ProfessionalProfile?> fetchProfessionalDetails(String driverId) async {
    try {
      isDetailsLoading.value = true;
      final data = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.fleet.professionalDetails(driverId),
      );

      if (data != null && data != "") {
        return ProfessionalProfile.fromJson(data as Map<String, dynamic>);
      } else {
        SnackBarHelper.error('Failed to load professional details');
      }
    } catch (e) {
      SnackBarHelper.error('Unable to load details: $e');
    } finally {
      isDetailsLoading.value = false;
    }
    return null;
  }

  List<ProfessionalProfile> get filteredProfessionals {
    final filter = selectedFilter.value;
    final query = searchQuery.value.trim().toLowerCase();

    return professionals.where((professional) {
      final statusMatch = _matchesFilter(filter, professional);
      final searchMatch =
          query.isEmpty ||
          professional.fullName.toLowerCase().contains(query) ||
          professional.vehicleNumber.toLowerCase().contains(query) ||
          professional.contactNumber.toLowerCase().contains(query);

      return statusMatch && searchMatch;
    }).toList();
  }

  bool _matchesFilter(String filter, ProfessionalProfile professional) {
    switch (filter) {
      case 'ONBOARD':
        return professional.driverType.toLowerCase() == 'onboard';
      case 'HIRED':
        return professional.driverType.toLowerCase() == 'hired';
      case 'FAVOURITE':
        return favoriteStatus[professional.driverId] ?? false;
      default:
        return true;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
  }

  void toggleFavorite(String driverId) {
    final current = favoriteStatus[driverId] ?? false;
    favoriteStatus[driverId] = !current;
  }
}
