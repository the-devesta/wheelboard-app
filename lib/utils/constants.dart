import 'package:flutter/material.dart';
import 'package:wheelboard/services/config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String baseUrl = AppConfig.baseUrl;
}

class MapsConstants {
  /// Google Maps API Key loaded from .env file
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
}

class API {
  static const String companySignUp = 'api/User/company_signup';
  static const String professionalSignUp = 'api/User/professional_signup';
  static const String login = 'api/User/login';
  static const String sendOtp = 'api/User/send-otp';
  static const String loginWithOtp = 'api/User/login-with-otp';
  static const String saveReferal = 'api/User/save-referral';

  static const String completeTransport = 'api/User/complete-transport';
  static const String completeServiceProvider =
      'api/User/complete-service-provider';
  static const String getUserProfile = 'api/User/user-profile';
  static const String userProfile = 'api/User/user-profile/{userId}';
  static const String addDriver = 'api/Transport/add-driver';
  static const String updateDriver = 'api/Transport/update-driver';
  static const String getDrivers = 'api/Transport/drivers';

  static const String addVehicle = 'api/Transport/add-vehicle';
  static const String updateVehicle = 'api/Transport/update-vehicle';
  static const String getVehicles = 'api/Transport/vehicle';
  static const String addTrip = 'api/Trip/add-trip';
  static const String updateTrip = 'api/Trip/update-trip';
  static const String startTrip = 'api/Trip/start-trip';
  static const String endTrip = 'api/Trip/end-trip';
  static const String getTripList = 'api/Trip/trip-list/';
  static const String getUnassignedTripList = 'api/Trip/unassign-trip-list';
  static const String getUnassignedTripDetails =
      'api/Trip/unassigned-trip-details/';
  static const String submitBid = 'api/Trip/submit-bid';
  static const String getTripBids = 'api/Trip/get-trip-bids/';
  static const String assignTrip = 'api/Trip/assign-trip/';
  static const String getAssignedTrips = 'api/Trip/assign-trip/';
  static const String getTripListByDriver = 'api/Trip/assign-trip-list/';
  static const String getReferralList = 'api/User/GetReferralsByUserId/';
  static const String getAssingServiceList = 'api/Service/assign-service/';
  static const String tripExpenseDetail = 'api/Trip/trip-expense-details';

  static const String createTripOrder = 'api/Trip/create-order';
  static const String verifyTripPayment = 'api/Trip/verify-payment';
  static const String getTripConfirmation = 'api/Trip/confirmation/';

  // Professional Management
  static const String professionalList = 'api/Transport/professional-list/';
  static const String professionalDetails =
      'api/Transport/professional-details/';

  // Profile Update APIs
  static const String updateProfessionalProfile =
      'api/User/update-professional-profile';
  static const String updateTransportProfile =
      'api/User/update-transport-profile';
  static const String updateServiceProvider =
      'api/User/update-service-provider';

  // Service APIs
  static const String serviceList = 'api/Service/service-list';
  static const String serviceListByUser =
      'api/Service/service-list/'; // With userId
  static const String serviceDetail = 'api/Service/details/';
  static const String serviceAssignList =
      'api/Service/service-assign-list'; // With serviceId query param
  static const String assignService = 'api/Service/assign-service';
  static const String addService = 'api/Service/add-service';
  static const String updateService = 'api/Service/update-service';
  static const String deleteService =
      'api/Service'; // Base path, will append /{serviceId}/user/{userId}/delete
  static const String deleteAccount = 'api/User/delete-account';

  static const String cancelService =
      'api/Service/cancel-service'; // With assignmentId query param
  static const String updateServiceStatus =
      'api/Service/update-service-status'; // With assignmentId and status query params
  static const String completeService =
      'api/Service/complete-service'; // With assignmentId query param

  // Vehicle and Driver Details APIs
  static const String getVehicleDetails = 'api/VehicleApi/GetVehicleDetails';
  static const String getLicenseDetails = 'api/VehicleApi/GetLicenceDetails';
  static const String getVehicleDetailsById = 'api/Transport/vehicle-details/';

