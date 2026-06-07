# Requirements Document

## Introduction

This feature delivers complete feature, workflow, API, and business parity between the **CompanyServiceProvider** role in **wheelboard-app** (Flutter mobile app) and the **Business** role in **wheelboard-fe** (Next.js web frontend). Both roles represent the same user type — a service-providing business — and must expose identical capabilities while providing a superior mobile-first experience.

The implementation is organized into nine sequential phases. Each phase must reach parity before the next begins. The shared backend (**wheelboard-be**, NestJS) provides the APIs for both platforms; no new backend endpoints are introduced unless explicitly called out.

**Platforms in scope:**
- `wheelboard-app` — Flutter mobile app, `CompanyServiceProvider` role (`lib/screens/CompanyServiceProvider/`)
- `wheelboard-fe` — Next.js web app, `Business` role (`src/app/business/`)
- `wheelboard-be` — NestJS backend, shared APIs (reference only — no new endpoints unless noted)

---

## Glossary

- **CSP** — CompanyServiceProvider; the Flutter mobile user type being brought to parity
- **Business** — The equivalent user type in wheelboard-fe
- **SP** — Service Provider (used interchangeably with CSP and Business throughout the codebase)
- **KPI** — Key Performance Indicator; a numeric metric displayed on the dashboard
- **Booking** — A service booking created by a CompanyTransport (buyer) for a service offered by a CSP (seller)
- **Lead** — An enquiry or request directed at the CSP for one of their listed services
- **Listing** / **Service** — A service offering created and managed by the CSP
- **Earnings** — Revenue received by the CSP for completed bookings
- **Subscription** — A paid or free plan that unlocks features for the CSP
- **KYC** — Know Your Customer; identity and document verification
- **ServiceProviderHomeController** — The GetX controller managing the SP home screen state
- **ApiClient** — The Dio-based HTTP client in `lib/core/network/api_client.dart`
- **SecureSessionManager** — Token storage in `lib/core/storage/secure_session_manager.dart`
- **AppEnvironment** — Environment config in `lib/core/config/app_environment.dart`

---

## Requirements

### Requirement 1: Foundation & Home Dashboard

**User Story:** As a CompanyServiceProvider, I want a home dashboard that shows the health and status of my business at a glance, so that I can quickly understand what needs my attention without navigating to multiple screens.

#### Acceptance Criteria

1. WHEN the CSP opens the app and navigates to their home screen, THE ServiceProviderHomeScreen SHALL display a profile completion reminder banner if the user's profile is missing `businessType`, `address`, `city`, or `state`, with a navigation action to the complete-profile screen.

2. WHEN the CSP home screen loads, THE ServiceProviderHomeScreen SHALL display a hero banner carousel fetched from the backend.

3. WHEN the CSP home screen loads, THE ServiceProviderHomeScreen SHALL display the following KPI stat cards:
   - Active Services count (published listings)
   - Total Leads count
   - Pending Bookings count (bookings in `Pending` or `Assigned` status)
   - Total Earnings (sum of confirmed revenue for the current month)

4. WHEN a KPI stat card is tapped, THE ServiceProviderHomeScreen SHALL navigate to the corresponding detail screen (Services → MyListingsScreen, Leads → LeadsScreen, Bookings → BookingListScreen, Earnings → EarningsScreen).

5. WHEN the CSP home screen loads, THE ServiceProviderHomeScreen SHALL display a subscription status indicator showing the active plan name and days remaining, or a prompt to subscribe if no active subscription exists.

6. WHEN the CSP home screen loads, THE ServiceProviderHomeScreen SHALL display a Quick Actions row containing at minimum: Add Service, View Bookings, View Earnings, Learning.

7. WHEN the CSP home screen loads, THE ServiceProviderHomeScreen SHALL display the two most recent services with their title, category, published status badge, and quick-toggle publish/unpublish action.

8. WHEN the CSP home screen loads, THE ServiceProviderHomeScreen SHALL display the three most recent leads with lead status badges and a navigation action to each lead's detail screen.

