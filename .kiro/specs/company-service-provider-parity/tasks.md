# Implementation Plan: CompanyServiceProvider Feature Parity

## Overview

This implementation brings complete feature parity between the CompanyServiceProvider role in the Flutter mobile app and the Business role in the Next.js web frontend. The plan is organized into 11 sequential phases, each building on the previous one to deliver a comprehensive mobile-first service provider experience.

**Implementation Language**: Dart (Flutter 3.x)

**Technology Stack**:
- State Management: GetX
- HTTP Client: Dio with custom interceptors
- Secure Storage: flutter_secure_storage
- Payment: razorpay_flutter
- Image Handling: cached_network_image

## Tasks

### Phase 1: Foundation & Home Dashboard

- [ ] 1. Create core architecture and dependency injection setup
  - [ ] 1.1 Create ServiceProviderBinding class in `lib/features/service_provider/bindings/`
    - Implement GetX Bindings for dependency injection
    - Register ServiceProviderHomeController
    - _Requirements: 1.1, 1.12_
  
  - [ ] 1.2 Enhance ServiceProviderHomeController in `lib/features/service_provider/controllers/`
    - Add observable state variables (isLoadingServices, isLoadingKPIs, services, totalLeads, pendingBookings, totalEarnings, profileComplete, subscriptionStatus, recentLeads, popularFeeds)
    - Implement fetchHomeData() method to load all dashboard data
    - Implement refresh logic with 60-second staleness check
    - Add error handling with retry capability
    - _Requirements: 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 1.10, 1.11, 1.12_


- [ ] 2. Build reusable UI widgets for the dashboard
  - [~] 2.1 Create StatCard widget in `lib/features/service_provider/widgets/`
    - Design card with title, value, icon, and navigation action
    - Implement tap gesture to navigate to detail screens
    - Add loading skeleton state
    - _Requirements: 1.3, 1.4_
  
  - [~] 2.2 Create QuickActionCard widget
    - Design button-style card with icon and label
    - Implement navigation actions
    - _Requirements: 1.6_
  
  - [~] 2.3 Create ServiceCard widget
    - Display service title, category, published status badge
    - Add toggle switch for publish/unpublish action
    - Implement optimistic UI update with rollback on error
    - _Requirements: 1.7_
  
  - [~] 2.4 Create LeadCard widget
    - Display lead title, requester name, status badge, timestamp
    - Implement tap navigation to lead detail
    - _Requirements: 1.8_
  
  - [~] 2.5 Create SkeletonLoader widget
    - Build shimmer effect placeholder matching card layouts
    - _Requirements: 1.10, 11.4_


- [ ] 3. Enhance ServiceProviderHomeScreen
  - [~] 3.1 Implement profile completion banner with conditional display
    - Check profile fields (businessType, address, city, state)
    - Show banner only if fields are missing
    - Add navigation to CompleteProfileScreen
    - _Requirements: 1.1_
  
  - [~] 3.2 Implement hero banner carousel
    - Integrate cached_network_image for banner images
    - Fetch banners from backend API
    - Add auto-scroll and manual swipe gestures
    - _Requirements: 1.2_
  
  - [~] 3.3 Build KPI stats section
    - Display 4 StatCards: Active Services, Total Leads, Pending Bookings, Total Earnings
    - Wire tap actions to navigate to respective screens
    - _Requirements: 1.3, 1.4_
  
  - [~] 3.4 Build subscription status indicator
    - Display current plan name and days remaining
    - Show "Subscribe Now" prompt if no active subscription
    - Add navigation to SubscriptionsScreen
    - _Requirements: 1.5_
  
  - [~] 3.5 Implement Quick Actions row
    - Display 4 QuickActionCards: Add Service, View Bookings, View Earnings, Learning
    - Wire navigation to respective screens
    - _Requirements: 1.6_


  - [~] 3.6 Implement Recent Services section
    - Display 2 ServiceCards with publish toggle
    - Wire toggle action to API endpoint
    - _Requirements: 1.7_
  
  - [~] 3.7 Implement Recent Leads section
    - Display 3 LeadCards with status badges
    - Wire navigation to lead detail screens
    - _Requirements: 1.8_
  
  - [~] 3.8 Implement Popular Feeds section
    - Display 3 feed cards with like count and share action
    - Wire navigation to feed detail screen
    - _Requirements: 1.9_
  
  - [~] 3.9 Integrate loading states throughout the screen
    - Show SkeletonLoader components while data loads
    - _Requirements: 1.10_
  
  - [~] 3.10 Implement error handling with retry button
    - Display error message when API calls fail
    - Add retry button to refetch data
    - _Requirements: 1.11_

- [~] 4. Checkpoint - Verify Phase 1 home dashboard functionality
  - Ensure all KPI cards display correct data
  - Test navigation from each card to detail screens
  - Verify profile completion banner logic
  - Test service publish/unpublish toggle
  - Ensure all tests pass, ask the user if questions arise.



### Phase 2: Service Management System

- [ ] 5. Create MyListingsController and enhance service management
  - [~] 5.1 Create MyListingsController in `lib/features/service_provider/controllers/`
    - Add observable state (isLoading, services, searchQuery, selectedFilter, currentPage, hasMore)
    - Implement fetchServices() with pagination support
    - Implement client-side search filter by title/description
    - Implement status filter (All, Published, Draft)
    - Add deleteService() and togglePublishStatus() methods
    - _Requirements: 2.1, 2.6, 2.9, 2.10_

- [ ] 6. Enhance MyListingsScreen
  - [~] 6.1 Build service list view with pagination
    - Display services grouped by published/unpublished status
    - Implement scroll-to-load-more (trigger at 200px from bottom)
    - Show loading indicator while fetching more
    - _Requirements: 2.1, 2.10_
  
  - [~] 6.2 Implement search bar with real-time filtering
    - Add TextFormField for search input
    - Filter services by title/description as user types
    - Update displayed list without API calls
    - _Requirements: 2.9_
  
  - [~] 6.3 Implement status filter tabs
    - Add tab bar with All, Published, Draft options
    - Filter displayed services based on selected tab
    - _Requirements: 2.1_


  - [~] 6.4 Add edit and delete actions to each service card
    - Implement swipe-to-delete or context menu
    - Show confirmation dialog before deletion
    - Navigate to AddServiceScreen for edit action
    - _Requirements: 2.5_
  
  - [~] 6.5 Implement empty state for no services
    - Display "No services yet" message with illustration
    - Add "Create Your First Service" CTA button
    - _Requirements: 11.5_

