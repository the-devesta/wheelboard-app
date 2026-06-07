# Technical Design Document

## Overview

This design implements complete feature parity between the **CompanyServiceProvider** role in the Flutter mobile app (wheelboard-app) and the **Business** role in the Next.js web frontend (wheelboard-fe). The implementation covers 11 major requirement areas spanning the entire service provider lifecycle: dashboard, service management, leads, bookings, profile management, payments, notifications, analytics, settings, legacy cleanup, and mobile UX optimization.

### Core Objectives

1. **API Parity**: Leverage existing NestJS backend APIs (wheelboard-be) without introducing new endpoints unless explicitly required
2. **Mobile-First UX**: Optimize for mobile interaction patterns, gestures, and performance
3. **State Management**: Use GetX reactive patterns consistently across all features
4. **Type Safety**: Maintain strong type definitions for all models and API responses
5. **Performance**: Implement pagination, lazy loading, and efficient caching strategies
6. **Offline Resilience**: Handle network failures gracefully with retry mechanisms and error states
7. **Deep Linking**: Support notification-driven deep navigation to specific screens
8. **Code Cleanup**: Remove legacy files and consolidate around modern architecture

### Technology Stack

- **Framework**: Flutter 3.x with Dart 3.x
- **State Management**: GetX (reactive observables, dependency injection, navigation)
- **HTTP Client**: Dio with custom interceptors (auth, refresh, logging)
- **Secure Storage**: flutter_secure_storage for tokens and sensitive data
- **Image Handling**: cached_network_image for efficient image loading
- **Payment Integration**: razorpay_flutter for subscription and booking payments
- **Backend**: NestJS REST API at `AppEnvironment.apiBaseUrl` (/api)

---

## Architecture

### Layer Structure

```
lib/
├── core/
│   ├── auth/           # AuthService, AuthModels (tokens, user)
│   ├── config/         # AppEnvironment (API URLs, env)
│   ├── network/        # ApiClient (Dio), ApiEndpoints, ApiException
│   ├── navigation/     # Route definitions, deep link handlers
│   └── storage/        # SecureSessionManager (token persistence)
├── features/
│   └── service_provider/
│       ├── controllers/
│       │   ├── service_provider_home_controller.dart
│       │   ├── my_listings_controller.dart
│       │   ├── leads_controller.dart
│       │   ├── bookings_controller.dart
│       │   ├── earnings_controller.dart
│       │   ├── profile_controller.dart
│       │   ├── analytics_controller.dart
│       │   └── subscriptions_controller.dart
│       ├── models/
│       │   ├── service_model.dart (existing)
│       │   ├── service_booking_model.dart (existing)
│       │   ├── lead_model.dart (existing)
│       │   ├── earnings_model.dart
│       │   ├── subscription_model.dart (existing)
│       │   └── analytics_model.dart
│       ├── screens/
│       │   ├── home_screen.dart (existing, enhance)
│       │   ├── my_listings_screen.dart (existing, enhance)
│       │   ├── add_service_screen.dart (existing, enhance)
│       │   ├── service_details_screen.dart (existing, enhance)
│       │   ├── leads/
│       │   │   ├── leads_screen.dart
│       │   │   ├── lead_detail_screen.dart
│       │   │   └── follow_up_screen.dart
│       │   ├── bookings/
│       │   │   ├── booking_list_screen.dart (existing, enhance)
│       │   │   └── booking_details_screen.dart (existing, enhance)
│       │   ├── earnings_screen.dart (existing, enhance)
│       │   ├── profile_screen.dart (existing, enhance)
│       │   ├── kyc_screen.dart
│       │   ├── analytics_screen.dart
│       │   ├── subscriptions_screen.dart
│       │   ├── settings_screen.dart
│       │   └── sp_notification_screen.dart (existing, enhance)
│       ├── widgets/
│       │   ├── stat_card.dart
│       │   ├── quick_action_card.dart
│       │   ├── service_card.dart
│       │   ├── lead_card.dart
│       │   ├── booking_card.dart
│       │   ├── empty_state_widget.dart
│       │   ├── skeleton_loader.dart
│       │   └── cash_payment_slider.dart
│       └── bindings/
│           └── service_provider_binding.dart
├── models/              # Shared models (legacy location, gradually migrate to features/)
├── services/            # Domain services (razorpay, kyc, learning, etc.)
├── utils/               # Helpers (logger, formatters, error_handler)
└── widgets/             # Global reusable widgets (loaders, snackbars)
```

### GetX State Management Pattern

All screens follow this pattern:

1. **Controller**: Extends `GetxController`, manages business logic, API calls, observable state
2. **Binding**: Extends `Bindings`, provides dependency injection for controllers
3. **Screen**: Stateless or StatefulWidget, observes controller state with `Obx()` or `GetX<T>()`
4. **Navigation**: Use `Get.to()`, `Get.off()`, `Get.back()` for route management

**Example Controller Pattern**:
```dart
class ServiceProviderHomeController extends GetxController {
  // Observable state
  final isLoading = false.obs;
  final services = <ServiceModel>[].obs;
  final error = Rxn<String>();
  
  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    fetchData();
  }
  
  // Business logic
  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      final data = await ApiClient.instance.get('/services');
      services.value = data.map((e) => ServiceModel.fromJson(e)).toList();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
```


### API Integration Architecture

**ApiClient** (singleton, Dio-based):
- Base URL: `AppEnvironment.apiBaseUrl` (reads from .env, appends /api)
- Auth Interceptor: Injects `Authorization: Bearer <token>` on every request
- Refresh Interceptor: Auto-refreshes token on 401, retries original request
- Logger Interceptor: Logs requests/responses in debug mode

**ApiEndpoints** (static constants):
- Organized by backend module (services, leads, bookings, notifications, etc.)
- All paths are relative to `/api` (no redundant /api prefix in endpoint strings)
- Example: `ApiEndpoints.services.list` → `/services`

**SecureSessionManager**:
- Stores tokens in `flutter_secure_storage` (not SharedPreferences)
- Methods: `setTokens()`, `getAccessToken()`, `getRefreshToken()`, `clearAll()`
- Migration handler for legacy SharedPreferences keys

**Error Handling**:
- DioException caught in controllers
- ApiException extracted from `e.error` for user-friendly messages
- SnackBarHelper displays errors to user
- Retry buttons on screens for network failures

---

## Components and Interfaces

### 1. Home Dashboard (ServiceProviderHomeScreen)

**Purpose**: Centralized dashboard showing business health, KPIs, and quick actions.

**State (ServiceProviderHomeController)**:
```dart
final isLoadingServices = false.obs;
final isLoadingKPIs = false.obs;
final services = <ServiceModel>[].obs;
final totalLeads = 0.obs;
final pendingBookings = 0.obs;
final totalEarnings = 0.0.obs;
final profileComplete = false.obs;
final subscriptionStatus = Rxn<SubscriptionModel>();
final recentLeads = <Lead>[].obs;
final popularFeeds = <FeedModel>[].obs;
```

**UI Components**:
- Profile completion banner (conditional, shows if missing businessType/address/city/state)
- Hero banner carousel (fetched from backend)
- KPI stat cards: Active Services, Total Leads, Pending Bookings, Total Earnings (month)
- Quick action row: Earnings, Hire, Bookings, Learning
- Recent services (2 cards): title, category, publish status, toggle publish/unpublish
- Recent leads (3 cards): lead status, navigation to detail
- Popular feeds (3 cards): like count, share action

