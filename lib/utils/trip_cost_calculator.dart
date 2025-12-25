/// Trip Cost Calculator Utility
/// Calculates trip cost based on distance, time, and various rates
library;

class TripCostCalculator {
  // Default rates (can be customized per vehicle type)
  static const double defaultBaseFare = 100.0; // ₹100 base fare
  static const double defaultRatePerKm = 15.0; // ₹15 per km
  static const double defaultWaitingChargePerMin = 2.0; // ₹2 per minute waiting
  static const double defaultGstPercent = 5.0; // 5% GST

  /// Calculate total trip cost
  static TripCostResult calculateTripCost({
    required double distanceInKm,
    double? waitingTimeInMinutes,
    double? tollCharges,
    double? baseFare,
    double? ratePerKm,
    double? waitingChargePerMin,
    double? gstPercent,
    double? driverAllowance,
    double? loadingCharges,
    double? unloadingCharges,
    double? insuranceCharges,
    double? otherCharges,
  }) {
    // Use provided rates or defaults
    final effectiveBaseFare = baseFare ?? defaultBaseFare;
    final effectiveRatePerKm = ratePerKm ?? defaultRatePerKm;
    final effectiveWaitingCharge =
        waitingChargePerMin ?? defaultWaitingChargePerMin;
    final effectiveGstPercent = gstPercent ?? defaultGstPercent;
    final effectiveWaitingTime = waitingTimeInMinutes ?? 0;
    final effectiveTolls = tollCharges ?? 0;
    final effectiveDriverAllowance = driverAllowance ?? 0;
    final effectiveLoadingCharges = loadingCharges ?? 0;
    final effectiveUnloadingCharges = unloadingCharges ?? 0;
    final effectiveInsuranceCharges = insuranceCharges ?? 0;
    final effectiveOtherCharges = otherCharges ?? 0;

    // Calculate individual components
    final distanceCharge = distanceInKm * effectiveRatePerKm;
    final waitingCharge = effectiveWaitingTime * effectiveWaitingCharge;

    // Subtotal before tax
    final subtotal =
        effectiveBaseFare +
        distanceCharge +
        waitingCharge +
        effectiveTolls +
        effectiveDriverAllowance +
        effectiveLoadingCharges +
        effectiveUnloadingCharges +
        effectiveInsuranceCharges +
        effectiveOtherCharges;

    // Calculate GST
    final gstAmount = subtotal * (effectiveGstPercent / 100);

    // Total cost
    final totalCost = subtotal + gstAmount;

    return TripCostResult(
      baseFare: effectiveBaseFare,
      distanceInKm: distanceInKm,
      ratePerKm: effectiveRatePerKm,
      distanceCharge: distanceCharge,
      waitingTimeInMinutes: effectiveWaitingTime,
      waitingChargePerMin: effectiveWaitingCharge,
      waitingCharge: waitingCharge,
      tollCharges: effectiveTolls,
      driverAllowance: effectiveDriverAllowance,
      loadingCharges: effectiveLoadingCharges,
      unloadingCharges: effectiveUnloadingCharges,
      insuranceCharges: effectiveInsuranceCharges,
      otherCharges: effectiveOtherCharges,
      subtotal: subtotal,
      gstPercent: effectiveGstPercent,
      gstAmount: gstAmount,
      totalCost: totalCost,
    );
  }

  /// Calculate distance-only cost (simple calculation)
  static double calculateSimpleCost({
    required double distanceInKm,
    required double ratePerKm,
  }) {
    return distanceInKm * ratePerKm;
  }

  /// Get rate per KM based on vehicle type
  static double getRatePerKm(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'bike':
      case 'two-wheeler':
        return 5.0; // ₹5/km
      case 'auto':
      case 'three-wheeler':
        return 10.0; // ₹10/km
      case 'car':
      case 'sedan':
        return 15.0; // ₹15/km
      case 'suv':
        return 18.0; // ₹18/km
      case 'mini truck':
      case 'pickup':
        return 20.0; // ₹20/km
      case 'truck':
      case 'lorry':
        return 25.0; // ₹25/km
      case 'container':
      case 'trailer':
        return 35.0; // ₹35/km
      default:
        return 15.0; // Default ₹15/km
    }
  }

  /// Get base fare based on vehicle type
  static double getBaseFare(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'bike':
      case 'two-wheeler':
        return 30.0;
      case 'auto':
      case 'three-wheeler':
        return 50.0;
      case 'car':
      case 'sedan':
        return 100.0;
      case 'suv':
        return 150.0;
      case 'mini truck':
      case 'pickup':
        return 200.0;
      case 'truck':
      case 'lorry':
        return 500.0;
      case 'container':
      case 'trailer':
        return 1000.0;
      default:
        return 100.0;
    }
  }

  /// Format currency for display
  static String formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(2)} K';
    } else {
      return '₹${amount.toStringAsFixed(2)}';
    }
  }

  /// Format currency with full amount
  static String formatCurrencyFull(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }
}

