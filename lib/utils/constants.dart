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
  
  // Vehicle and Driver Details APIs
  static const String getVehicleDetails = 'api/VehicleApi/GetVehicleDetails';
  static const String getLicenseDetails = 'api/VehicleApi/GetLicenceDetails';
  
  // Post APIs
  static const String createPost = 'api/Post/add';
  static const String getUserPosts = 'api/Post/user/';
  
  // Job APIs
  static const String getAppliedJobs = 'api/Job/applied-jobs/';
  static const String getOpenJobs = 'api/Job/open-job-list';
  static const String applyJob = 'api/Job/apply-job';
  
  // Calendar Events APIs
  static const String saveCalendarEvent = 'api/Trip/save-calendar-events';
  static const String getEventsByUserId = 'api/Trip/get-events-by-userId/';
}