**API Calls**:
- `GET /services?userId=<cspId>` → services list
- `GET /leads/provider/:providerId` → total leads count
- `GET /services/bookings/provider/:providerId` → pending bookings count
- `GET /services/earnings/analytics?period=current_month` → total earnings
- `GET /users/profile` → profile completeness check
- `GET /subscription/current` → subscription status
- `GET /feeds?limit=3&sort=popular` → popular feeds

**Navigation Targets**:
- Tap Services card → MyListingsScreen
- Tap Leads card → LeadsScreen
- Tap Bookings card → BookingListScreen
- Tap Earnings card → EarningsScreen
- Tap service card → ServiceDetailsScreen
- Tap lead card → LeadDetailScreen
- Tap feed card → FeedDetailScreen


### 2. Service Management System

**MyListingsScreen**:
- Display all services (published + unpublished)
- Search by title/description (client-side filter)
- Filter by status: All, Published, Draft
- Pagination: load 20 at a time, fetch more on scroll
- Actions: Edit (navigate to AddServiceScreen), Delete (confirmation dialog)

**AddServiceScreen** (create + edit):
- Form fields:
  - Service title (required)
  - Category (dropdown from server `GET /services/categories`)
  - Description (multiline, 500 char limit)
  - Pricing: amount (number), unit (dropdown: per hour / flat price)
  - Availability: business hours (from/to time pickers), days open (multi-select)
  - Images (up to 5): file picker, validate JPEG/PNG/WEBP, max 5MB each
  - Documents (optional): PDF uploads
  - Custom attributes: key-value pairs (dynamic list)
  - Location: city (autocomplete), state (dropdown), full address (text)
  - Business type (dropdown)
- Validation: all required fields must be filled before submit
- Create: `POST /services` with multipart/form-data
- Update: `PUT /services/:id` with multipart/form-data
- Image upload: handled by backend, returns image URLs

**ServiceDetailsScreen**:
- Display: images (carousel), title, category, description, pricing, availability, location, custom attributes, total bookings, average rating
- Actions: Edit (navigate to AddServiceScreen), Delete (confirmation dialog), Toggle Publish Status
- Toggle publish: `POST /services/:id/publish` or `POST /services/:id/unpublish`
- Delete: `DELETE /services/:id` with confirmation dialog

**State (MyListingsController)**:
```dart
final isLoading = false.obs;
final services = <ServiceModel>[].obs;
final searchQuery = ''.obs;
final selectedFilter = 'All'.obs; // All, Published, Draft
final currentPage = 1.obs;
final hasMore = true.obs;
```

**ServiceModel** (existing, already well-defined):
```dart
class ServiceModel {
  final String serviceId;
  final String serviceTitle;
  final String city;
  final String fullAddress;
  final bool isAvailable; // published status
  final String businessName;
  final String businessType;
  final String? serviceCategory;
  final String? contactNumber;
  final String? whatsappNumber;
  final String? description;
  final String? pricingOption;
  final num? amount;
  final String? businessHoursFrom;
  final String? businessHoursTo;
  final String? daysOpen;
  final List<String> images;
  final List<String> tags;
  final double? rating;
  // ...
}
```


### 3. Leads & Requests

**LeadsScreen**:
- Display all leads for authenticated CSP
- Filter by status: All, New, Accepted, Rejected, Completed
- Search by requester name or lead title (client-side filter)
- Sort: newest first (default), oldest first, by status
- Pagination: load 20 at a time
- Empty state: "No leads yet" with CTA to services screen

**LeadDetailScreen**:
- Display: lead title, requester name, requester contact, requested service, current status, status history timeline, full description
- Actions:
  - Accept: `PATCH /leads/:id/status` with `{ status: 'accepted' }`
  - Reject: prompt for reason, `PATCH /leads/:id/status` with `{ status: 'rejected', notes: reason }`
  - Follow Up: navigate to FollowUpScreen
- Status history: timeline component showing all status changes with timestamps

**FollowUpScreen**:
- Form: follow-up note (text area), follow-up date (date picker)
- Submit: `PATCH /leads/:id/follow-up` with `{ date: ISO8601, notes: string }`
- Navigate back to LeadDetailScreen on success

**State (LeadsController)**:
```dart
final isLoading = false.obs;
final leads = <Lead>[].obs;
final selectedStatus = 'All'.obs;
final searchQuery = ''.obs;
final sortBy = 'newest'.obs; // newest, oldest, status
final stats = Rxn<LeadStats>();
```

**Lead Model** (existing):
```dart
class Lead {
  final String id;
  final String companyName;
  final String? companyPhone;
  final String? companyEmail;
  final String providerName;
  final String source;
  final String status;
  final String? serviceName;
  final String? serviceCategory;
  final double? estimatedValue;
  final String? notes;
  final String? requirements;
  final DateTime? lastContactedAt;
  final DateTime? nextFollowUpAt;
  final DateTime? convertedAt;
  final String? lostReason;
  final List<String> tags;
  final DateTime? createdAt;
}

class LeadStats {
  final int total;
  final int newCount;
  final int contacted;
  final int qualified;
  final int converted;
  final int lost;
  final double conversionRate;
  final double totalValue;
  final double averageValue;
}
```

**API Calls**:
- `GET /leads/provider/:providerId` → list of leads
- `GET /leads/provider/:providerId/stats` → lead statistics
- `GET /leads/:id` → lead detail
- `PATCH /leads/:id/status` → update status (accept/reject)
- `PATCH /leads/:id/follow-up` → schedule follow-up


### 4. Orders & Bookings

**BookingListScreen**:
- Tab navigation: All, Assigned, Started, Completed, Cancelled, Pending Payment
- Display bookings for all services owned by CSP
- Pagination: load 20 at a time
- Booking card: service name, buyer company, scheduled date/time, payment method, payment status, booking status
- Tap card → navigate to BookingDetailsScreen

**BookingDetailsScreen**:
- Display: service name, transport company (buyer), contact info, scheduled date/time, payment method (Cash/Online), payment status, booking status, lifecycle timestamps
- Actions based on status:
  - **Assigned** → "Start Service" button: `PATCH /services/bookings/:id/start`
  - **Started** → "Complete Service" button: `PATCH /services/bookings/:id/complete`
  - **Completed + Cash + ConfirmationPending** → "Slide to Confirm Cash Payment" widget: `POST /services/bookings/:id/confirm-cash-payment`
  - **Pending or Assigned** → "Cancel Booking" button: `PATCH /services/bookings/:id/cancel`
- Optimistic UI updates with rollback on error
- Deep link support: notification taps land directly here

**Cash Payment Confirmation**:
- Custom slider widget (slide to confirm pattern)
- On slide complete:
  - Call `POST /services/bookings/:id/confirm-cash-payment`
  - Update `paymentStatus` to `Paid`
  - Update earnings display (booking now counts toward total earnings)

**Payment Status Logic**:
- **Online + Paid**: auto-included in earnings (Razorpay verification complete)
- **Cash + ConfirmationPending**: excluded from earnings until CSP confirms
- **Cash + Paid** (after confirmation): included in earnings

**State (BookingsController)**:
```dart
final isLoading = false.obs;
final allBookings = <ServiceBookingModel>[].obs;
final filteredBookings = <ServiceBookingModel>[].obs;
final selectedTab = 'All'.obs;
final currentPage = 1.obs;
final hasMore = true.obs;
```