- [ ] 7. Enhance AddServiceScreen for create and edit flows
  - [~] 7.1 Build multi-section form layout
    - Create form sections: Basic Info, Pricing, Availability, Media, Location, Custom Attributes
    - Add collapsible section headers for better UX
    - _Requirements: 2.2, 2.4_
  
  - [~] 7.2 Implement Basic Info section
    - Add TextFormField for service title (required)
    - Add DropdownButton for category (fetch from `GET /services/categories`)
    - Add TextFormField for description (multiline, 500 char limit)
    - _Requirements: 2.2_
  
  - [~] 7.3 Implement Pricing section
    - Add TextFormField for amount (number input)
    - Add DropdownButton for pricing unit (per hour / flat price)
    - _Requirements: 2.2_


  - [~] 7.4 Implement Availability section
    - Add time pickers for business hours (from/to)
    - Add multi-select checkboxes for days open
    - _Requirements: 2.2_
  
  - [~] 7.5 Implement Media section
    - Add image picker for up to 5 images
    - Validate file type (JPEG, PNG, WEBP) and size (max 5MB each)
    - Display selected images in grid with remove action
    - Add optional PDF document upload
    - _Requirements: 2.2, 2.8_
  
  - [~] 7.6 Implement Location section
    - Add autocomplete TextFormField for city
    - Add DropdownButton for state
    - Add TextFormField for full address
    - _Requirements: 2.2_
  
  - [~] 7.7 Implement Custom Attributes section
    - Add dynamic key-value pair input fields
    - Allow adding/removing attribute pairs
    - _Requirements: 2.2_
  
  - [~] 7.8 Implement form validation
    - Validate all required fields before submission
    - Show field-level error messages
    - Prevent form submission until all validations pass
    - _Requirements: 2.2, 2.8, 2.11_


  - [~] 7.9 Implement create service API integration
    - Call `POST /services` with multipart/form-data
    - Show loading indicator during submission
    - Handle success: show snackbar, navigate back to MyListingsScreen
    - Handle error: display error message, retain form values
    - _Requirements: 2.3, 2.11_
  
  - [~] 7.10 Implement edit service API integration
    - Pre-populate form fields with existing service data
    - Call `PUT /services/:id` with multipart/form-data
    - Handle success/error same as create flow
    - _Requirements: 2.4, 2.11_
  
  - [~] 7.11 Implement unsaved changes confirmation dialog
    - Detect form changes
    - Show confirmation dialog on back navigation if unsaved changes exist
    - _Requirements: 11.6_

- [ ] 8. Enhance ServiceDetailsScreen
  - [~] 8.1 Build service detail layout
    - Display image carousel at top
    - Show service title, category, description, pricing, availability
    - Display location (city, state, full address)
    - Show custom attributes in key-value list
    - Display total bookings count and average rating
    - _Requirements: 2.7_


  - [~] 8.2 Implement action buttons
    - Add Edit button → navigate to AddServiceScreen with service ID
    - Add Delete button → show confirmation dialog, call `DELETE /services/:id`
    - Add Toggle Publish Status button → call appropriate endpoint based on current status
    - _Requirements: 2.5, 2.6_

- [~] 9. Checkpoint - Verify Phase 2 service management functionality
  - Test creating a new service with all fields
  - Test editing an existing service
  - Test deleting a service with confirmation
  - Test toggling publish/unpublish status
  - Test search and filter functionality
  - Test pagination on listings screen
  - Test form validation and error handling
  - Ensure all tests pass, ask the user if questions arise.

### Phase 3: Leads & Requests

- [ ] 10. Create leads data models
  - [ ] 10.1 Create or verify Lead model in `lib/features/service_provider/models/`
    - Define Lead class with all required fields (id, companyName, providerName, status, serviceName, etc.)
    - Implement fromJson() and toJson() methods
    - _Requirements: 3.1, 3.2, 3.3_


  - [ ] 10.2 Create LeadStats model
    - Define LeadStats class (total, newCount, contacted, qualified, converted, lost, conversionRate, etc.)
    - Implement fromJson() method
    - _Requirements: 8.3_

- [ ] 11. Create LeadsController
  - [~] 11.1 Implement LeadsController in `lib/features/service_provider/controllers/`
    - Add observable state (isLoading, leads, selectedStatus, searchQuery, sortBy, stats)
    - Implement fetchLeads() with pagination
    - Implement client-side status filter (All, New, Accepted, Rejected, Completed)
    - Implement client-side search by requester name or lead title
    - Implement sorting (newest first, oldest first, by status)
    - Add acceptLead() and rejectLead() methods
    - _Requirements: 3.1, 3.2, 3.4, 3.5, 3.6, 3.7, 3.8_

- [ ] 12. Build LeadsScreen
  - [~] 12.1 Create LeadsScreen in `lib/features/service_provider/screens/leads/`
    - Display list of leads with LeadCard widgets
    - Implement tab bar for status filtering
    - Add search bar for filtering by requester/title
    - Add sorting dropdown
    - Implement pagination (load 20 at a time)
    - _Requirements: 3.1, 3.2, 3.6, 3.7, 3.8_


  - [~] 12.2 Implement empty state for no leads
    - Display "No leads yet" message
    - Add "Go to Services" CTA button
    - _Requirements: 3.10_

- [ ] 13. Build LeadDetailScreen
  - [~] 13.1 Create LeadDetailScreen in `lib/features/service_provider/screens/leads/`
    - Display lead title, requester name, contact details, requested service
    - Show current status with badge
    - Display full lead description
    - Build status history timeline component
    - _Requirements: 3.3_
  
  - [~] 13.2 Implement Accept action
    - Add "Accept Lead" button (visible when status is New)
    - Call `PATCH /leads/:id/status` with status='accepted'
    - Update UI immediately with optimistic update
    - _Requirements: 3.4_
  
  - [~] 13.3 Implement Reject action
    - Add "Reject Lead" button (visible when status is New)
    - Show dialog to prompt for rejection reason
    - Call `PATCH /leads/:id/status` with status='rejected' and reason
    - Update UI immediately
    - _Requirements: 3.5_


  - [~] 13.4 Implement Follow Up action
    - Add "Follow Up" button
    - Navigate to FollowUpScreen with lead ID
    - _Requirements: 3.9_