9. WHEN the CSP home screen loads, THE ServiceProviderHomeScreen SHALL display the three most recent popular feed posts with like count and share action.

10. WHEN the CSP home screen data has not yet loaded, THE ServiceProviderHomeScreen SHALL display loading skeleton or spinner placeholders in each section.

11. IF a network error occurs while loading the CSP home screen, THEN THE ServiceProviderHomeController SHALL set an error state and THE ServiceProviderHomeScreen SHALL display a retry button.

12. WHEN the CSP navigates away from and returns to the home screen, THE ServiceProviderHomeController SHALL refresh all KPI data from the API within 5 seconds.

---

### Requirement 2: Service Management System

**User Story:** As a CompanyServiceProvider, I want to create, manage, and control the visibility of my services in full, so that Transport companies can discover and book them.

#### Acceptance Criteria

1. WHEN the CSP accesses the service listings screen, THE MyListingsScreen SHALL display all services belonging to the authenticated CSP, grouped by published and unpublished status.

2. WHEN the CSP creates a new service, THE AddServiceScreen SHALL collect and submit the following fields: service title, category (from server-provided category list), description, pricing (amount and unit), availability schedule, service images (up to 5), service documents (optional), custom attributes (key-value pairs), city, state, and business type.

3. WHEN a new service is successfully created, THE AddServiceScreen SHALL call `POST /services` and navigate back to MyListingsScreen with a success notification.

4. WHEN the CSP edits an existing service, THE AddServiceScreen SHALL pre-populate all existing service fields and submit changes via `PUT /services/:id`.

5. WHEN the CSP deletes a service, THE ServiceDetailsScreen SHALL display a confirmation dialog before calling `DELETE /services/:id`.

6. WHEN the CSP toggles a service's publish status, THE ServiceProviderHomeController or MyListingsController SHALL call `PATCH /services/:id/toggle-availability` and update the UI immediately with optimistic state change.

7. WHEN the CSP opens a service detail screen, THE ServiceDetailsScreen SHALL display: service images (carousel), title, category, description, pricing, availability, city/state, custom attributes, total bookings count, and average rating.

8. WHEN service images are uploaded, THE AddServiceScreen SHALL validate that each file is an image type (JPEG, PNG, WEBP) and does not exceed 5 MB, and IF validation fails THEN THE AddServiceScreen SHALL display a field-level error without submitting the form.

9. WHEN the CSP searches for a service in the listings screen, THE MyListingsScreen SHALL filter displayed services by service title or category in real time as the user types, without making additional API calls.

10. WHEN the MyListingsScreen loads with more than 20 services, THE MyListingsScreen SHALL implement paginated loading, fetching additional results when the user scrolls to within 200 pixels of the list bottom.

11. IF the service creation or update API call fails, THEN THE AddServiceScreen SHALL display a descriptive error message and retain all form field values so the user does not lose their input.

---

### Requirement 3: Leads & Requests

**User Story:** As a CompanyServiceProvider, I want to view and manage inbound leads and service requests from transport companies, so that I can respond appropriately and convert leads into bookings.

#### Acceptance Criteria

1. WHEN the CSP opens the leads screen, THE LeadsScreen SHALL display all leads assigned to the authenticated CSP, fetched via `GET /leads?userId=<cspId>`.

2. WHEN the leads screen loads, THE LeadsScreen SHALL display each lead with: lead title, requester name, status badge, creation date, and a navigation action to the lead detail screen.

3. WHEN the CSP views a lead's detail, THE LeadDetailScreen SHALL display: full lead description, requester contact details, requested service, current status, and the full status history timeline.

4. WHEN the CSP accepts a lead, THE LeadDetailScreen SHALL call `PATCH /leads/:id/status` with status `accepted` and update the lead status badge immediately.

5. WHEN the CSP rejects a lead, THE LeadDetailScreen SHALL prompt for a rejection reason, then call `PATCH /leads/:id/status` with status `rejected` and the reason.