**ServiceBookingModel** (existing):
```dart
class ServiceBookingModel {
  final String bookingId;
  final String serviceId;
  final String serviceName;
  final String companyId;
  final String companyName;
  final String companyPhone;
  final String scheduledDate;
  final String scheduledTime;
  final String status; // Pending, Assigned, Started, Completed, Cancelled
  final String paymentMethod; // Cash, Online
  final String paymentStatus; // Pending, ConfirmationPending, Paid, Failed
  final num amount;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
}
```

**API Calls**:
- `GET /services/bookings/provider/:providerId` → all bookings for CSP's services
- `PATCH /services/bookings/:id/start` → start service
- `PATCH /services/bookings/:id/complete` → complete service
- `POST /services/bookings/:id/confirm-cash-payment` → confirm cash received
- `PATCH /services/bookings/:id/cancel` → cancel booking


### 5. Profile & Business Management

**ServiceProviderProfileScreen**:
- Display sections:
  - Business logo (circular avatar, tap to change)
  - Business name, owner name, business type, phone, email, city, state, address
  - KYC status badge (Not Started, Pending, Approved, Rejected)
  - Active subscription plan (name, status, days remaining)
  - Portfolio section (images or links, add/remove)
- Edit button → navigate to EditProfileScreen
- KYC button → navigate to KYCScreen
- Settings button → navigate to SettingsScreen

**EditProfileScreen**:
- Form fields: business name, owner name, business type (dropdown), phone, email, city, state, address
- Logo upload: file picker, validate image < 5MB, upload via `POST /upload` (or similar file upload endpoint)
- Submit: `PUT /users/profile/service-provider`
- Success: show snackbar, navigate back

**KYCScreen**:
- Display document status for each required type: PAN, GST, business registration
- Status badges: Not Uploaded, Pending Review, Approved, Rejected
- Upload button for each document type
- If rejected: show rejection reason and enable re-upload
- Upload: `POST /kyc/upload/document` with multipart form-data
- Fetch status: `GET /kyc/my-kyc`

**CompleteProfileScreen** (wizard):
- Multi-step form with progress indicator
- Steps: Business Info, Contact Info, Location Info, Documents (optional)
- Final step: submit all data via `POST /users/complete-service-provider`
- Navigate to home screen on success

**BusinessSettingsScreen**:
- Change Password: form with old password, new password, confirm new password → `PUT /settings/account/password`
- Notification Preferences: toggles for each category → `PUT /settings/notifications`
- Delete Account: confirmation dialog with email typing verification → `DELETE /auth/delete-account`

**State (ProfileController)**:
```dart
final isLoading = false.obs;
final profile = Rxn<UserProfile>();
final kycStatus = Rxn<KycStatus>();
final portfolioItems = <PortfolioItem>[].obs;
```

**UserProfile Model**:
```dart
class UserProfile {
  final String userId;
  final String businessName;
  final String? ownerName;
  final String? businessType;
  final String? phone;
  final String? email;
  final String? city;
  final String? state;
  final String? address;
  final String? businessLogoPath;
  final bool isProfileComplete;
  final String? kycStatus;
}
```

**API Calls**:
- `GET /users/profile` → current user profile
- `PUT /users/profile/service-provider` → update profile
- `GET /kyc/my-kyc` → KYC status
- `POST /kyc/upload/document` → upload KYC document
- `PUT /settings/account/password` → change password
- `PUT /settings/notifications` → update notification preferences
- `DELETE /auth/delete-account` → delete account


### 6. Payments, Wallet & Subscriptions

**EarningsScreen**:
- Display:
  - Total earnings (current month)
  - Total earnings (all time)
  - Breakdown by service (bar chart or list)
  - Transaction list: payment method, amount, booking reference, date, payment status
- Date range filter: this week, this month, last 3 months, custom range
- Transaction detail: tap transaction → show booking details

**SubscriptionsScreen**:
- Display available plans: fetched from `GET /subscription/plans?role=service_provider`
- Plan card: plan name, price, billing cycle, feature list, CTA button
- Current plan status: plan name, status badge, days remaining
- Actions:
  - **No active plan**: "Get Started Free" (free plan), "Subscribe Now" (paid plans)
  - **Active paid plan**: "Upgrade" (higher tier), "Manage Subscription"
  - **Active free plan**: "Upgrade to Premium"
- Payment flow: Razorpay checkout, on success call `POST /subscription/subscribe`
- Downgrade confirmation: modal warning before switching to lower tier
- Billing history: past transactions with date, plan name, amount, payment status

**Payment Integration (Razorpay)**:
- RazorpayService wraps razorpay_flutter
- Create order: `POST /subscription/create-order` → returns Razorpay order ID
- Checkout: open Razorpay modal with order ID, amount, user details
- On success: verify payment with `POST /subscription/verify-payment` (signature verification on backend)
- On failure: show error, allow retry

**State (EarningsController)**:
```dart
final isLoading = false.obs;
final currentMonthEarnings = 0.0.obs;
final allTimeEarnings = 0.0.obs;
final earningsByService = <ServiceEarnings>[].obs;
final transactions = <Transaction>[].obs;
final selectedRange = 'this_month'.obs;
```

**State (SubscriptionsController)**:
```dart
final isLoading = false.obs;
final availablePlans = <SubscriptionPlan>[].obs;
final currentPlan = Rxn<SubscriptionModel>();
final billingHistory = <BillingTransaction>[].obs;
```

**Models**:
```dart
class ServiceEarnings {
  final String serviceId;
  final String serviceName;
  final num totalEarnings;
  final int bookingCount;
}

class Transaction {
  final String id;
  final String bookingId;
  final String serviceName;
  final num amount;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
}

class SubscriptionPlan {
  final String planId;
  final String name;
  final num price;
  final String billingCycle; // monthly, yearly
  final List<String> features;
}

class SubscriptionModel {
  final String subscriptionId;
  final String planId;
  final String planName;
  final String status; // active, expired, cancelled
  final DateTime? expiresAt;
  final int daysRemaining;
}

class BillingTransaction {
  final String transactionId;
  final String planName;
  final num amount;
  final String paymentStatus;
  final DateTime createdAt;
}
```

**API Calls**:
- `GET /services/earnings/analytics?period=current_month` → earnings data
- `GET /services/earnings/analytics?period=all_time` → total earnings
- `GET /subscription/plans?role=service_provider` → available plans
- `GET /subscription/current` → current subscription
- `POST /subscription/create-order` → create Razorpay order
- `POST /subscription/verify-payment` → verify payment
- `POST /subscription/subscribe` → activate plan
- `POST /subscription/change-plan` → change plan
- `GET /subscription/billing-history` → past transactions


### 7. Notifications & Communication

**SpNotificationScreen**:
- Display all notifications for authenticated CSP: `GET /notifications`
- Notification card: type icon, title, body text, timestamp, unread indicator dot
- Tap notification → mark as read (`PATCH /notifications/:id/read`), navigate to target screen
- "Mark All as Read" button → `POST /notifications/read-all`
- Real-time updates: WebSocket connection or polling every 30 seconds
- Empty state: "No notifications yet"
- Bottom navigation badge: unread count

**Notification Types & Navigation**:
- `new_lead` → LeadDetailScreen(leadId)
- `booking_created` → BookingDetailsScreen(bookingId)
- `booking_status_update` → BookingDetailsScreen(bookingId)
- `payment_received` → EarningsScreen
- `subscription_expiring` → SubscriptionsScreen
- `kyc_status_update` → KYCScreen
- `platform_announcement` → no navigation (informational)