- [ ] 14. Build FollowUpScreen
  - [~] 14.1 Create FollowUpScreen in `lib/features/service_provider/screens/leads/`
    - Add TextFormField for follow-up notes (multiline)
    - Add DatePicker for follow-up date
    - Add submit button
    - Call `POST /leads/:id/follow-up` with date and notes
    - Navigate back to LeadDetailScreen on success
    - _Requirements: 3.9_

- [~] 15. Checkpoint - Verify Phase 3 leads functionality
  - Test viewing all leads with correct data
  - Test filtering by status
  - Test searching by requester name/title
  - Test sorting functionality
  - Test accepting a lead
  - Test rejecting a lead with reason
  - Test creating a follow-up
  - Test pagination
  - Ensure all tests pass, ask the user if questions arise.



### Phase 4: Orders & Bookings

- [ ] 16. Create BookingsController
  - [~] 16.1 Implement BookingsController in `lib/features/service_provider/controllers/`
    - Add observable state (isLoading, allBookings, filteredBookings, selectedTab, currentPage, hasMore)
    - Implement fetchBookings() with pagination
    - Implement tab filtering (All, Assigned, Started, Completed, Cancelled, Pending Payment)
    - Add startService(), completeService(), confirmCashPayment(), cancelBooking() methods
    - Implement optimistic UI updates with rollback on error
    - _Requirements: 4.1, 4.2, 4.4, 4.5, 4.6, 4.9, 4.10, 4.11_

- [ ] 17. Enhance BookingListScreen
  - [~] 17.1 Implement tab navigation for status filtering
    - Add TabBar with All, Assigned, Started, Completed, Cancelled, Pending Payment tabs
    - Filter bookings based on selected tab
    - _Requirements: 4.2_
  
  - [~] 17.2 Build booking list with BookingCard widgets
    - Display service name, buyer company, scheduled date/time, payment method, payment status, booking status
    - Implement tap navigation to BookingDetailsScreen
    - Add pagination (load 20 at a time)
    - _Requirements: 4.1, 4.3, 4.11_



- [ ] 18. Enhance BookingDetailsScreen
  - [~] 18.1 Build booking detail layout
    - Display service name, transport company name and contact
    - Show scheduled date and time
    - Display payment method, payment status, booking status
    - Show all lifecycle timestamps (assigned, started, completed)
    - _Requirements: 4.3_
  
  - [~] 18.2 Implement "Start Service" action
    - Show button when status is Assigned
    - Call `PATCH /services/bookings/:id/start` on tap
    - Update booking status to Started with optimistic UI
    - _Requirements: 4.4_
  
  - [~] 18.3 Implement "Complete Service" action
    - Show button when status is Started
    - Call `PATCH /services/bookings/:id/complete` on tap
    - Update booking status to Completed with optimistic UI
    - _Requirements: 4.5_
  
  - [~] 18.4 Create CashPaymentSlider widget
    - Build custom slider widget with "Slide to Confirm" pattern
    - Implement slide gesture detection
    - Add visual feedback during slide
    - _Requirements: 4.6_


  - [~] 18.5 Implement cash payment confirmation
    - Show CashPaymentSlider when booking is Completed + Cash + ConfirmationPending
    - Call `POST /services/bookings/:id/confirm-cash-payment` on slide complete
    - Update paymentStatus to Paid
    - Trigger earnings recalculation
    - _Requirements: 4.6, 4.7_
  
  - [~] 18.6 Implement "Cancel Booking" action
    - Show button when status is Pending or Assigned
    - Display confirmation dialog before cancellation
    - Call `PATCH /services/bookings/:id/cancel` on confirm
    - Update booking status with optimistic UI
    - _Requirements: 4.9_
  
  - [~] 18.7 Implement error handling and rollback
    - Catch API errors for all status transitions
    - Revert optimistic UI updates on failure
    - Display error message to user
    - _Requirements: 4.10_

- [~] 19. Checkpoint - Verify Phase 4 bookings functionality
  - Test viewing all bookings with filtering
  - Test starting a service
  - Test completing a service
  - Test confirming cash payment with slider
  - Test cancelling a booking
  - Test pagination
  - Verify earnings exclusion/inclusion logic for cash payments
  - Ensure all tests pass, ask the user if questions arise.



### Phase 5: Profile & Business Management

- [ ] 20. Create profile data models
  - [ ] 20.1 Create UserProfile model in `lib/features/service_provider/models/`
    - Define UserProfile class with all required fields (userId, businessName, ownerName, businessType, phone, email, city, state, address, businessLogoPath, isProfileComplete, kycStatus)
    - Implement fromJson() and toJson() methods
    - _Requirements: 5.1_
  
  - [ ] 20.2 Create KycStatus model
    - Define KycStatus class for document verification tracking
    - Include status for each document type (PAN, GST, business registration)
    - Implement fromJson() method
    - _Requirements: 5.4_
  
  - [ ] 20.3 Create PortfolioItem model
    - Define PortfolioItem class (id, type, url, description)
    - Implement fromJson() and toJson() methods
    - _Requirements: 5.10_

- [ ] 21. Create ProfileController
  - [~] 21.1 Implement ProfileController in `lib/features/service_provider/controllers/`
    - Add observable state (isLoading, profile, kycStatus, portfolioItems)
    - Implement fetchProfile() method
    - Implement updateProfile() method
    - Add uploadBusinessLogo() method
    - Implement portfolio management (add, remove)
    - _Requirements: 5.1, 5.2, 5.3, 5.10_