6. WHEN the CSP applies a status filter on the leads screen, THE LeadsScreen SHALL display only leads matching the selected status (All, New, Accepted, Rejected, Completed), and FOR ALL filter states the filtered set of leads SHALL be a subset of the unfiltered set.

7. WHEN the CSP searches for a lead by requester name or lead title, THE LeadsScreen SHALL update the displayed list to show only matching leads, and the total displayed count SHALL be less than or equal to the pre-search count.

8. WHEN the CSP sorts leads, THE LeadsScreen SHALL support sorting by: newest first (default), oldest first, and status. FOR ALL sort operations, the set of displayed leads SHALL remain identical to the pre-sort set; only their order SHALL change.

9. WHEN the CSP taps "Follow Up" on a lead, THE LeadDetailScreen SHALL navigate to a follow-up form where the CSP can record a note and submission date, which is saved via `POST /leads/:id/follow-up`.

10. WHEN the leads screen loads with no leads, THE LeadsScreen SHALL display a descriptive empty state message and a quick-action button to navigate to the service listings screen.

---

### Requirement 4: Orders & Bookings

**User Story:** As a CompanyServiceProvider, I want to track and manage my service bookings through their full lifecycle, so that I can start services on time, complete them accurately, and receive payment correctly.

#### Acceptance Criteria

1. WHEN the CSP opens the bookings screen, THE BookingListScreen SHALL display all bookings for the authenticated CSP's services, fetchable via `GET /services/bookings/provider/:providerId`.

2. WHEN the bookings screen loads, THE BookingListScreen SHALL support tab filtering by booking status: All, Assigned, Started, Completed, Cancelled, and Pending Payment.

3. WHEN the CSP views a booking detail, THE BookingDetailsScreen SHALL display: service name, transport company (buyer) name and contact, scheduled date and time, payment method (Cash or Online), payment status, booking status, and all lifecycle timestamps (assigned, started, completed).

4. WHEN a booking is in `Assigned` status, THE BookingDetailsScreen SHALL display a "Start Service" button. WHEN tapped, THE BookingDetailsScreen SHALL call `PATCH /services/bookings/:id/start` and update the booking status to `Started`.

5. WHEN a booking is in `Started` status, THE BookingDetailsScreen SHALL display a "Complete Service" button. WHEN tapped, THE BookingDetailsScreen SHALL call `PATCH /services/bookings/:id/complete` and update the booking status to `Completed`.

6. WHEN a booking is `Completed` with `paymentMethod = Cash` and `paymentStatus = ConfirmationPending`, THE BookingDetailsScreen SHALL display a "Slide to Confirm Cash Payment" widget. WHEN the CSP completes the slide gesture, THE BookingDetailsScreen SHALL call `POST /services/bookings/:id/confirm-cash-payment` and update `paymentStatus` to `Paid`.

7. WHILE a booking has `paymentStatus = ConfirmationPending` (cash not yet confirmed), THE EarningsScreen SHALL exclude that booking's amount from the total earnings displayed.

8. WHEN a booking has `paymentMethod = Online` and `paymentStatus = Paid`, THE EarningsScreen SHALL include that booking's amount in total earnings, because online payment verification is handled by Razorpay and does not require CSP confirmation.

9. WHEN the CSP cancels a booking that is in `Pending` or `Assigned` status, THE BookingDetailsScreen SHALL display a confirmation dialog, then call `PATCH /services/bookings/:id/cancel`.

10. IF a booking status transition API call fails, THEN THE BookingDetailsScreen SHALL revert the optimistic UI update, display the error message, and leave the booking in its original status.

11. WHEN the bookings screen loads with more than 20 bookings, THE BookingListScreen SHALL implement pagination, loading additional results as the user scrolls.

---

### Requirement 5: Profile & Business Management

**User Story:** As a CompanyServiceProvider, I want to manage my business identity, documents, and verification status fully from the mobile app, so that I can build trust with buyers and comply with platform requirements.

#### Acceptance Criteria