**Deep Linking**:
- Notification payload includes target screen and parameters
- NavigationHelper parses payload and routes to correct screen
- Example payload: `{ type: 'new_lead', leadId: 'lead_123' }`
- NavigationHelper.handleNotificationTap() → Get.to(LeadDetailScreen(leadId: 'lead_123'))

**State (NotificationController)**:
```dart
final isLoading = false.obs;
final notifications = <NotificationModel>[].obs;
final unreadCount = 0.obs;
```

**NotificationModel** (existing):
```dart
class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data; // target screen parameters
}
```

**API Calls**:
- `GET /notifications` → list of notifications
- `PATCH /notifications/:id/read` → mark as read
- `POST /notifications/read-all` → mark all as read
- WebSocket connection: `ws://origin/notifications` (or polling fallback)


### 8. Analytics & Reporting

**AnalyticsScreen**:
- Accessible from bottom navigation or profile screen
- Sections:
  - **Revenue Metrics**: total revenue (current month), 7-day sparkline chart, month-over-month % change
  - **Lead Metrics**: total leads, accepted, rejected, conversion rate
  - **Service Performance**: ranked list by booking count and revenue
  - **Order Analytics**: total orders, completed, cancelled, average order value
  - **Customer Insights**: top 5 repeat buyers by booking count
- Time period filter: last 7 days, last 30 days, last 90 days
- Chart library: fl_chart or syncfusion_flutter_charts
- Empty state: "No data available for selected period" with retry button

**State (AnalyticsController)**:
```dart
final isLoading = false.obs;
final selectedPeriod = '30days'.obs; // 7days, 30days, 90days
final revenueMetrics = Rxn<RevenueMetrics>();
final leadMetrics = Rxn<LeadMetrics>();
final servicePerformance = <ServicePerformance>[].obs;
final orderAnalytics = Rxn<OrderAnalytics>();
final topCustomers = <CustomerInsight>[].obs;
```

**Models**:
```dart
class RevenueMetrics {
  final num totalRevenue;
  final List<RevenuePoint> sparklineData; // 7-day trend
  final double monthOverMonthChange;
}

class RevenuePoint {
  final DateTime date;
  final num revenue;
}

class LeadMetrics {
  final int totalLeads;
  final int accepted;
  final int rejected;
  final double conversionRate;
}

class ServicePerformance {
  final String serviceId;
  final String serviceName;
  final int bookingCount;
  final num totalRevenue;
}

class OrderAnalytics {
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final num averageOrderValue;
}

class CustomerInsight {
  final String companyId;
  final String companyName;
  final int bookingCount;
  final num totalSpent;
}
```

**API Calls**:
- `GET /services/analytics/revenue?period=30days` → revenue metrics
- `GET /leads/provider/:providerId/stats?period=30days` → lead metrics
- `GET /services/analytics/performance?period=30days` → service performance
- `GET /services/analytics/orders?period=30days` → order analytics
- `GET /services/analytics/customers?period=30days&limit=5` → top customers


### 9. Settings, Support & Utilities

**SettingsScreen**:
- Sections: Account, Notifications, Support, Legal
- **Account Section**:
  - Change Password → ChangePasswordScreen
  - Notification Preferences → NotificationPreferencesScreen
  - Delete Account → DeleteAccountConfirmationDialog
- **Support Section**:
  - Contact Support → SupportTicketScreen
  - FAQs → FAQScreen (accordion list)
  - Email support: support@wheelboard.com
  - Phone support: +91-XXXXXXXXXX
- **Legal Section**:
  - Privacy Policy → LegalScreen(type: 'privacy')
  - Terms of Service → LegalScreen(type: 'terms')

**NotificationPreferencesScreen**:
- Toggle switches for each category:
  - New Leads
  - Booking Updates
  - Payment Notifications
  - Platform Announcements
- Save button → `PUT /settings/notifications`
- Success: show snackbar, navigate back

**SupportTicketScreen**:
- Form: subject (text), description (multiline, 1000 char limit)
- Submit: `POST /issues` (reuse existing issues endpoint)
- Success: show confirmation message, navigate back

**FAQScreen**:
- Accordion list: question title, expandable answer body
- Fetch from `GET /support/faqs` or static list in assets
- Search filter: filter FAQs by question text

**LegalScreen**:
- Fetch policy content: `GET /policy/:type` (type = privacy | terms)
- Display in scrollable text widget
- Back button to settings

**DeleteAccountConfirmationDialog**:
- Warning text: "This action cannot be undone"
- Email verification: text field, must match user's email
- Confirm button enabled only after email match
- Submit: `DELETE /auth/delete-account`
- On success: clear session, navigate to login screen

**State (SettingsController)**:
```dart
final isLoading = false.obs;
final notificationPreferences = <String, bool>{}.obs;
final faqs = <FAQ>[].obs;
final policyContent = ''.obs;
```

**Models**:
```dart
class FAQ {
  final String question;
  final String answer;
}

class NotificationPreference {
  final String category;
  final bool enabled;
}
```

**API Calls**:
- `PUT /settings/notifications` → update notification preferences
- `POST /issues` → create support ticket
- `GET /support/faqs` → FAQ list (or static)
- `GET /policy/:type` → legal policy content
- `DELETE /auth/delete-account` → delete account


---

## Data Models

### Core Models Summary

All models are located in `lib/models/` (legacy) or `lib/features/service_provider/models/` (new structure).

**ServiceModel** (existing, comprehensive):
- Maps backend service object to Flutter model
- Handles both legacy and new backend response formats
- Includes images, tags, pricing, availability, location

**ServiceBookingModel** (existing):
- Represents a service booking lifecycle
- Tracks status transitions: Pending → Assigned → Started → Completed
- Tracks payment method (Cash/Online) and payment status

**Lead** (existing):
- CRM lead model with status tracking
- Includes follow-up dates, conversion tracking, source attribution

**UserProfile**:
- Business profile for service provider
- Includes KYC status, subscription status, profile completeness

**SubscriptionModel** (existing):
- Represents active subscription plan
- Tracks expiration, days remaining, plan features

**NotificationModel** (existing):
- Push notification with type, payload, read status
- Includes deep link parameters for navigation

**EarningsModel** (new):
```dart
class EarningsModel {
  final num totalEarnings;
  final num currentMonthEarnings;
  final List<ServiceEarnings> byService;
  final List<Transaction> transactions;
}
```

**AnalyticsModel** (new):
```dart
class AnalyticsModel {
  final RevenueMetrics revenue;
  final LeadMetrics leads;
  final List<ServicePerformance> servicePerformance;
  final OrderAnalytics orders;
  final List<CustomerInsight> topCustomers;
}
```

### Model Parsing Strategy

All models follow this pattern:
```dart
factory ModelName.fromJson(Map<String, dynamic> json) {
  // Handle nested 'data' key if present
  final root = json['data'] is Map<String, dynamic> 
      ? json['data'] as Map<String, dynamic> 
      : json;
  
  // Handle both backend field names and legacy field names
  final id = root['id'] ?? root['_id'] ?? root['legacyId'] ?? '';
  
  // Safe type casting with null fallbacks
  final amount = (root['amount'] as num?) ?? 0;
  
  // Date parsing with null safety
  DateTime? parseDate(dynamic v) => 
      v == null ? null : DateTime.tryParse(v.toString());
  
  return ModelName(
    id: id,
    amount: amount,
    createdAt: parseDate(root['createdAt']),
    // ...
  );
}
```


