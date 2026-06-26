import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/wallet/wallet_models.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

/// Drives the shared Wallet screen for both the Professional and Service
/// Provider personas. The backend determines the earnings source from the JWT,
/// so the same controller works for both — no role parameter needed here.
class WalletController extends GetxController {
  final summary = WalletSummary.empty.obs;
  final transactions = <WalletTransaction>[].obs;
  final withdrawals = <WithdrawalRequest>[].obs;

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading(true);
    hasError(false);
    errorMessage('');
    try {
      await Future.wait([
        _fetchSummary(),
        _fetchTransactions(),
        _fetchWithdrawals(),
      ]);
    } catch (e) {
      hasError(true);
      errorMessage(_friendly(e));
      AppLogger.e('❌ Wallet load failed: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Refresh after an action without the full-screen spinner.
  Future<void> refreshQuietly() async {
    try {
      await Future.wait([
        _fetchSummary(),
        _fetchTransactions(),
        _fetchWithdrawals(),
      ]);
    } catch (e) {
      AppLogger.e('❌ Wallet refresh failed: $e');
    }
  }

  Future<void> _fetchSummary() async {
    final res = await ApiClient.instance.get<Map<String, dynamic>>(
      ApiEndpoints.wallet.summary,
    );
    final data = res['data'];
    if (data is Map<String, dynamic>) {
      summary.value = WalletSummary.fromJson(data);
    }
  }

  Future<void> _fetchTransactions() async {
    final res = await ApiClient.instance.get<Map<String, dynamic>>(
      ApiEndpoints.wallet.transactions,
      queryParameters: {'limit': 100},
    );
    final list = res['data'];
    if (list is List) {
      transactions.value = list
          .whereType<Map<String, dynamic>>()
          .map(WalletTransaction.fromJson)
          .toList();
    }
  }

  Future<void> _fetchWithdrawals() async {
    final res = await ApiClient.instance.get<Map<String, dynamic>>(
      ApiEndpoints.wallet.withdrawals,
    );
    final list = res['data'];
    if (list is List) {
      withdrawals.value = list
          .whereType<Map<String, dynamic>>()
          .map(WithdrawalRequest.fromJson)
          .toList();
    }
  }

  /// Submit a withdrawal (claim earnings) request. Returns true on success.
  Future<bool> createWithdrawal({
    required double amount,
    required String withdrawalMethod, // BANK | UPI
    String? accountHolderName,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? upiId,
    String? notes,
  }) async {
    try {
      isSubmitting(true);
      final body = <String, dynamic>{
        'amount': amount,
        'withdrawalMethod': withdrawalMethod,
        if (withdrawalMethod == 'BANK') ...{
          'accountHolderName': accountHolderName,
          'bankName': bankName,
          'accountNumber': accountNumber,
          'ifscCode': ifscCode,
        },
        if (withdrawalMethod == 'UPI') 'upiId': upiId,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      };

      final res = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiEndpoints.wallet.withdrawals,
        data: body,
      );

      final ok = res['success'] == true || res['data'] != null;
      if (ok) {
        SnackBarHelper.success(
          (res['message'] as String?) ?? 'Withdrawal request submitted',
        );
        await refreshQuietly();
        return true;
      }
      SnackBarHelper.error((res['message'] as String?) ?? 'Request failed');
      return false;
    } on dio.DioException catch (e) {
      SnackBarHelper.error(_friendly(e, fallback: 'Failed to submit request'));
      return false;
    } catch (e) {
      SnackBarHelper.error('Something went wrong');
      return false;
    } finally {
      isSubmitting(false);
    }
  }

  String _friendly(Object e, {String fallback = 'Something went wrong'}) {
    if (e is dio.DioException) {
      if (e.error is ApiException) return (e.error as ApiException).message;
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        final m = data['message'];
        return m is List ? m.join(', ') : m.toString();
      }
    }
    return fallback;
  }
}