1. WHEN the CSP accesses their profile screen, THE ServiceProviderProfileScreen SHALL display: business logo, business name, owner name, business type, phone number, email, city, state, address, KYC status, and active subscription plan.

2. WHEN the CSP edits their profile, THE ServiceProviderProfileScreen SHALL submit changes via `PUT /users/profile` and display a success notification on completion.

3. WHEN the CSP uploads a business logo, THE ServiceProviderProfileScreen SHALL validate the file is an image under 5 MB before uploading via the file upload API endpoint.

4. WHEN the CSP opens the KYC screen, THE KYC screen SHALL display the verification status for each required document type (PAN, GST, business registration) as: Not Uploaded, Pending Review, Approved, or Rejected.

5. WHEN the CSP uploads a KYC document, THE KYC screen SHALL call the appropriate `POST /kyc` endpoint and update the document's status to `Pending Review` immediately.

6. IF a KYC document is rejected, THEN THE KYC screen SHALL display the rejection reason and enable re-upload for that document type.

7. WHEN the CSP accesses the complete-profile wizard, THE CompleteProfileScreen SHALL guide the CSP through all required fields in a multi-step form with a visible progress indicator.

8. WHEN the CSP navigates to business settings, THE ServiceProviderProfileScreen SHALL provide access to: change password, notification preferences, and delete account.

9. WHEN the CSP deletes their account, THE delete account flow SHALL require explicit confirmation with the user typing their email, then call `DELETE /auth/delete-account`.

10. THE ServiceProviderProfileScreen SHALL display a portfolio section where the CSP can add, view, and remove portfolio items (images or links), stored via the profile API.

---

### Requirement 6: Payments, Wallet & Subscriptions

**User Story:** As a CompanyServiceProvider, I want to track my earnings, view transaction history, and manage my subscription plan from the mobile app, so that I can understand my revenue and control my membership.

#### Acceptance Criteria

1. WHEN the CSP opens the earnings screen, THE EarningsScreen SHALL display: total earnings for the current month, total earnings to date, a breakdown by service, and a transaction list with payment method, amount, booking reference, and date.

2. WHEN the CSP views transaction history, THE EarningsScreen SHALL support date-range filtering (this week, this month, last 3 months, custom range) and THE filtered result SHALL be a subset of the unfiltered transaction list for any given range.

3. WHEN the CSP opens the subscriptions screen, THE SubscriptionsScreen SHALL fetch available plans via `GET /subscription/plans?role=service_provider` and display: plan name, price, billing cycle, feature list, and a CTA button.

4. WHEN the CSP has no active subscription, THE SubscriptionsScreen SHALL display a "Get Started Free" prompt for the free plan and "Subscribe Now" for paid plans.

5. WHEN the CSP has an active subscription, THE SubscriptionsScreen SHALL display the current plan name, status badge, and days remaining on the current plan.

6. WHEN the CSP selects a paid subscription plan, THE SubscriptionsScreen SHALL initiate a Razorpay payment flow and on success call `POST /subscription/subscribe` to activate the plan.

7. WHEN the CSP selects a free plan while having an active paid subscription, THE SubscriptionsScreen SHALL display a downgrade confirmation dialog before calling `POST /subscription/change-plan`.

8. WHEN the CSP upgrades from a lower-tier plan to a higher-tier plan, THE SubscriptionsScreen SHALL call `POST /subscription/change-plan` without requiring a downgrade confirmation.

9. WHEN the CSP's subscription expires, THE SubscriptionsScreen SHALL display an "Expired" status badge and prompt the user to renew.

10. WHEN the CSP opens the billing history section, THE SubscriptionsScreen SHALL display past subscription transactions with date, plan name, amount paid, and payment status.

---

### Requirement 7: Notifications & Communication

**User Story:** As a CompanyServiceProvider, I want to receive and act on relevant notifications from the mobile app, so that I can respond to new leads, booking updates, and platform messages without missing business events.

#### Acceptance Criteria

1. WHEN a new notification arrives, THE app's notification badge on the bottom navigation bar SHALL increment its unread count by one without requiring a screen reload.