---

## Error Handling

### Error Handling Strategy

**Layered Error Handling**:
1. **Network Layer** (ApiClient): catches DioException, wraps in ApiException
2. **Controller Layer**: catches exceptions, sets error state, logs to AppLogger
3. **UI Layer**: displays error messages via SnackBarHelper, shows retry buttons

**ApiException**:
```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  
  ApiException(this.message, {this.statusCode, this.errorCode});
  
  factory ApiException.fromDioException(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      return ApiException(
        data['message'] ?? 'Request failed',
        statusCode: e.response?.statusCode,
        errorCode: data['errorCode'],
      );
    }
    return ApiException(
      e.message ?? 'Network error',
      statusCode: e.response?.statusCode,
    );
  }
}
```

**Controller Error Handling Pattern**:
```dart
Future<void> fetchData() async {
  isLoading.value = true;
  error.value = null;
  
  try {
    final data = await ApiClient.instance.get('/endpoint');
    items.value = data.map((e) => Model.fromJson(e)).toList();
  } on DioException catch (e) {
    final apiError = e.error is ApiException 
        ? e.error as ApiException 
        : ApiException.fromDioException(e);
    error.value = apiError.message;
    AppLogger.e('Failed to fetch data', error: e);
    SnackBarHelper.error(apiError.message);
  } catch (e) {
    error.value = 'An unexpected error occurred';
    AppLogger.e('Unexpected error', error: e);
    SnackBarHelper.error('Something went wrong');
  } finally {
    isLoading.value = false;
  }
}
```

**UI Error Display Pattern**:
```dart
Obx(() {
  if (controller.isLoading.value) {
    return const CustomLoader();
  }
  
  if (controller.error.value != null) {
    return ErrorStateWidget(
      message: controller.error.value!,
      onRetry: () => controller.fetchData(),
    );
  }
  
  if (controller.items.isEmpty) {
    return const EmptyStateWidget();
  }
  
  return ListView.builder(...);
})
```

**Error Types**:
- **Network Errors**: No internet, timeout → retry button
- **Auth Errors**: 401 → auto-refresh token, 403 → logout
- **Validation Errors**: 400 → field-level error messages
- **Server Errors**: 500 → generic error message, retry button
- **Not Found**: 404 → "Item not found" message


---

## Testing Strategy

This feature does NOT involve property-based testing. The CompanyServiceProvider parity feature is primarily **UI rendering, CRUD operations, API integration, and mobile UX**—none of which are suitable for property-based testing.

### Testing Approach

**1. Unit Tests** (specific examples, edge cases):
- Model parsing: test fromJson() with various backend response formats
- Controller logic: test state transitions, error handling, pagination logic
- Validation: test form field validators (email, phone, required fields)
- Date/currency formatters: test edge cases (null, zero, large numbers)
- Search/filter logic: test client-side filtering with empty results, special characters

**2. Widget Tests** (UI component behavior):
- Stat cards: test rendering with zero, small, large numbers
- Empty states: test display when no data available
- Error states: test retry button functionality
- Cash payment slider: test gesture recognition, confirmation flow
- Form validation: test required field indicators, error messages

**3. Integration Tests** (end-to-end flows):
- Login → home screen → navigate to services → create service → publish
- Home screen → leads → accept lead → follow up
- Bookings → start service → complete service → confirm cash payment
- Profile → edit profile → upload logo → save
- Subscriptions → select plan → payment → confirmation

**4. Mock-Based Unit Tests**:
- ApiClient: mock Dio responses for success, error, timeout scenarios
- RazorpayService: mock payment success/failure callbacks
- SecureSessionManager: mock token storage and retrieval

**5. Manual Testing Checklist**:
- Test on low-end devices (Android 8.0, 2GB RAM)
- Test with poor network conditions (2G, intermittent connectivity)
- Test deep links from notifications
- Test pagination (scroll to bottom, fetch more)
- Test offline → online transitions
- Test token refresh on 401 errors

### Test Coverage Goals

- **Unit Tests**: 70% coverage for controllers, models, utilities
- **Widget Tests**: All reusable widgets (stat cards, empty states, error states)
- **Integration Tests**: 5-10 critical user flows
- **Manual Tests**: All screens tested on Android and iOS

### Test File Organization

```
test/
├── unit/
│   ├── models/
│   │   ├── service_model_test.dart
│   │   ├── lead_model_test.dart
│   │   └── earnings_model_test.dart
│   ├── controllers/
│   │   ├── service_provider_home_controller_test.dart
│   │   ├── leads_controller_test.dart
│   │   └── bookings_controller_test.dart
│   └── utils/
│       ├── format_utils_test.dart
│       └── validation_utils_test.dart
├── widget/
│   ├── stat_card_test.dart
│   ├── empty_state_widget_test.dart
│   └── cash_payment_slider_test.dart
└── integration/
    ├── service_creation_flow_test.dart
    ├── lead_acceptance_flow_test.dart
    └── booking_completion_flow_test.dart
```


---

## Mobile UX, Performance, and Navigation

### Performance Optimization

**1. Pagination Strategy**:
- Load 20 items per page (services, leads, bookings, notifications)
- Detect scroll position: trigger fetch when within 200px of bottom
- Use `ScrollController` with listener:
```dart
final scrollController = ScrollController();

@override
void initState() {
  super.initState();
  scrollController.addListener(_onScroll);
}

void _onScroll() {
  if (scrollController.position.pixels >= 
      scrollController.position.maxScrollExtent - 200) {
    if (!controller.isLoading.value && controller.hasMore.value) {
      controller.fetchNextPage();
    }
  }
}
```

**2. Image Optimization**:
- Use `cached_network_image` for all remote images
- Set placeholder and error widgets
- Compress uploads to max 5MB before sending
- Use thumbnails for list views, full resolution for detail views

**3. State Management Optimization**:
- Use `Get.put()` with `permanent: false` for screen-specific controllers
- Use `Get.lazyPut()` for controllers not immediately needed
- Dispose controllers properly in `onClose()`
- Avoid rebuilding entire screen: use `Obx()` only around changing widgets

**4. Loading States**:
- **Skeleton Loaders**: show placeholder cards with shimmer effect during initial load
- **Spinner**: show small spinner during pagination fetch
- **Pull-to-Refresh**: use `RefreshIndicator` for manual refresh

**5. Caching Strategy**:
- Cache profile data in memory (refresh every 5 minutes)
- Cache service list in memory (refresh on screen init)
- Cache images with `cached_network_image` (7-day cache)
- No persistent cache for sensitive data (bookings, earnings)

### Navigation Architecture

**1. Bottom Navigation Bar** (main_wrapper.dart):
- Tabs: Home, Bookings, Services, Notifications, Profile
- Persistent across tab switches
- Badge on Notifications tab shows unread count

**2. GetX Navigation**:
- Forward navigation: `Get.to(() => ScreenName())`
- Replace navigation: `Get.off(() => ScreenName())`
- Back navigation: `Get.back()`
- Named routes: `Get.toNamed('/screen-name')`

**3. Deep Link Navigation**:
- Notification taps → NavigationHelper.handleNotificationTap()
- Parse notification payload → route to target screen with parameters
- Example: `{ type: 'new_lead', leadId: 'lead_123' }` → LeadDetailScreen(leadId: 'lead_123')

