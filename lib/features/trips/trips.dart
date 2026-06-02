/// Feature barrel: Trips
///
/// All trip-related exports consolidated in one place.
///
/// ```dart
/// import 'package:wheelboard/features/trips/trips.dart';
/// ```
library;

// Controllers
export '../../controllers/Transport/add_trip_controller.dart';
export '../../controllers/Transport/assign_trip_controller.dart';
export '../../controllers/Transport/trip_bids_controller.dart';
export '../../controllers/Transport/trip_expenses_controller.dart';
export '../../controllers/Transport/trip_page_controller.dart';
export '../../controllers/Professional/assigned_trip_controller.dart';
export '../../controllers/Professional/unassigned_trips_controller.dart';
export '../../controllers/Professional/track_trip_controller.dart';
export '../../controllers/Professional/trip_dashboard_controller.dart';

// Models
export '../../models/add_new_trip_model.dart';
export '../../models/assigned_trip_model.dart';
export '../../models/trip_bid_model.dart';
export '../../models/trip_confirmation_model.dart';
export '../../models/trip_expense_detail_model.dart';
export '../../models/trip_expenses_model.dart';
export '../../models/unassigned_trip_model.dart';

// Services
export '../../services/trip_payment_service.dart';