- [ ] 22. Build ServiceProviderProfileScreen
  - [~] 22.1 Create or enhance ServiceProviderProfileScreen in `lib/features/service_provider/screens/`
    - Display business logo (circular avatar with tap-to-change)
    - Show business name, owner name, business type
    - Display phone, email, city, state, address
    - Show KYC status badge
    - Display active subscription plan with days remaining
    - _Requirements: 5.1_
  
  - [~] 22.2 Implement portfolio section
    - Display portfolio items in grid
    - Add "Add Portfolio Item" button
    - Implement remove action for each item
    - _Requirements: 5.10_
  
  - [~] 22.3 Add navigation buttons
    - Add Edit Profile button → navigate to EditProfileScreen
    - Add KYC button → navigate to KYCScreen
    - Add Settings button → navigate to SettingsScreen
    - _Requirements: 5.1_

- [ ] 23. Build EditProfileScreen
  - [~] 23.1 Create EditProfileScreen in `lib/features/service_provider/screens/`
    - Add form fields for business name, owner name, business type, phone, email, city, state, address
    - Pre-populate fields with existing profile data
    - Implement business logo upload with file picker
    - Validate image size < 5MB
    - _Requirements: 5.2, 5.3_


  - [~] 23.2 Implement form submission
    - Call `PUT /users/profile/service-provider` with updated data
    - Show success snackbar and navigate back
    - Handle errors and retain form values
    - _Requirements: 5.2_

- [ ] 24. Build KYCScreen
  - [~] 24.1 Create KYCScreen in `lib/features/service_provider/screens/`
    - Display document status for PAN, GST, business registration
    - Show status badges (Not Uploaded, Pending Review, Approved, Rejected)
    - Add upload button for each document type
    - Display rejection reason if document is rejected
    - Enable re-upload for rejected documents
    - _Requirements: 5.4, 5.5, 5.6_
  
  - [~] 24.2 Implement document upload
    - Implement file picker for each document type
    - Call `POST /kyc/upload/document` with multipart form-data
    - Update document status to Pending Review immediately
    - _Requirements: 5.5_

- [ ] 25. Build CompleteProfileScreen
  - [~] 25.1 Create CompleteProfileScreen in `lib/features/service_provider/screens/`
    - Build multi-step wizard with progress indicator
    - Step 1: Business Info (name, type)
    - Step 2: Contact Info (phone, email)
    - Step 3: Location Info (city, state, address)
    - Step 4: Documents (optional KYC uploads)
    - _Requirements: 5.7_


  - [~] 25.2 Implement wizard navigation and submission
    - Add Next/Previous buttons for step navigation
    - Validate each step before advancing
    - Call `POST /users/complete-service-provider` on final step
    - Navigate to home screen on success
    - _Requirements: 5.7_

- [ ] 26. Build BusinessSettingsScreen
  - [~] 26.1 Create BusinessSettingsScreen in `lib/features/service_provider/screens/`
    - Add navigation to ChangePasswordScreen
    - Add navigation to NotificationPreferencesScreen
    - Add "Delete Account" button with confirmation
    - _Requirements: 5.8_
  
  - [~] 26.2 Implement Change Password flow
    - Build form with old password, new password, confirm password fields
    - Validate password match
    - Call `PUT /settings/account/password`
    - Show success message on completion
    - _Requirements: 5.8_
  
  - [~] 26.3 Implement Delete Account flow
    - Show confirmation dialog requiring email typing
    - Enable confirm button only when email matches
    - Call `DELETE /auth/delete-account`
    - Clear session and navigate to login on success
    - _Requirements: 5.9_



- [~] 27. Checkpoint - Verify Phase 5 profile management functionality
  - Test viewing profile with all data
  - Test editing profile information
  - Test uploading business logo
  - Test KYC document upload
  - Test complete profile wizard flow
  - Test changing password
  - Test deleting account (use test account!)
  - Test portfolio management
  - Ensure all tests pass, ask the user if questions arise.

### Phase 6: Payments, Wallet & Subscriptions

- [ ] 28. Create payment and subscription models
  - [ ] 28.1 Create earnings models in `lib/features/service_provider/models/`
    - Create ServiceEarnings model (serviceId, serviceName, totalEarnings, bookingCount)
    - Create Transaction model (id, bookingId, serviceName, amount, paymentMethod, paymentStatus, createdAt)
    - Implement fromJson() methods
    - _Requirements: 6.1, 6.2_
  
  - [ ] 28.2 Create subscription models
    - Create SubscriptionPlan model (planId, name, price, billingCycle, features)
    - Create SubscriptionModel (subscriptionId, planId, planName, status, expiresAt, daysRemaining)
    - Create BillingTransaction model (transactionId, planName, amount, paymentStatus, createdAt)
    - Implement fromJson() methods
    - _Requirements: 6.3, 6.4, 6.5, 6.10_



- [ ] 29. Create EarningsController
  - [~] 29.1 Implement EarningsController in `lib/features/service_provider/controllers/`
    - Add observable state (isLoading, currentMonthEarnings, allTimeEarnings, earningsByService, transactions, selectedRange)
    - Implement fetchEarnings() for different time periods
    - Implement date range filtering (this week, this month, last 3 months, custom)
    - Ensure cash payments with ConfirmationPending are excluded from totals
    - Ensure online payments and confirmed cash payments are included
    - _Requirements: 6.1, 6.2, 4.7, 4.8_

- [ ] 30. Build EarningsScreen
  - [~] 30.1 Create or enhance EarningsScreen in `lib/features/service_provider/screens/`
    - Display total earnings for current month
    - Display total earnings (all time)
    - Show breakdown by service (list or bar chart)
    - Display transaction list with payment method, amount, booking reference, date
    - _Requirements: 6.1_
  
  - [~] 30.2 Implement date range filter
    - Add filter dropdown (this week, this month, last 3 months, custom range)
    - Update displayed data based on selected range
    - Add custom date range picker for custom option
    - _Requirements: 6.2_


  - [~] 30.3 Implement transaction detail navigation
    - Make each transaction card tappable
    - Navigate to BookingDetailsScreen with booking ID
    - _Requirements: 6.1_

- [ ] 31. Create SubscriptionsController
  - [~] 31.1 Implement SubscriptionsController in `lib/features/service_provider/controllers/`
    - Add observable state (isLoading, availablePlans, currentPlan, billingHistory)
    - Implement fetchPlans() to get available subscription plans
    - Implement fetchCurrentPlan() to get active subscription
    - Implement fetchBillingHistory()
    - Add subscribeToPlan() method with Razorpay integration
    - Add changePlan() method with upgrade/downgrade logic
    - _Requirements: 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.10_