**4. Back Button Handling**:
- Intercept system back button on forms with unsaved changes
- Show "Discard changes?" confirmation dialog
- Use `WillPopScope` or `PopScope` (Flutter 3.12+)

**5. FAB (Floating Action Button)**:
- Home screen: "Add Service" → AddServiceScreen
- Services screen: "Add Service" → AddServiceScreen
- Leads screen: no FAB (leads are inbound only)


### Mobile-First UX Patterns

**1. Gesture Support**:
- Swipe left on list item → show delete button
- Swipe down → pull-to-refresh
- Slide to confirm → cash payment confirmation
- Long press → context menu (edit, delete, share)

**2. Touch Targets**:
- Minimum 48x48 dp for all interactive elements
- Adequate spacing between buttons (8-12 dp)
- Large tap areas for mobile fingers

**3. Form Optimization**:
- Use appropriate keyboard types (number, email, phone)
- Auto-capitalize where appropriate (names, titles)
- Disable submit button until all required fields filled
- Show character count for limited fields
- Use date/time pickers instead of text input

**4. Offline Handling**:
- Detect connectivity: use `connectivity_plus` package
- Show banner: "You are offline"
- Queue actions: store failed requests, retry when online
- Disable submit buttons when offline

**5. Accessibility**:
- Semantic labels for screen readers
- Sufficient color contrast (WCAG AA)
- Text scaling support (respect user font size settings)
- Focus indicators for keyboard navigation

**6. Responsive Layout**:
- Use `LayoutBuilder` or `MediaQuery` for breakpoints
- Adapt column count: 1 column on small phones, 2 on tablets
- Responsive font sizes: scale based on screen width
- Safe area insets: respect notches and system UI

### Legacy Code Cleanup Plan

**Files to Remove** (Requirement 10):

1. **lib/services/config.dart**:
   - Verify no imports remain
   - All code using AppEnvironment.apiBaseUrl
   - Remove file

2. **lib/apihelperclass/api_helper.dart**:
   - Verify no imports remain
   - All code using ApiClient.instance
   - Remove file

3. **lib/utils/session_manager.dart**:
   - Verify no imports remain
   - All code using SecureSessionManager
   - Remove file

4. **lib/screens/auth/forget_password_screen.dart**:
   - Replace all navigation references with forgot_password.dart
   - Remove file

5. **lib/screens/CompanyTransport/notification.dart**:
   - Replace all navigation references with notification_screen.dart
   - Remove file

6. **lib/screens/CompanyTransport/feed_screen.dart**:
   - Check if it's a stub (< 50 lines)
   - If stub: remove, replace with full implementation
   - If full: keep and enhance

7. **lib/screens/CompanyTransport/states_gridview.dart**:
   - Empty file, safe to delete

**Validation**:
- Run `flutter analyze` after each deletion
- Run full test suite after each deletion
- Test all affected navigation paths


---

## Implementation Phases

### Phase 1: Foundation & Home Dashboard (Requirement 1)

**Scope**:
- Enhance ServiceProviderHomeScreen with all KPI cards
- Add profile completion banner logic
- Implement quick action buttons
- Add recent services, leads, feeds sections
- Implement data fetching in ServiceProviderHomeController

**Deliverables**:
- Updated home_screen.dart with complete UI
- Enhanced service_provider_home_controller.dart with all API calls
- Stat card, quick action card widgets
- Empty states, loading skeletons

**Acceptance**:
- Home screen displays all KPIs correctly
- Navigation to all detail screens works
- Pull-to-refresh updates all data
- Loading states show during fetch
- Error states show on network failure

### Phase 2: Service Management System (Requirement 2)

**Scope**:
- Enhance MyListingsScreen with search, filter, pagination
- Enhance AddServiceScreen with all fields, validation, image upload
- Enhance ServiceDetailsScreen with complete data display
- Implement toggle publish/unpublish, delete service

**Deliverables**:
- Updated my_listings_screen.dart, add_service_screen.dart, service_details_screen.dart
- Service card widget with all actions
- Image upload with validation
- Pagination logic in controller

**Acceptance**:
- Can create service with all fields
- Can edit existing service
- Can delete service with confirmation
- Can toggle publish status
- Search and filter work correctly
- Pagination loads more items on scroll

### Phase 3: Leads & Requests (Requirement 3)

**Scope**:
- Create LeadsScreen with filter, search, sort
- Create LeadDetailScreen with full data display
- Create FollowUpScreen for scheduling follow-ups
- Implement accept, reject, follow-up actions

**Deliverables**:
- leads_screen.dart, lead_detail_screen.dart, follow_up_screen.dart
- LeadsController with all API integration
- Lead card widget
- Status timeline widget

**Acceptance**:
- Can view all leads
- Can filter by status
- Can search by requester name
- Can accept/reject leads
- Can schedule follow-ups
- Empty state shows when no leads


### Phase 4: Orders & Bookings (Requirement 4)

**Scope**:
- Enhance BookingListScreen with tab navigation, pagination
- Enhance BookingDetailsScreen with all lifecycle actions
- Create cash payment slider widget
- Implement booking status transitions (start, complete, cancel)
- Implement cash payment confirmation

**Deliverables**:
- Updated booking_list_screen.dart, booking_details_screen.dart
- BookingsController with all API integration
- Cash payment slider widget
- Booking card widget

**Acceptance**:
- Can view bookings filtered by status
- Can start and complete bookings
- Can confirm cash payment with slider
- Can cancel bookings with confirmation
- Optimistic UI updates with rollback on error
- Pagination works correctly

### Phase 5: Profile & Business Management (Requirement 5)

**Scope**:
- Enhance ServiceProviderProfileScreen with complete data display
- Create EditProfileScreen with all fields
- Create KYCScreen with document upload
- Create CompleteProfileScreen wizard
- Create BusinessSettingsScreen

**Deliverables**:
- Updated profile_screen.dart
- edit_profile_screen.dart, kyc_screen.dart, complete_profile_screen.dart, settings_screen.dart
- ProfileController with all API integration
- Logo upload functionality
- Change password, delete account flows

**Acceptance**:
- Can view complete profile
- Can edit profile and upload logo
- Can upload KYC documents
- Can complete profile wizard
- Can change password
- Can delete account with email verification

### Phase 6: Payments, Wallet & Subscriptions (Requirement 6)

**Scope**:
- Enhance EarningsScreen with all metrics, filters
- Create SubscriptionsScreen with plan display, payment flow
- Integrate Razorpay for subscription payments
- Implement billing history

**Deliverables**:
- Updated earnings_screen.dart
- subscriptions_screen.dart
- EarningsController, SubscriptionsController
- Razorpay integration
- Transaction list widget

**Acceptance**:
- Can view earnings by period
- Can filter transactions by date range
- Can view available subscription plans
- Can subscribe with Razorpay payment
- Can view billing history
- Payment success/failure handled correctly


### Phase 7: Notifications & Communication (Requirement 7)

**Scope**:
- Enhance SpNotificationScreen with all notification types
- Implement deep link navigation
- Implement real-time notification updates
- Implement mark as read, mark all as read

**Deliverables**:
- Updated sp_notification_screen.dart
- NotificationController enhancements
- Deep link handler (NavigationHelper)
- Notification badge on bottom nav