2. WHEN the CSP opens the notifications screen, THE SpNotificationScreen SHALL display all notifications for the authenticated CSP, fetched via `GET /notifications`, ordered newest first.

3. WHEN the CSP opens the notifications screen, THE SpNotificationScreen SHALL display each notification with: notification type icon, title, body text, timestamp, and an unread indicator dot for unread notifications.

4. WHEN the CSP taps a notification, THE SpNotificationScreen SHALL mark the notification as read via `PATCH /notifications/:id/read` and navigate to the relevant screen based on notification type (e.g., a new lead notification navigates to the lead detail screen).

5. WHEN the CSP taps "Mark All as Read", THE SpNotificationScreen SHALL call `POST /notifications/read-all` and remove all unread indicators.

6. THE SpNotificationScreen SHALL support the following notification types with appropriate icons and navigation targets:
   - `new_lead` → LeadDetailScreen
   - `booking_created` → BookingDetailsScreen
   - `booking_status_update` → BookingDetailsScreen
   - `payment_received` → EarningsScreen
   - `subscription_expiring` → SubscriptionsScreen
   - `kyc_status_update` → KYC screen
   - `platform_announcement` → no navigation (informational)

7. WHILE the notifications screen is open, THE SpNotificationScreen SHALL poll or use WebSocket to receive new notifications in real time without requiring a manual refresh.

8. WHEN the notifications list is empty, THE SpNotificationScreen SHALL display a descriptive empty state message.

9. IF the notification fetch API call fails, THEN THE SpNotificationScreen SHALL display an error message and a retry button.

---

### Requirement 8: Analytics & Reporting

**User Story:** As a CompanyServiceProvider, I want to view performance metrics for my services and business, so that I can understand my growth, identify top-performing services, and make informed decisions.

#### Acceptance Criteria

1. WHEN the CSP opens the analytics screen, THE AnalyticsScreen SHALL be accessible from the bottom navigation bar or profile screen.

2. WHEN the CSP opens the analytics screen, THE AnalyticsScreen SHALL display the following revenue metrics: total revenue (current month), revenue trend (7-day sparkline chart), and month-over-month change percentage.

3. WHEN the CSP views lead metrics, THE AnalyticsScreen SHALL display: total leads received, leads accepted, leads rejected, and conversion rate (accepted / total), fetched from the backend analytics endpoint.

4. WHEN the CSP views service performance, THE AnalyticsScreen SHALL display a ranked list of services by booking count and total revenue generated.

5. WHEN the CSP applies a time period filter (last 7 days, last 30 days, last 90 days), ALL analytics metrics on THE AnalyticsScreen SHALL update to reflect the selected period, and FOR ALL periods the revenue total SHALL equal the sum of all confirmed booking amounts within that period.

6. WHEN the CSP views order analytics, THE AnalyticsScreen SHALL display: total orders, completed orders, cancelled orders, and average order value.

7. WHEN the CSP views customer insights, THE AnalyticsScreen SHALL display the top 5 repeat buyers by booking count.

8. IF the analytics API call fails or returns no data, THEN THE AnalyticsScreen SHALL display a descriptive empty state with a retry option.

---

### Requirement 9: Settings, Support & Utilities

**User Story:** As a CompanyServiceProvider, I want access to app settings, support resources, and legal documents, so that I can configure the app to my preferences and get help when needed.

#### Acceptance Criteria

1. WHEN the CSP accesses the settings screen, THE SettingsScreen SHALL be navigable from the bottom navigation bar or profile screen and SHALL display sections for: Account, Notifications, Support, and Legal.

2. WHEN the CSP opens the Account section in settings, THE SettingsScreen SHALL provide navigation to: change password, manage notification preferences, and delete account.

3. WHEN the CSP opens notification preferences, THE NotificationPreferencesScreen SHALL display toggles for each notification category (leads, bookings, payments, platform announcements) and save preferences via `PUT /settings/notifications`.