  // Post APIs
  static const String createPost = 'api/Post/add';
  // static const String getUserPosts = 'api/Post/user/';
  static const String getAllPost = 'api/Post/get-all-post';
  static const String togglePostLike = 'api/Post/post-like-toggle';

  // Job APIs
  static const String getAppliedJobs = 'api/Job/applied-jobs/';
  static const String getOpenJobs = 'api/Job/open-job-list';
  static const String applyJob = 'api/Job/apply-job';
  static const String addJob = 'api/Job/add-job';
  static const String updateJob = 'api/Job/update-job';
  static const String getJobList = 'api/Job/job-list/';
  static const String toggleJobLike = 'api/Job/job-like-toggle';
  static const String getJobApplications = 'api/Job/get-applications/';
  static const String updateJobStatus = 'api/Job/update-job-status';
  static const String getAppliedUserProfile = 'api/Job/ApplyedUserProfile/';

  // Calendar Events APIs
  static const String saveCalendarEvent = 'api/Trip/save-calendar-events';
  static const String getEventsByUserId = 'api/Trip/get-events-by-userId/';

  // Expense APIs
  static const String getExpensePurposes = 'api/Trip/trip_expense_purposes';
  static const String saveTripExpense = 'api/Trip/trip_expense_save';

  // Notification APIs
  static const String getNotifications = 'api/NotificationsApi/notifications';
  static const String markNotificationRead =
      'api/NotificationsApi/notification/read';

  // Dashboard APIs
  static const String getDashboard = 'api/Dashboard/GetDashboard';

  // Vehicle Lease APIs
  static const String addVehicleLease = 'api/Transport/AddVehicleLease';
  static const String leaseList = 'api/Transport/lease-list';
  static const String leaseListByUserId = 'api/Transport/lease-list-by-userId';
  static const String myBookedLeaseListByUserId =
      'api/Transport/my-booked-lease-list-by-userId';
  static const String leaseDetails = 'api/Transport/lease-details/';
  static const String applyForLease = 'api/Transport/apply-for-lease';
  static const String getLeaseApplicationList =
      'api/Transport/get-lease-application-list';
  static const String leaseTogglePauseResume =
      'api/Transport/lease-toggle-pause-resume';
  static const String offLeases = 'api/Transport/off-leases';
  static const String updateLeaseApplicationStatus =
      'api/Transport/update-lease-application-status';

  // Service Provider APIs
  static const String serviceTogglePublishUnpublish =
      'api/Service/service-toggle-publish-unpublish';

  static const String deleteVehicle = 'api/Transport';
  static const String deleteDriver = 'api/Transport/driver';
  static const String deleteVehicleSuffix = '/delete';

  // KYC Verification APIs
  static const String verifyDrivingLicence = 'api/User/VerifyDrivingLicenceKYC';
  static const String verifyPanKYC = 'api/User/VerifyPanKYC';

  // Earnings Dashboard API
  static const String earningsDashboard = 'api/Trip/earnings-dashboard';
  static const String tripDashboard = 'api/Trip/trip-dashboard';

  // Service Provider Earnings APIs
  static const String serviceEarningsDashboard =
      'api/Service/service-earnings-dashboard';
  static const String createPayment = 'api/Service/create-payment';
  static const String completePayment = 'api/Service/complete-payment';
}

class AppImages {
  static const String mechanics = 'assets/mechanics.jpeg';
  static const String driver = 'assets/truck_driver.jpeg';
  static const String service = 'assets/service_page.jpeg';
  static const String trip = 'assets/trip_post_schedule.jpg';
}

String formatDateShort(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return "-";
  }

  try {
    final dateTime = DateTime.parse(dateString);
    return "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}";
  } catch (e) {
    debugPrint('Invalid date: $dateString');
    return dateString;
  }
}

String _getMonthName(int month) {
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month];
}