**Acceptance**:
- Can view all notifications
- Can mark individual notifications as read
- Can mark all notifications as read
- Notification tap navigates to correct screen
- Unread badge updates in real-time
- Empty state shows when no notifications

### Phase 8: Analytics & Reporting (Requirement 8)

**Scope**:
- Create AnalyticsScreen with all metrics
- Implement time period filter
- Implement revenue charts (sparkline)
- Display service performance, customer insights

**Deliverables**:
- analytics_screen.dart
- AnalyticsController
- Chart widgets (fl_chart integration)
- Analytics models

**Acceptance**:
- Can view revenue metrics with trend chart
- Can view lead metrics
- Can view service performance ranking
- Can view order analytics
- Can view top customers
- Time period filter updates all metrics

### Phase 9: Settings, Support & Utilities (Requirement 9)

**Scope**:
- Create SettingsScreen with all sections
- Create NotificationPreferencesScreen
- Create SupportTicketScreen
- Create FAQScreen
- Create LegalScreen
- Implement change password, delete account

**Deliverables**:
- settings_screen.dart, notification_preferences_screen.dart, support_ticket_screen.dart, faq_screen.dart, legal_screen.dart
- SettingsController
- FAQ accordion widget

**Acceptance**:
- Can navigate to all settings sections
- Can update notification preferences
- Can submit support ticket
- Can view FAQs
- Can view legal documents
- Can change password
- Can delete account with confirmation


### Phase 10: Legacy Code Cleanup (Requirement 10)

**Scope**:
- Remove obsolete configuration files
- Remove obsolete API helper files
- Remove obsolete session manager files
- Remove duplicate screen files
- Remove empty files

**Deliverables**:
- Deleted files: config.dart, api_helper.dart, session_manager.dart, forget_password_screen.dart, notification.dart, states_gridview.dart
- Updated navigation references
- Verified compilation

**Acceptance**:
- All legacy files removed
- No import errors
- All navigation paths work
- Full test suite passes
- Flutter analyze shows no errors

### Phase 11: Mobile UX, Performance & Navigation (Requirement 11)

**Scope**:
- Implement pagination on all list screens
- Implement skeleton loaders
- Implement empty states
- Implement error states with retry
- Implement discard confirmation dialogs
- Implement deep link navigation
- Optimize GetX bindings
- Optimize image loading

**Deliverables**:
- Pagination logic in all list controllers
- Skeleton loader widgets
- Empty state widgets
- Error state widgets
- Navigation helper with deep link support
- GetX bindings for all controllers
- Image optimization (cached_network_image)

**Acceptance**:
- All list screens load 20 items at a time
- Skeleton loaders show during initial load
- Empty states show when no data
- Error states show retry button
- Forms show discard confirmation
- Notification deep links navigate correctly
- Controllers use GetX bindings
- Images load efficiently with cache

---

## Dependencies

**Existing Dependencies**:
- get: ^4.6.6 (state management, navigation)
- dio: ^5.4.0 (HTTP client)
- flutter_secure_storage: ^9.0.0 (secure token storage)
- shared_preferences: ^2.2.2 (non-sensitive storage)
- flutter_dotenv: ^5.1.0 (environment config)
- cached_network_image: ^3.3.1 (image caching)

**New Dependencies**:
- razorpay_flutter: ^1.3.7 (subscription payments)
- fl_chart: ^0.66.2 (analytics charts)
- connectivity_plus: ^5.0.2 (network status)
- file_picker: ^6.1.1 (document/image upload)
- image_picker: ^1.0.7 (camera/gallery image selection)
- intl: ^0.19.0 (date/currency formatting)

**Dev Dependencies**:
- flutter_test: sdk (widget/integration tests)
- mockito: ^5.4.4 (mock API responses)
- build_runner: ^2.4.8 (code generation for mocks)


---

## Security Considerations

### Authentication & Authorization

1. **Token Management**:
   - Access token stored in flutter_secure_storage (encrypted)
   - Refresh token stored in flutter_secure_storage (encrypted)
   - Never log tokens in debug mode
   - Clear tokens on logout and account deletion

2. **API Security**:
   - All API calls include Authorization header
   - Auto-refresh token on 401 responses
   - Force logout on unrecoverable 401 (refresh failed)
   - Validate SSL certificates in production

3. **Role-Based Access**:
   - Backend enforces role checks (CompanyServiceProvider only)
   - Frontend assumes authenticated user has correct role
   - No sensitive role checks in frontend (backend is source of truth)

### Data Privacy

1. **Secure Storage**:
   - Tokens, user ID → flutter_secure_storage
   - Non-sensitive preferences → shared_preferences
   - No sensitive data in logs (mask PII in AppLogger)

2. **Payment Security**:
   - Razorpay handles card details (PCI DSS compliant)
   - Never store card numbers in app
   - Verify payment signature on backend (not frontend)

3. **File Uploads**:
   - Validate file types (image, PDF only)
   - Limit file size (5MB max)
   - Backend sanitizes filenames and content
   - Use signed URLs for image access (if backend implements)

### Network Security

1. **HTTPS Only**:
   - AppEnvironment enforces HTTPS in production
   - Reject insecure connections

2. **Certificate Pinning** (optional future enhancement):
   - Pin API server certificate
   - Reject man-in-the-middle attacks

3. **Request Signing** (optional future enhancement):
   - Sign sensitive requests with HMAC
   - Backend verifies signature

---

## Monitoring & Logging

### Application Logging

**AppLogger** (existing utility):
- Debug logs: verbose info for development
- Info logs: important state changes
- Warning logs: recoverable errors
- Error logs: exceptions, API failures

**Log Levels by Environment**:
- Development: all logs (debug, info, warning, error)
- Production: warning and error only

**What to Log**:
- API request/response (debug mode only)
- Authentication events (login, logout, token refresh)
- Navigation events (screen transitions)
- User actions (create service, accept lead, complete booking)
- Errors (exceptions, API failures, validation failures)

**What NOT to Log**:
- Tokens, passwords, API keys
- PII (email, phone, address) in production
- Full request/response bodies in production

### Error Reporting

**Future Enhancement**: Integrate crash reporting (Sentry, Firebase Crashlytics)
- Auto-report uncaught exceptions
- Include stack trace, device info, user ID (hashed)
- Exclude PII from reports

### Analytics Tracking

**Future Enhancement**: Integrate analytics (Firebase Analytics, Mixpanel)
- Track screen views
- Track user actions (service created, lead accepted, booking completed)
- Track feature adoption (subscription upgrades, KYC completion)
- Track performance metrics (API response times, screen load times)


---

## API Contracts Reference

### Services Module

| Endpoint | Method | Purpose | Request | Response |
|----------|--------|---------|---------|----------|
| `/services` | POST | Create service | Multipart form-data: title, category, description, pricing, availability, images, location | `{ success: true, data: { serviceId, ... } }` |
| `/services` | GET | List services | Query: userId | `[{ id, title, category, status, ... }]` |
| `/services/:id` | GET | Service details | - | `{ id, title, description, images, pricing, ... }` |
| `/services/:id` | PATCH | Update service | Same as create | `{ success: true, data: {...} }` |
| `/services/:id` | DELETE | Delete service | - | `{ success: true }` |
| `/services/:id/publish` | POST | Publish service | - | `{ success: true }` |
| `/services/:id/unpublish` | POST | Unpublish service | - | `{ success: true }` |

### Bookings Module

