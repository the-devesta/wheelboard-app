import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../models/trip_expenses_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/auth/auth_service.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

class TripExpensesController extends GetxController {
  final isLoading = false.obs;
  final tripExpenses = Rxn<TripExpensesModel>();
  final errorMessage = ''.obs;

  Future<void> fetchTripExpenses(String tripId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      AppLogger.d('📡 Fetching trip expense summary for tripId: $tripId');

      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.expenses.tripSummary(tripId),
      );

      tripExpenses.value = TripExpensesModel.fromJson(data);
      AppLogger.d('✅ Trip expenses loaded successfully');
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to load trip expenses';
      errorMessage.value = msg;
      AppLogger.e('❌ Error fetching trip expenses: $e');
    } catch (e) {
      errorMessage.value = 'Error: $e';
      AppLogger.e('❌ Error fetching trip expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteTrip(String tripId) async {
    try {
      final userId = AuthService.to.userId;

      if (userId.isEmpty) {
        SnackBarHelper.error('User not found. Please login again.');
        return false;
      }

      AppLogger.d('📡 Deleting trip: $tripId');

      await ApiClient.instance.delete(
        ApiEndpoints.trips.delete(tripId),
      );

      SnackBarHelper.success('Trip deleted successfully');
      return true;
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to delete trip';
      SnackBarHelper.error(msg);
      AppLogger.e('❌ Error deleting trip: $e');
      return false;
    } catch (e) {
      SnackBarHelper.error('Error deleting trip: $e');
      AppLogger.e('❌ Error deleting trip: $e');
      return false;
    }
  }
}