- [ ] 32. Build SubscriptionsScreen
  - [~] 32.1 Create SubscriptionsScreen in `lib/features/service_provider/screens/`
    - Display current plan status (plan name, status badge, days remaining)
    - Show "Subscribe Now" prompt if no active subscription
    - Display available plans in grid/list layout
    - _Requirements: 6.3, 6.4, 6.5_


  - [~] 32.2 Build plan cards
    - Display plan name, price, billing cycle
    - Show feature list for each plan
    - Add CTA button (Subscribe/Upgrade/Manage)
    - _Requirements: 6.3_
  
  - [~] 32.3 Implement subscription actions
    - Handle free plan selection (no payment required)
    - Handle paid plan selection → initiate Razorpay flow
    - Show downgrade confirmation dialog when switching to lower tier
    - Allow upgrade without confirmation
    - _Requirements: 6.6, 6.7, 6.8_
  
  - [~] 32.4 Implement expired subscription handling
    - Display "Expired" badge when subscription expires
    - Show "Renew Now" prompt
    - _Requirements: 6.9_
  
  - [~] 32.5 Build billing history section
    - Display past transactions in list
    - Show date, plan name, amount, payment status for each transaction
    - _Requirements: 6.10_

- [ ] 33. Integrate Razorpay payment flow
  - [~] 33.1 Create or enhance RazorpayService in `lib/services/`
    - Wrap razorpay_flutter package
    - Implement createOrder() method calling `POST /subscription/create-order`
    - Implement openCheckout() to launch Razorpay modal
    - Handle payment success callback
    - Handle payment failure callback
    - _Requirements: 6.6_


  - [~] 33.2 Implement payment verification
    - On payment success, call `POST /subscription/verify-payment` with signature
    - Call `POST /subscription/subscribe` to activate plan
    - Update UI with new subscription status
    - _Requirements: 6.6_
  
  - [~] 33.3 Handle payment errors
    - Display error message on payment failure
    - Provide retry option
    - _Requirements: 6.6_

- [~] 34. Checkpoint - Verify Phase 6 payments and subscriptions functionality
  - Test earnings display with correct data
  - Verify cash payment confirmation exclusion/inclusion logic
  - Test date range filtering on earnings
  - Test viewing available subscription plans
  - Test subscribing to a free plan
  - Test subscribing to a paid plan (use Razorpay test mode)
  - Test upgrading and downgrading plans
  - Test viewing billing history
  - Ensure all tests pass, ask the user if questions arise.



### Phase 7: Notifications & Communication

- [ ] 35. Create NotificationController
  - [~] 35.1 Implement NotificationController in `lib/features/service_provider/controllers/`
    - Add observable state (isLoading, notifications, unreadCount)
    - Implement fetchNotifications() method
    - Implement markAsRead() method for single notification
    - Implement markAllAsRead() method
    - Add real-time update mechanism (WebSocket or polling every 30 seconds)
    - _Requirements: 7.1, 7.2, 7.5, 7.7_

- [ ] 36. Build or enhance SpNotificationScreen
  - [~] 36.1 Create or enhance SpNotificationScreen in `lib/features/service_provider/screens/`
    - Display list of notifications ordered newest first
    - Show notification type icon, title, body text, timestamp
    - Display unread indicator dot for unread notifications
    - _Requirements: 7.2, 7.3_
  
  - [~] 36.2 Implement notification tap handling
    - Mark notification as read on tap
    - Navigate to appropriate detail screen based on notification type
    - _Requirements: 7.4_


  - [~] 36.3 Implement "Mark All as Read" action
    - Add button in app bar
    - Call `POST /notifications/read-all`
    - Remove all unread indicators from UI
    - _Requirements: 7.5_
  
  - [~] 36.4 Implement empty state
    - Display "No notifications yet" message when list is empty
    - _Requirements: 7.8_
  
  - [~] 36.5 Implement error handling
    - Show error message and retry button if API call fails
    - _Requirements: 7.9_

- [ ] 37. Implement notification navigation routing
  - [~] 37.1 Create or enhance NavigationHelper in `lib/core/navigation/`
    - Implement handleNotificationTap() method
    - Route notification types to correct screens:
      - new_lead → LeadDetailScreen(leadId)
      - booking_created → BookingDetailsScreen(bookingId)
      - booking_status_update → BookingDetailsScreen(bookingId)
      - payment_received → EarningsScreen
      - subscription_expiring → SubscriptionsScreen
      - kyc_status_update → KYCScreen
      - platform_announcement → no navigation
    - _Requirements: 7.6, 11.7_



- [ ] 38. Implement bottom navigation badge for unread count
  - [~] 38.1 Update bottom navigation bar widget
    - Add badge widget on notification icon
    - Bind badge count to NotificationController.unreadCount
    - Update badge in real-time as notifications arrive
    - _Requirements: 7.1_

- [~] 39. Checkpoint - Verify Phase 7 notifications functionality
  - Test viewing all notifications
  - Test marking a notification as read
  - Test marking all as read
  - Test navigation from each notification type
  - Test unread count badge updates
  - Test real-time notification updates (WebSocket or polling)
  - Test error handling and retry
  - Ensure all tests pass, ask the user if questions arise.

### Phase 8: Analytics & Reporting

- [ ] 40. Create analytics data models
  - [ ] 40.1 Create analytics models in `lib/features/service_provider/models/`
    - Create RevenueMetrics model (totalRevenue, sparklineData, monthOverMonthChange)
    - Create RevenuePoint model (date, revenue)
    - Create LeadMetrics model (totalLeads, accepted, rejected, conversionRate)
    - Create ServicePerformance model (serviceId, serviceName, bookingCount, totalRevenue)
    - Create OrderAnalytics model (totalOrders, completedOrders, cancelledOrders, averageOrderValue)
    - Create CustomerInsight model (companyId, companyName, bookingCount, totalSpent)
    - Implement fromJson() methods for all models
    - _Requirements: 8.2, 8.3, 8.4, 8.6, 8.7_



