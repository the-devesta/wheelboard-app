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
  static const String userProfile = 'api/User/user-profile/{userId}';
  static const String addDriver = 'api/Transport/add-driver';
  static const String getDrivers = 'api/Transport/drivers';

  static const String addVehicle = 'api/Transport/add-vehicle';
  static const String getVehicles = 'api/Transport/vehicle';
}
