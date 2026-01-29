import 'dart:convert';

import 'package:get/get.dart';

import '../../apihelperclass/api_helper.dart';
import '../../models/professional_profile_model.dart';
import '../../utils/constants.dart';
import '../../utils/session_manager.dart';
import '../../widgets/custom_snackbar.dart';

class ProfessionalListController extends GetxController {
  final SessionManager _sessionManager = SessionManager();

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
    _companyId ??= await _sessionManager.getString('userId');
    if (_companyId == null) {
      SnackBarHelper.error('User information missing. Please login again.');
      return;
    }
    await fetchProfessionalList();
  }

  Future<void> fetchProfessionalList() async {
    if (_companyId == null) return;

    try {
      isLoading.value = true;
      final response = await HttpHelper.getData(
        endpoint: '${API.professionalList}${_companyId!}',
        headers: const {'accept': '*/*'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
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
      } else {
        SnackBarHelper.error(
          'Failed to load professionals (${response.statusCode})',
        );
      }
    } catch (e) {
      SnackBarHelper.error('Unable to load professionals: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<ProfessionalProfile?> fetchProfessionalDetails(String driverId) async {
    try {
      isDetailsLoading.value = true;
      final response = await HttpHelper.getData(
        endpoint: '${API.professionalDetails}$driverId',
        headers: const {'accept': '*/*'},
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProfessionalProfile.fromJson(data);
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