- [ ] 41. Create AnalyticsController
  - [~] 41.1 Implement AnalyticsController in `lib/features/service_provider/controllers/`
    - Add observable state (isLoading, selectedPeriod, revenueMetrics, leadMetrics, servicePerformance, orderAnalytics, topCustomers)
    - Implement fetchAnalytics() for all metrics based on selected period
    - Implement period filtering (7 days, 30 days, 90 days)
    - Add error handling with retry capability
    - _Requirements: 8.2, 8.3, 8.4, 8.5, 8.6, 8.7_

- [ ] 42. Build AnalyticsScreen
  - [~] 42.1 Create AnalyticsScreen in `lib/features/service_provider/screens/`
    - Add time period filter dropdown at top
    - Create scrollable layout with sections for each metric type
    - _Requirements: 8.1, 8.5_
  
  - [~] 42.2 Build Revenue Metrics section
    - Display total revenue for current month
    - Show 7-day sparkline chart using fl_chart
    - Display month-over-month change percentage with up/down indicator
    - _Requirements: 8.2, 8.5_
  
  - [~] 42.3 Build Lead Metrics section
    - Display total leads received, accepted, rejected
    - Show conversion rate (accepted / total) as percentage
    - _Requirements: 8.3, 8.5_


  - [~] 42.4 Build Service Performance section
    - Display ranked list of services by booking count and revenue
    - Show bar chart or list view with metrics
    - _Requirements: 8.4, 8.5_
  
  - [~] 42.5 Build Order Analytics section
    - Display total orders, completed orders, cancelled orders
    - Show average order value
    - _Requirements: 8.6, 8.5_
  
  - [~] 42.6 Build Customer Insights section
    - Display top 5 repeat buyers by booking count
    - Show company name, booking count, total spent for each
    - _Requirements: 8.7, 8.5_
  
  - [~] 42.7 Implement empty state and error handling
    - Display descriptive empty state when no data is available
    - Add retry button on API failure
    - _Requirements: 8.8_

- [~] 43. Checkpoint - Verify Phase 8 analytics functionality
  - Test viewing all analytics metrics
  - Test time period filtering (7, 30, 90 days)
  - Verify revenue calculations match confirmed bookings
  - Test sparkline chart rendering
  - Test lead conversion rate calculation
  - Test service performance ranking
  - Test error handling and empty states
  - Ensure all tests pass, ask the user if questions arise.



### Phase 9: Settings, Support & Utilities

- [ ] 44. Create settings data models
  - [x] 44.1 Create settings models in `lib/features/service_provider/models/`
    - Create FAQ model (question, answer)
    - Create NotificationPreference model (category, enabled)
    - Implement fromJson() and toJson() methods
    - _Requirements: 9.6, 9.3_

- [ ] 45. Create SettingsController
  - [~] 45.1 Implement SettingsController in `lib/features/service_provider/controllers/`
    - Add observable state (isLoading, notificationPreferences, faqs, policyContent)
    - Implement fetchNotificationPreferences()
    - Implement updateNotificationPreferences()
    - Implement fetchFAQs()
    - Implement fetchPolicyContent()
    - Add submitSupportTicket() method
    - _Requirements: 9.3, 9.5, 9.6, 9.8_

- [ ] 46. Build SettingsScreen
  - [~] 46.1 Create SettingsScreen in `lib/features/service_provider/screens/`
    - Create sections: Account, Notifications, Support, Legal
    - Build list tiles for each setting option
    - _Requirements: 9.1_


  - [~] 46.2 Implement Account section
    - Add navigation to Change Password screen
    - Add navigation to Notification Preferences screen
    - Add "Delete Account" button
    - _Requirements: 9.2_
  
  - [~] 46.3 Implement Support section
    - Add navigation to Contact Support screen
    - Add navigation to FAQ screen
    - Display email support link (support@wheelboard.com)
    - Display phone support link (+91-XXXXXXXXXX)
    - _Requirements: 9.4_
  
  - [~] 46.4 Implement Legal section
    - Add navigation to Privacy Policy screen
    - Add navigation to Terms of Service screen
    - _Requirements: 9.7_

- [ ] 47. Build NotificationPreferencesScreen
  - [~] 47.1 Create NotificationPreferencesScreen
    - Display toggle switches for each notification category:
      - New Leads
      - Booking Updates
      - Payment Notifications
      - Platform Announcements
    - Bind switches to controller state
    - _Requirements: 9.3_


  - [~] 47.2 Implement save functionality
    - Add Save button
    - Call `PUT /settings/notifications` with updated preferences
    - Show success snackbar and navigate back
    - _Requirements: 9.3_

- [ ] 48. Build SupportTicketScreen
  - [~] 48.1 Create SupportTicketScreen
    - Add TextFormField for subject
    - Add TextFormField for description (multiline, 1000 char limit)
    - Add character counter for description
    - Validate required fields
    - _Requirements: 9.5_
  
  - [~] 48.2 Implement ticket submission
    - Call `POST /issues` with subject and description
    - Show success confirmation message
    - Navigate back to settings
    - _Requirements: 9.5_

- [ ] 49. Build FAQScreen
  - [~] 49.1 Create FAQScreen
    - Display FAQs in accordion/expansion tile layout
    - Fetch from `GET /support/faqs` or load from static assets
    - _Requirements: 9.6_
  
  - [~] 49.2 Implement FAQ search filter
    - Add search bar at top
    - Filter FAQs by question text as user types
    - _Requirements: 9.6_



- [ ] 50. Build LegalScreen
  - [~] 50.1 Create LegalScreen
    - Accept policy type parameter (privacy | terms)
    - Fetch content from `GET /policy/:type`
    - Display content in scrollable text widget
    - Add back button to settings
    - _Requirements: 9.7, 9.8_

- [~] 51. Checkpoint - Verify Phase 9 settings and support functionality
  - Test navigating to all settings sections
  - Test updating notification preferences
  - Test submitting a support ticket
  - Test viewing FAQs with search
  - Test viewing Privacy Policy
  - Test viewing Terms of Service
  - Ensure all tests pass, ask the user if questions arise.

### Phase 10: Legacy Code Cleanup

