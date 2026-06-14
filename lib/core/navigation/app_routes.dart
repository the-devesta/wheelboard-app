/// Named route constants for the entire application.
///
/// Usage: `Get.toNamed(AppRoutes.login)` instead of `Get.to(() => LoginScreen())`.
/// All route names are centralized here for type-safe navigation.
class AppRoutes {
  AppRoutes._();

  // ── Auth ──────────────────────────────────────────────────────────────
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const companySignup = '/signup/company';
  static const professionalSignup = '/signup/professional';
  static const serviceProviderSignup = '/signup/service-provider';
  static const otpVerify = '/otp-verify';
  static const forgotPassword = '/forgot-password';
  static const verifyEmail = '/verify-email';

  // ── Main Wrappers (role-based shells) ─────────────────────────────────
  static const professionalHome = '/professional';
  static const companyHome = '/company';
  static const serviceProviderHome = '/service-provider';

  // ── Company Transport Screens ─────────────────────────────────────────
  static const companyCompleteProfile = '/company/complete-profile';
  static const addTrip = '/company/trips/add';
  static const addVehicle = '/company/fleet/add-vehicle';
  static const addDriver = '/company/fleet/add-driver';
  static const vehicleDetail = '/company/fleet/vehicle/:id';
  static const driverDetail = '/company/fleet/driver/:id';
  static const tripDetail = '/company/trips/:id';
  static const addLease = '/company/lease/add';
  static const leaseDetail = '/company/lease/:id';
  static const jobForm = '/company/jobs/form';
  static const jobApplications = '/company/jobs/:id/applications';
  static const newPost = '/company/feed/new-post';
  static const companyProfile = '/company/profile';

  // ── Professional Screens ──────────────────────────────────────────────
  static const professionalProfile = '/professional/profile';
  static const professionalKyc = '/professional/kyc';
  static const professionalCalendar = '/professional/calendar';
  static const professionalEarnings = '/professional/earnings';
  static const professionalBidSubmit = '/professional/bid/:id';
  static const professionalTripDashboard = '/professional/trip-dashboard';
  static const professionalLiveMap = '/professional/live-map/:id';
  static const professionalNotifications = '/professional/notifications';

  // ── Service Provider Screens ──────────────────────────────────────────
  static const serviceProviderCompleteProfile =
      '/service-provider/complete-profile';
  static const addService = '/service-provider/add-service';
  static const serviceDetail = '/service-provider/service/:id';
  static const serviceProviderProfile = '/service-provider/profile';
  static const serviceProviderEarnings = '/service-provider/earnings';

  // ── Shared ────────────────────────────────────────────────────────────
  static const notifications = '/notifications';
}
