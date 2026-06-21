/// Feature barrel: Fleet Management
///
/// All fleet-related exports (vehicles, drivers, lease models) consolidated.
///
/// ```dart
/// import 'package:wheelboard/features/fleet/fleet.dart';
/// ```
library;

// Controllers
export '../../controllers/Transport/fleet_controller.dart';
export '../../controllers/Transport/driver_details_controller.dart';

// Modern Models
export '../../models/fleet_models.dart';
export '../../models/get_driver_model.dart';
export '../../models/get_vehicle_model.dart';
export '../../models/driver_details_model.dart';

// Legacy models (kept for backward compat)
export '../../models/vehicle_detail_response_model.dart';