- [ ] 52. Audit and remove legacy configuration files
  - [~] 52.1 Verify AppEnvironment is the sole configuration provider
    - Search for all imports of `lib/services/config.dart`
    - Replace imports with `lib/core/config/app_environment.dart`
    - Verify all config access uses AppEnvironment
    - _Requirements: 10.1_


  - [~] 52.2 Delete lib/services/config.dart
    - Confirm no remaining imports
    - Delete the file
    - _Requirements: 10.1, 10.8_

- [ ] 53. Audit and remove legacy HTTP client
  - [~] 53.1 Verify ApiClient is the sole HTTP client
    - Search for all imports of `lib/apihelperclass/api_helper.dart`
    - Replace with `lib/core/network/api_client.dart`
    - Verify all API calls use ApiClient
    - _Requirements: 10.2_
  
  - [~] 53.2 Delete lib/apihelperclass/api_helper.dart
    - Confirm no remaining imports
    - Delete the file
    - _Requirements: 10.2, 10.8_

- [ ] 54. Audit and remove legacy session manager
  - [~] 54.1 Verify SecureSessionManager is the sole session storage provider
    - Search for all imports of `lib/utils/session_manager.dart`
    - Replace with `lib/core/storage/secure_session_manager.dart`
    - Verify all token storage uses SecureSessionManager
    - _Requirements: 10.3_
  
  - [~] 54.2 Delete lib/utils/session_manager.dart
    - Confirm no remaining imports
    - Delete the file
    - _Requirements: 10.3, 10.8_



- [ ] 55. Remove duplicate auth screens
  - [~] 55.1 Consolidate forget password screens
    - Search for navigation references to `lib/screens/auth/forget_password_screen.dart`
    - Update all references to point to `lib/screens/auth/forgot_password.dart`
    - Delete `lib/screens/auth/forget_password_screen.dart`
    - _Requirements: 10.4, 10.8_

- [ ] 56. Remove duplicate CompanyTransport screens
  - [~] 56.1 Consolidate notification screens
    - Search for navigation references to `lib/screens/CompanyTransport/notification.dart`
    - Update all references to point to `lib/screens/CompanyTransport/notification_screen.dart`
    - Delete `lib/screens/CompanyTransport/notification.dart`
    - _Requirements: 10.5, 10.8_
  
  - [~] 56.2 Review and handle feed_screen.dart
    - Review `lib/screens/CompanyTransport/feed_screen.dart`
    - If stub (< 50 significant lines), delete and replace navigation references
    - If substantial, retain and document
    - _Requirements: 10.6_
  
  - [~] 56.3 Delete empty states_gridview.dart file
    - Delete `lib/screens/CompanyTransport/states_gridview.dart`
    - Confirm file is empty or trivial
    - _Requirements: 10.7_



- [ ] 57. Verify Flutter project compilation after cleanup
  - [~] 57.1 Run flutter clean and flutter pub get
    - Execute `flutter clean`
    - Execute `flutter pub get`
    - _Requirements: 10.8_
  
  - [~] 57.2 Compile and verify no errors
    - Execute `flutter build apk --debug` or `flutter run`
    - Verify no compilation errors
    - Verify all navigation routes work correctly
    - _Requirements: 10.8_

- [~] 58. Checkpoint - Verify Phase 10 legacy cleanup
  - Confirm all legacy files are deleted
  - Verify project compiles without errors
  - Test navigation paths that were updated
  - Ensure all tests pass, ask the user if questions arise.

### Phase 11: Mobile UX, Performance & Navigation Improvements

- [ ] 59. Implement pagination across all list screens
  - [~] 59.1 Audit pagination implementation
    - Verify MyListingsScreen has pagination (load 20, trigger at 200px from bottom)
    - Verify LeadsScreen has pagination
    - Verify BookingListScreen has pagination
    - Verify SpNotificationScreen has pagination
    - _Requirements: 11.1, 2.10_


  - [~] 59.2 Ensure consistent pagination behavior
    - All list screens should load 20 items initially
    - All list screens should fetch more when scrolled to 200px from bottom
    - Show loading indicator while fetching more
    - _Requirements: 11.1_

- [ ] 60. Optimize controller initialization with GetX Bindings
  - [~] 60.1 Verify ServiceProviderHomeController uses Binding
    - Ensure ServiceProviderHomeController is instantiated via ServiceProviderBinding
    - Verify controller is NOT created in build() method
    - _Requirements: 11.2_
  
  - [~] 60.2 Create bindings for all other controllers if missing
    - Ensure all controllers have corresponding Binding classes
    - Register bindings in route definitions
    - _Requirements: 11.2_

- [ ] 61. Implement smart home screen refresh logic
  - [~] 61.1 Add staleness check to ServiceProviderHomeController
    - Track last fetch timestamp
    - On navigation back to home, check if data is older than 60 seconds
    - Only refetch if stale
    - _Requirements: 11.3_


  - [~] 61.2 Preserve home screen data on back navigation
    - Ensure existing data remains visible while refetching
    - Avoid flickering or blank screens
    - _Requirements: 11.3_

- [ ] 62. Implement skeleton loaders for all list screens
  - [~] 62.1 Verify SkeletonLoader widget exists and is reusable
    - Ensure widget matches approximate height and layout of real content
    - _Requirements: 11.4_
  
  - [~] 62.2 Apply skeleton loaders to all list screens
    - Use in MyListingsScreen while loading
    - Use in LeadsScreen while loading
    - Use in BookingListScreen while loading
    - Use in SpNotificationScreen while loading
    - Use in ServiceProviderHomeScreen sections while loading
    - _Requirements: 11.4_

- [ ] 63. Implement descriptive empty states for all list screens
  - [~] 63.1 Create or verify EmptyStateWidget
    - Widget should accept message and optional action button
    - Widget should have illustration or icon
    - _Requirements: 11.5_


  - [~] 63.2 Apply empty states to all list screens
    - MyListingsScreen: "No services yet" + "Create Your First Service" button
    - LeadsScreen: "No leads yet" + "Go to Services" button
    - BookingListScreen: "No bookings yet"
    - SpNotificationScreen: "No notifications yet"
    - _Requirements: 11.5_

