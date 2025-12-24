class ApiConstants {
  static const String baseUrl = 'https://wheelboardapi.addonshareware.com/';
}

class API {
  static const String companySignUp = 'api/User/company_signup';
  static const String professionalSignUp = 'api/User/professional_signup';
  static const String login = 'api/User/login';
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
  static const String getTripList = 'api/Trip/trip-list/';
  static const String getUnassignedTripList = 'api/Trip/unassign-trip-list';
  static const String getUnassignedTripDetails =
      'api/Trip/unassigned-trip-details/';
  static const String submitBid = 'api/Trip/submit-bid';
  static const String getTripBids = 'api/Trip/get-trip-bids/';
  static const String assignTrip = 'api/Trip/assign-trip/';
  static const String getAssignedTrips = 'api/Trip/assign-trip/';
  static const String getTripListByDriver = 'api/Trip/assign-trip-list/';
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

  // KYC Verification APIs
  static const String verifyDrivingLicence = 'api/User/VerifyDrivingLicenceKYC';
}