4. WHEN the CSP opens the Support section, THE SettingsScreen SHALL display: a contact support form, FAQ accordion list, and links to email and phone support.

5. WHEN the CSP taps "Contact Support", THE SettingsScreen SHALL open a form where the CSP can submit a support ticket with subject and description via `POST /support/ticket`.

6. WHEN the CSP opens the FAQ section, THE SettingsScreen SHALL render a list of question-answer pairs in an accordion layout fetched from `GET /support/faqs` or rendered from a static list.

7. WHEN the CSP opens the Legal section, THE SettingsScreen SHALL display links to: Privacy Policy and Terms of Service, which navigate to the shared LegalScreen.

8. THE Privacy Policy and Terms of Service screens SHALL display the full legal document text fetched from the backend `GET /policy/:type` endpoint.

---

### Requirement 10: Legacy Code Cleanup and Parity Housekeeping

**User Story:** As the development team, we want to remove obsolete, duplicate, and legacy files from the codebase, so that the codebase remains maintainable and new developers are not confused by dead code.

#### Acceptance Criteria

1. THE file `lib/services/config.dart` SHALL be removed after verifying that `lib/core/config/app_environment.dart` is the sole configuration provider and that no live imports remain.

2. THE file `lib/apihelperclass/api_helper.dart` SHALL be removed after verifying that `lib/core/network/api_client.dart` is the sole HTTP client and that no live imports remain.

3. THE file `lib/utils/session_manager.dart` SHALL be removed after verifying that `lib/core/storage/secure_session_manager.dart` is the sole session storage provider and that no live imports remain.

4. THE file `lib/screens/auth/forget_password_screen.dart` SHALL be removed and all navigation references SHALL point to `lib/screens/auth/forgot_password.dart`.

5. THE file `lib/screens/CompanyTransport/notification.dart` SHALL be removed and all navigation references SHALL point to `lib/screens/CompanyTransport/notification_screen.dart`.

6. THE file `lib/screens/CompanyTransport/feed_screen.dart` SHALL be reviewed; if it contains fewer than 50 significant lines of unique widget code, it SHALL be removed and replaced with the appropriate non-stub implementation.

7. THE file `lib/screens/CompanyTransport/states_gridview.dart` SHALL be deleted as it is an empty file.

8. WHEN any legacy file is removed, THE Flutter project SHALL compile without errors and all affected navigation paths SHALL route to the replacement file.

---

### Requirement 11: Mobile UX, Performance, and Navigation Improvements

**User Story:** As a CompanyServiceProvider user, I want the mobile app to be fast, reliable, and intuitive, so that I can accomplish tasks efficiently even on low-end devices or poor network connections.

#### Acceptance Criteria

1. WHEN any list screen (Bookings, Leads, Listings, Notifications) loads more than 20 items, THE list screen SHALL implement paginated loading (cursor or page-based) and fetch additional items when the user scrolls to within 200 pixels of the list end.

2. WHEN the ServiceProviderHomeScreen initializes, THE ServiceProviderHomeController SHALL be instantiated via a GetX Binding class, not inside the `build()` method of any widget.

3. WHEN the user navigates back from any CompanyServiceProvider sub-screen to the home screen, THE back navigation SHALL function correctly and THE home screen data SHALL remain visible without re-fetching unless the data is stale (older than 60 seconds).

4. WHEN a list screen is in a loading state, THE list screen SHALL display skeleton placeholder cards matching the approximate height and layout of real content cards.

5. WHEN a list screen has no results, THE list screen SHALL display a visually distinct empty state with a descriptive message and a relevant quick-action button (e.g., "Add your first service" on MyListingsScreen).

6. WHEN any form screen (Add Service, Edit Service, Lead Follow-up, Support Ticket) has unsaved changes and the user navigates back, THE form screen SHALL display a discard confirmation dialog before navigating away.

7. WHEN the CSP taps a notification that references a specific booking or lead, THE deep link navigation SHALL navigate directly to the correct detail screen in a single step, without passing through intermediate list screens.