- [ ] 64. Implement unsaved changes confirmation for form screens
  - [~] 64.1 Add change detection to AddServiceScreen
    - Track form field changes
    - Show confirmation dialog on back navigation if unsaved changes exist
    - _Requirements: 11.6_
  
  - [~] 64.2 Add change detection to other form screens
    - Apply to EditProfileScreen
    - Apply to FollowUpScreen
    - Apply to SupportTicketScreen
    - _Requirements: 11.6_

- [ ] 65. Enhance deep link navigation for notifications
  - [~] 65.1 Verify NavigationHelper.handleNotificationTap() routes correctly
    - Test navigation from each notification type
    - Ensure direct navigation without intermediate screens
    - _Requirements: 11.7_


  - [~] 65.2 Test deep link navigation end-to-end
    - Send test notifications for each type
    - Verify tapping notification lands on correct detail screen
    - Verify notification is marked as read
    - _Requirements: 11.7_

- [~] 66. Final checkpoint - Verify all Phase 11 UX improvements
  - Test pagination on all list screens
  - Verify controller initialization via Bindings
  - Test home screen refresh logic (navigate away and back)
  - Verify skeleton loaders display during loading
  - Verify empty states display when no data
  - Test unsaved changes dialogs on all forms
  - Test deep link navigation from all notification types
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 67. Final integration testing and polish
  - [~] 67.1 End-to-end testing of complete user journey
    - Test full CSP onboarding flow
    - Test service creation, editing, deletion
    - Test lead acceptance and follow-up
    - Test booking lifecycle (start, complete, cash confirmation)
    - Test subscription purchase flow
    - Test notification handling
    - _Requirements: All_


  - [~] 67.2 Performance testing on low-end devices
    - Test on Android device with 2GB RAM
    - Verify smooth scrolling in list screens
    - Verify image loading performance
    - Check app memory usage
    - _Requirements: 11.1, 11.4_
  
  - [~] 67.3 Network resilience testing
    - Test with slow network connection
    - Test with intermittent connectivity
    - Verify error messages and retry buttons work
    - Ensure no data loss on network failures
    - _Requirements: 1.11, 2.11, 4.10_
  
  - [~] 67.4 Accessibility and UI polish
    - Verify all buttons have adequate touch targets (48x48dp minimum)
    - Check text contrast ratios
    - Test with large font sizes
    - Verify all form fields have proper labels
    - _Requirements: All_

- [ ] 68. Documentation and handoff
  - [~] 68.1 Update code documentation
    - Add doc comments to all controllers
    - Document API endpoint usage in controllers
    - Add usage examples for reusable widgets
    - _Requirements: All_


  - [~] 68.2 Create implementation summary
    - Document all new screens and controllers
    - List all API endpoints used
    - Note any deviations from original design
    - _Requirements: All_

## Notes

- All tasks reference specific requirements for traceability
- Each phase must be completed before moving to the next
- Checkpoints ensure incremental validation of functionality
- Focus exclusively on coding tasks that can be executed by an LLM agent
- The design uses Dart (Flutter) with specific libraries: GetX, Dio, flutter_secure_storage, razorpay_flutter, cached_network_image, fl_chart
- All API integrations leverage existing NestJS backend endpoints
- No new backend endpoints are introduced unless explicitly required
- State management follows GetX patterns with observable variables and reactive updates
- All form screens implement validation and error handling
- All list screens implement pagination for scalability
- Deep linking supports notification-driven navigation
- Legacy code cleanup ensures codebase maintainability


## Task Dependency Graph

```json
{
  "waves": [
    {
      "id": 0,
      "tasks": ["1.1", "1.2", "10.1", "10.2", "20.1", "20.2", "20.3", "28.1", "28.2", "40.1", "44.1"]
    },
    {
      "id": 1,
      "tasks": ["2.1", "2.2", "2.3", "2.4", "2.5", "5.1", "11.1", "16.1", "21.1", "29.1", "31.1", "35.1", "41.1", "45.1"]
    },
    {
      "id": 2,
      "tasks": ["3.1", "3.2", "3.3", "3.4", "3.5", "6.1", "6.2", "6.3", "12.1", "17.1", "22.1", "22.2", "30.1", "30.2", "32.1", "32.2", "36.1", "36.2", "42.1", "42.2", "46.1", "46.2"]
    },
    {
      "id": 3,
      "tasks": ["3.6", "3.7", "3.8", "3.9", "3.10", "6.4", "6.5", "12.2", "17.2", "22.3", "30.3", "32.3", "32.4", "36.3", "36.4", "42.3", "42.4", "46.3", "46.4"]
    },
    {
      "id": 4,
      "tasks": ["7.1", "7.2", "7.3", "7.4", "7.5", "13.1", "13.2", "13.3", "18.1", "18.2", "23.1", "32.5", "36.5", "42.5", "42.6", "47.1"]
    },
    {
      "id": 5,
      "tasks": ["7.6", "7.7", "7.8", "7.9", "13.4", "18.3", "18.4", "23.2", "33.1", "42.7", "47.2", "48.1"]
    },
    {
      "id": 6,
      "tasks": ["7.10", "7.11", "14.1", "18.5", "18.6", "24.1", "33.2", "48.2", "49.1"]
    },
    {
      "id": 7,
      "tasks": ["8.1", "8.2", "18.7", "24.2", "25.1", "33.3", "49.2", "50.1"]
    },
    {
      "id": 8,
      "tasks": ["25.2", "26.1", "26.2", "37.1", "38.1", "52.1", "53.1", "54.1"]
    },
    {
      "id": 9,
      "tasks": ["26.3", "52.2", "53.2", "54.2", "55.1", "56.1", "56.2", "56.3"]
    },
    {
      "id": 10,
      "tasks": ["57.1", "57.2", "59.1", "59.2", "60.1", "60.2"]
    },
    {
      "id": 11,
      "tasks": ["61.1", "61.2", "62.1", "62.2", "63.1", "63.2"]
    },
    {
      "id": 12,
      "tasks": ["64.1", "64.2", "65.1", "65.2"]
    },
    {
      "id": 13,
      "tasks": ["67.1", "67.2", "67.3", "67.4"]
    },
    {
      "id": 14,
      "tasks": ["68.1", "68.2"]
    }
  ]
}
```
