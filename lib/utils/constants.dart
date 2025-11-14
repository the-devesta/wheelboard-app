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
  static const String getUnassignedTripDetails = 'api/Trip/unassigned-trip-details/';
  static const String submitBid = 'api/Trip/submit-bid';
  static const String getTripBids = 'api/Trip/get-trip-bids/';
  
  // Service APIs
  static const String serviceList = 'api/Service/service-list';
  static const String serviceDetail = 'api/Service/details/';
  static const String assignService = 'api/Service/assign-service';
  
  // Vehicle and Driver Details APIs
  static const String getVehicleDetails = 'api/VehicleApi/GetVehicleDetails';
  static const String getLicenseDetails = 'api/VehicleApi/GetLicenceDetails';
  
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
  



  // Calendar Events APIs
  static const String saveCalendarEvent = 'api/Trip/save-calendar-events';
  static const String getEventsByUserId = 'api/Trip/get-events-by-userId/';
}