| Endpoint | Method | Purpose | Request | Response |
|----------|--------|---------|---------|----------|
| `/services/bookings/provider/:providerId` | GET | List bookings | Query: status | `[{ bookingId, serviceId, companyId, status, paymentMethod, paymentStatus, ... }]` |
| `/services/bookings/:id` | GET | Booking details | - | `{ bookingId, serviceName, companyName, ... }` |
| `/services/bookings/:id/start` | PATCH | Start booking | - | `{ success: true, data: {...} }` |
| `/services/bookings/:id/complete` | PATCH | Complete booking | - | `{ success: true, data: {...} }` |
| `/services/bookings/:id/cancel` | PATCH | Cancel booking | - | `{ success: true }` |
| `/services/bookings/:id/confirm-cash-payment` | POST | Confirm cash payment | - | `{ success: true, data: { paymentStatus: 'Paid' } }` |

### Leads Module

| Endpoint | Method | Purpose | Request | Response |
|----------|--------|---------|---------|----------|
| `/leads/provider/:providerId` | GET | List leads | Query: status, source | `[{ id, companyName, status, source, serviceName, ... }]` |
| `/leads/provider/:providerId/stats` | GET | Lead statistics | Query: period | `{ total, new, contacted, qualified, converted, lost, conversionRate, ... }` |
| `/leads/:id` | GET | Lead details | - | `{ id, companyName, providerName, status, requirements, ... }` |
| `/leads/:id/status` | PATCH | Update status | Body: `{ status, notes? }` | `{ success: true, data: {...} }` |
| `/leads/:id/follow-up` | PATCH | Schedule follow-up | Body: `{ date, notes? }` | `{ success: true, data: {...} }` |

### Earnings Module

| Endpoint | Method | Purpose | Request | Response |
|----------|--------|---------|---------|----------|
| `/services/earnings/analytics` | GET | Earnings analytics | Query: period | `{ totalEarnings, byService: [...], transactions: [...] }` |

### Subscriptions Module

| Endpoint | Method | Purpose | Request | Response |
|----------|--------|---------|---------|----------|
| `/subscription/plans` | GET | Available plans | Query: role=service_provider | `[{ planId, name, price, billingCycle, features: [...] }]` |
| `/subscription/current` | GET | Current subscription | - | `{ subscriptionId, planId, planName, status, expiresAt, ... }` |
| `/subscription/create-order` | POST | Create Razorpay order | Body: `{ planId }` | `{ orderId, amount, currency }` |
| `/subscription/verify-payment` | POST | Verify payment | Body: `{ orderId, paymentId, signature }` | `{ success: true }` |
| `/subscription/subscribe` | POST | Activate plan | Body: `{ planId, paymentId }` | `{ success: true, data: {...} }` |
| `/subscription/change-plan` | POST | Change plan | Body: `{ planId }` | `{ success: true }` |
| `/subscription/billing-history` | GET | Billing history | - | `[{ transactionId, planName, amount, paymentStatus, createdAt }]` |

### Notifications Module

| Endpoint | Method | Purpose | Request | Response |
|----------|--------|---------|---------|----------|
| `/notifications` | GET | List notifications | - | `[{ id, type, title, body, isRead, createdAt, data: {...} }]` |
| `/notifications/:id/read` | PATCH | Mark as read | - | `{ success: true }` |
| `/notifications/read-all` | POST | Mark all as read | - | `{ success: true }` |

### Profile Module

| Endpoint | Method | Purpose | Request | Response |
|----------|--------|---------|---------|----------|
| `/users/profile` | GET | Current user profile | - | `{ userId, businessName, ownerName, businessType, phone, email, city, state, address, businessLogoPath, isProfileComplete, kycStatus }` |
| `/users/profile/service-provider` | PUT | Update profile | Body: all profile fields | `{ success: true, data: {...} }` |
| `/users/complete-service-provider` | POST | Complete profile wizard | Body: all required fields | `{ success: true }` |

### KYC Module

| Endpoint | Method | Purpose | Request | Response |
|----------|--------|---------|---------|----------|
| `/kyc/my-kyc` | GET | KYC status | - | `{ documents: [{ type, status, rejectionReason }] }` |
| `/kyc/upload/document` | POST | Upload document | Multipart: file, type | `{ success: true, data: { documentId, status: 'Pending Review' } }` |

### Settings Module

| Endpoint | Method | Purpose | Request | Response |
|----------|--------|---------|---------|----------|
| `/settings/notifications` | PUT | Update preferences | Body: `{ leads: bool, bookings: bool, payments: bool, announcements: bool }` | `{ success: true }` |
| `/settings/account/password` | PUT | Change password | Body: `{ oldPassword, newPassword }` | `{ success: true }` |

### Support Module

| Endpoint | Method | Purpose | Request | Response |
|----------|--------|---------|---------|----------|
| `/issues` | POST | Create support ticket | Body: `{ title, description, category?, priority? }` | `{ success: true, data: { issueId } }` |
| `/support/faqs` | GET | FAQ list | - | `[{ question, answer }]` |
| `/policy/:type` | GET | Legal policy | Param: type (privacy \| terms) | `{ content: "..." }` |

### Analytics Module

| Endpoint | Method | Purpose | Request | Response |
|----------|--------|---------|---------|----------|
| `/services/analytics/revenue` | GET | Revenue metrics | Query: period | `{ totalRevenue, sparklineData: [...], monthOverMonthChange }` |
| `/services/analytics/performance` | GET | Service performance | Query: period | `[{ serviceId, serviceName, bookingCount, totalRevenue }]` |
| `/services/analytics/orders` | GET | Order analytics | Query: period | `{ totalOrders, completedOrders, cancelledOrders, averageOrderValue }` |
| `/services/analytics/customers` | GET | Customer insights | Query: period, limit | `[{ companyId, companyName, bookingCount, totalSpent }]` |

---

## Glossary

- **CSP**: CompanyServiceProvider; the Flutter mobile user role
- **Business**: The equivalent role in wheelboard-fe (Next.js)
- **KPI**: Key Performance Indicator (stat card on dashboard)
- **Booking**: A service booking created by CompanyTransport for a CSP's service
- **Lead**: An inquiry or request for a CSP's service
- **Listing**: A service offering created by a CSP
- **Earnings**: Revenue from completed bookings
- **Subscription**: A paid or free plan that unlocks features
- **KYC**: Know Your Customer; identity verification
- **GetX**: Flutter state management library (reactive observables, DI, navigation)
- **Dio**: HTTP client library for Dart/Flutter
- **ApiClient**: Singleton wrapper around Dio with auth interceptors
- **SecureSessionManager**: Secure token storage using flutter_secure_storage
- **AppEnvironment**: Environment configuration (API URLs, flags)
- **Razorpay**: Payment gateway for subscriptions and bookings

---

## Summary

This design delivers complete parity between CompanyServiceProvider (Flutter) and Business (Next.js) by implementing 11 major feature areas: home dashboard, service management, leads, bookings, profile, payments, notifications, analytics, settings, legacy cleanup, and mobile UX optimization. The implementation leverages existing NestJS backend APIs, uses GetX for state management, and follows mobile-first UX patterns with pagination, skeleton loaders, offline handling, and deep linking. The architecture is modular, type-safe, and optimized for performance on low-end devices. Testing covers unit, widget, and integration levels without property-based testing (as this feature is UI/CRUD focused). All legacy files are removed, and the codebase is consolidated around the modern architecture (ApiClient, SecureSessionManager, AppEnvironment).