/// Trip Cost Result Model
class TripCostResult {
  final double baseFare;
  final double distanceInKm;
  final double ratePerKm;
  final double distanceCharge;
  final double waitingTimeInMinutes;
  final double waitingChargePerMin;
  final double waitingCharge;
  final double tollCharges;
  final double driverAllowance;
  final double loadingCharges;
  final double unloadingCharges;
  final double insuranceCharges;
  final double otherCharges;
  final double subtotal;
  final double gstPercent;
  final double gstAmount;
  final double totalCost;

  TripCostResult({
    required this.baseFare,
    required this.distanceInKm,
    required this.ratePerKm,
    required this.distanceCharge,
    required this.waitingTimeInMinutes,
    required this.waitingChargePerMin,
    required this.waitingCharge,
    required this.tollCharges,
    required this.driverAllowance,
    required this.loadingCharges,
    required this.unloadingCharges,
    required this.insuranceCharges,
    required this.otherCharges,
    required this.subtotal,
    required this.gstPercent,
    required this.gstAmount,
    required this.totalCost,
  });

  /// Get cost breakdown as Map
  Map<String, double> get breakdown => {
    'Base Fare': baseFare,
    'Distance Charge ($distanceInKm km × ₹$ratePerKm)': distanceCharge,
    if (waitingCharge > 0)
      'Waiting Charge ($waitingTimeInMinutes min)': waitingCharge,
    if (tollCharges > 0) 'Toll Charges': tollCharges,
    if (driverAllowance > 0) 'Driver Allowance': driverAllowance,
    if (loadingCharges > 0) 'Loading Charges': loadingCharges,
    if (unloadingCharges > 0) 'Unloading Charges': unloadingCharges,
    if (insuranceCharges > 0) 'Insurance': insuranceCharges,
    if (otherCharges > 0) 'Other Charges': otherCharges,
    'Subtotal': subtotal,
    'GST ($gstPercent%)': gstAmount,
    'TOTAL': totalCost,
  };

  /// Get summary string
  String get summary =>
      '''
Trip Cost Summary:
─────────────────────────────
Distance: ${distanceInKm.toStringAsFixed(1)} km
Rate: ₹${ratePerKm.toStringAsFixed(2)}/km
─────────────────────────────
Base Fare:      ₹${baseFare.toStringAsFixed(2)}
Distance:       ₹${distanceCharge.toStringAsFixed(2)}
${waitingCharge > 0 ? 'Waiting:        ₹${waitingCharge.toStringAsFixed(2)}\n' : ''}${tollCharges > 0 ? 'Tolls:          ₹${tollCharges.toStringAsFixed(2)}\n' : ''}─────────────────────────────
Subtotal:       ₹${subtotal.toStringAsFixed(2)}
GST ($gstPercent%):       ₹${gstAmount.toStringAsFixed(2)}
─────────────────────────────
TOTAL:          ₹${totalCost.toStringAsFixed(2)}
═════════════════════════════
''';

  @override
  String toString() => summary;
}

/// Vehicle Rate Configuration
class VehicleRateConfig {
  final String vehicleType;
  final double baseFare;
  final double ratePerKm;
  final double waitingChargePerMin;
  final double minKmCharge; // Minimum km to charge
  final double nightChargePercent; // Extra % for night trips

  VehicleRateConfig({
    required this.vehicleType,
    required this.baseFare,
    required this.ratePerKm,
    this.waitingChargePerMin = 2.0,
    this.minKmCharge = 5.0,
    this.nightChargePercent = 25.0,
  });

  /// Predefined vehicle rates
  static List<VehicleRateConfig> get standardRates => [
    VehicleRateConfig(vehicleType: 'Bike', baseFare: 30, ratePerKm: 5),
    VehicleRateConfig(vehicleType: 'Auto', baseFare: 50, ratePerKm: 10),
    VehicleRateConfig(vehicleType: 'Car', baseFare: 100, ratePerKm: 15),
    VehicleRateConfig(vehicleType: 'SUV', baseFare: 150, ratePerKm: 18),
    VehicleRateConfig(vehicleType: 'Mini Truck', baseFare: 200, ratePerKm: 20),
    VehicleRateConfig(vehicleType: 'Truck', baseFare: 500, ratePerKm: 25),
    VehicleRateConfig(vehicleType: 'Container', baseFare: 1000, ratePerKm: 35),
  ];
}
