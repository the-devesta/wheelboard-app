# Wheelboard — Business User ↔ Company Service Provider Parity Audit & Modernization Plan

**Scope:** the *service-provider / business* persona across the three repos.
**Source of truth:** current code (read directly; no prior audits trusted).
**Date:** 2026-06-09

> **Naming map (confirmed with product owner):**
> | Concept | Backend | Web (`wheelboard-fe`) | App (`wheelboard-app`) |
> |---|---|---|---|
> | **Service Provider / Business** (offers & fulfils services) | `service-management` + `modules/leads` + `jobs` + `kyc` + `subscription` | `src/app/business/**` | `lib/screens/CompanyServiceProvider/**` |
> | **Consumer** (books & pays for a service) | same `service-management` | `src/app/company/{marketplace,services,bookings}` | `lib/screens/CompanyTransport/{services_screen,service_dashboard}` |
>
> This audit targets the **provider** persona: web `business/*` ≡ app `CompanyServiceProvider/*`. The consumer (CompanyTransport) is referenced only where bookings/payments originate.

---

## 0. Executive Summary

The Flutter `CompanyServiceProvider` module is **structurally present** (16 screens, 6 controllers, real models/services) and is **further along than expected** — Leads CRM, KYC, Subscription, Earnings, Feeds and Notifications are all wired. But it is **split-brain**: one sub-module (`leads/`) is built on the modern design system while the rest is pre-modernization legacy, and there is a cluster of **payment / booking-lifecycle bugs that break the core money-making flow**.

### The five things that matter most

| # | Severity | Finding | Evidence |
|---|---|---|---|
| 1 | **P0 security** | `service-management` controller has **no auth guards at all**; identity (`userId`/`providerId`/`companyId`/`businessId`) is taken from query/body. Any caller can read/mutate any provider's services, bookings, earnings. | `wheelboard-be/src/service-management/services.controller.ts` — no `@UseGuards` anywhere; comment admits "passing userId as a query for simplicity/MVP". Same class of bug as the subscription audit. |
| 2 | **P0 functional** | App **cannot Start or Complete a booking**. Backend requires `providerId` in the body and rejects mismatches; the app sends none. | `BookingDetailsController.startService/completeService` send no `providerId`; backend `startService/completeService` throw *"Only the assigned provider can start/complete this service"* (`services.service.ts:1779,1819`). Web sends it (`business/bookings/[id]/page.tsx:211,727`). |
| 3 | **P0 functional** | A **free-tier provider cannot create a service** (two compounding bugs). (a) `add_service_screen._saveService` reads userId from the legacy `SessionManager("userId")` key that the SecureStorage migration wipes → the guard short-circuits with "User ID not found" before any API call (same class as the Trips create/edit/delete bug). (b) Even past that, the backend **throws HTTP 402 PAYMENT_REQUIRED** with a Razorpay order (`services.service.ts:514–528`) for free providers, and the app never completed that listing-fee flow. |
| 4 | **P0/P1 functional** | **"Record payment"** hits a non-existent endpoint → 404. | `api_endpoints.dart` `recordPayment = /services/earnings/payments`; backend route is `POST /services/payments/manual` (`services.controller.ts:183`). |
| 5 | **P1 functional** | App's booking & lead **counts and lists are wrong/inefficient** — it ignores the dedicated provider endpoints and the real Leads stats, using N+1 per-service fetches and a "bookings = leads" proxy. | `ServiceProviderHomeController.fetchTotalLeads()/fetchBookings()` loop `bookings/service/:id`; backend offers `GET /services/bookings/provider/:providerId` and `GET /leads/provider/:id/stats`. |

The consumer side has its own P0 (faked Razorpay verify in `ServiceDashboardController`), included below for completeness.

**Recommended order:** fix backend auth (P0-1) → fix booking-lifecycle + listing-fee + record-payment contract bugs (P0-2/3/4) → switch dashboards/lists to the proper endpoints (P1) → add the missing payment-status / cash-confirmation workflow (P2) → modernize the legacy screens onto the design system (P3) → cleanup duplicate controllers/cross-imports (P4).

---

## 0.1 Implementation Status — P0 fixes APPLIED (2026-06-09)

All five P0 items are implemented and verified (backend `nest build` clean; `flutter analyze` on changed files = 0 errors / 0 warnings, only pre-existing info lints).

| # | Fix | Files changed | Verified |
|---|---|---|---|
| P0.1 | **Auth guards + JWT-derived identity** on the whole `services` controller. `JwtAuthGuard` on all authed routes; `OptionalJwtAuthGuard` on public browse (`GET /services`, `GET /services/:id`); `RolesGuard`+`@Roles(ADMIN,SUPER_ADMIN)` on admin routes (admin/list, admin/stats, flag, approve, admin delete, bookings/all). Every "me" id (userId/providerId/businessId/booking actor) now comes from `req.user`, never the body/query. publish/unpublish kept as owner (authed) actions. | `wheelboard-be/src/service-management/services.controller.ts` (rewritten) | `nest build` ✅ |
| P0.2 | Send `providerId` (from `AuthService.to.userId`) in booking **start/complete**. | `wheelboard-app/.../ServiceProvider/booking_details_controller.dart` | analyze ✅ |
| P0.3 | **Listing-fee flow** wired: `addService` catches the 402, runs Razorpay against the returned order, resubmits create with `listingPayment*` fields. Also fixed the **legacy-userId guard** in the add-service screen. | `.../Transport/service_provider_controller.dart`, `.../CompanyServiceProvider/add_service_screen.dart` | analyze ✅ |
| P0.4 | `recordPayment` endpoint → `POST /services/payments/manual` (was the non-existent `/services/earnings/payments`). | `.../core/network/api_endpoints.dart` | analyze ✅ |
| P0.5 | **Consumer booking payment** rewritten to the real `initiate → Razorpay(order) → verify` flow with the correct `razorpay_*` field names (was empty order + client UUID that could never verify). | `.../Transport/service_dashboard_controller.dart` | analyze ✅ |

### Audit corrections discovered during implementation
- **Jobs is COMPLETE, not partial** — `JobController` is a full 1:1 mirror of the FE employer API (create/update/delete job, applications inbox, `updateApplicationStatus` pending→hired, applicant profile, hired-professionals CRUD); `sp_job_screen` wires PostJob + JobApplications + HiredProfessionals. Only the UI is legacy.
- **Listing fee is a 402 throw, not a silent success** (corrected in finding #3 above).
- **A second add-service bug** (legacy `SessionManager("userId")`) was blocking *all* service creates/edits, not just free-tier — fixed in P0.3.

### P1 — Core functional parity APPLIED (2026-06-09)

`flutter analyze` on all changed files = 0 errors / 0 warnings.

| # | Fix | Files |
|---|---|---|
| P1.1 | Provider bookings via a single `GET /services/bookings/provider/:id` (backend resolves provider from JWT) — replaced the N+1 per-service loop, which also missed backfilled-providerId bookings. | `api_endpoints.dart` (+`providerBookings`), `service_provider_home_controller.dart` |
| P1.2 | Dashboard "leads" now from the real CRM stats `GET /leads/provider/:id/stats` (`LeadService.getStats`) instead of counting bookings per service. Added `leadStats` to the controller for accurate KPIs. | `service_provider_home_controller.dart` |
| P1.3 | Booking detail refresh fetches the exact record via `GET /services/bookings/:id` when the assignmentId is known (was `bookingsByService[0]`, which could return the wrong booking). Falls back to service-latest when opened with only a serviceId. | `booking_details_controller.dart` |
| P1.4 | **Earnings response key mismatch fixed** — backend returns `serviceBreakdown:[{serviceCategory,earnings,bookings}]` + `timeSeriesData:[{date,earnings}]`, but the model parsed `serviceTitle/totalAmount/bookingCount` + `earningsChart`, so the breakdown and chart rendered **empty**. Model now reads the real keys (back-compat kept). Added monthly/quarterly/yearly **period** toggle (`selectedPeriod` + `setPeriod`, wired the previously-dead chart dropdown). | `service_earnings_model.dart`, `service_earnings_controller.dart`, `earnings_screen.dart` |
| P1.5 | (Jobs) — no work needed; verified already complete. | — |

**New issues found during P1 (not yet fixed):**
- Earnings **Payment History** section is still always empty — the analytics endpoint doesn't return it; needs `GET /services/payments/my` (roadmap item **2.3**).
- Consumer-side `ServiceDashboardController.getServices()` calls `/services/bookings/my` **without `role`**, so the backend's `getMyBookings` falls into the provider branch — the *consumer* dashboard reads provider-scoped bookings. Pre-existing consumer (CompanyTransport) bug, out of the provider scope; fix by sending `role:'company'`.
- The **leads controller** (`modules/leads/leads.controller.ts`) still has **no auth guards** (same class as the service-management hole fixed in P0.1). Recommend applying the same `JwtAuthGuard` + JWT-derived providerId there.

### P2 — Workflow parity APPLIED (2026-06-09)

`flutter analyze` on all changed files = 0 errors / 0 warnings.

| # | Fix | Files |
|---|---|---|
| P2.1 | **`ServiceBookingModel` was fundamentally mismatched** with the backend `mapBooking` shape — it read `assignmentId`/`serviceTitle`/`customerName`/`customerMobile`/`amount`, but the backend returns `id`/`serviceName`/`companyName`/`companyPhone`/`pricing.amount`. So every booking parsed with an **empty assignmentId** (start/complete/cancel would fail with "Assignment ID not found" even after the P0.2 fix) and showed default title/customer/₹0. Rewrote the model to the real keys (back-compat kept). Then added the **full provider action set**: confirm-cash-payment, payment-status (Completed/Cancelled/Refunded), and the dual-confirmation handshake panel (you/company confirmed, fully-completed) on completed/paid bookings. | `service_booking_model.dart`, `api_endpoints.dart` (+`confirmCashPayment`,`paymentStatus`), `booking_details_controller.dart`, `booking_details_screen.dart` |
| P2.2 | Leads **schedule follow-up** (date picker) + **delete** (confirm → back). | `lead_service.dart` (+`scheduleFollowUp`,`deleteLead`), `leads/lead_detail_screen.dart` |
| P2.3 | Earnings **Payment History** now populated from `GET /services/payments/my` (was always empty — analytics doesn't return per-payment rows). Tolerant `PaymentHistory` parsing + refresh on record/pull. | `api_endpoints.dart` (+`myPayments`), `service_earnings_controller.dart`, `service_earnings_model.dart`, `earnings_screen.dart` |
| P2.4 | Notification **deep-links** — tapping a service booking/payment notification opens the booking; a lead notification opens the lead. | `notification_model.dart` (+`serviceId`/`bookingId`/`leadId`/`isServiceBooking`), `sp_notification_screen.dart` |
| P2.5 | Onboarding parity **verified** — `ServiceProviderModel` + `completeServiceProvider`/`updateServiceProvider` already capture businessName/type/address/city/services/gst/phone/email/logo/description, and `profile_screen` exposes edit. Minor gaps deferred to P3: no `state` field, no home "complete your profile" nudge banner. | (verification only) |

> The P2.1 model rewrite is the most consequential change of the whole effort — the provider booking list/detail/actions were effectively non-functional before (empty ids + placeholder display), independent of the P0 auth/providerId fixes.

### P3 — UI modernization APPLIED — core services flow (2026-06-09)

`flutter analyze` on all changed files = 0 errors / 0 warnings. Built on `theme/design_system.dart` (AppPalette/AppText/AppCard/App* states), `leads/*` as the template.

| # | Fix | Files |
|---|---|---|
| P3.1 | **`home_screen` fully rebuilt** as an enterprise dashboard — brand-gradient header, 3 KPI cards (Services / Leads / **Conversion %** from the real `leadStats`), quick actions, My Services (edit/publish), Popular Feeds (ported). Removed legacy `AppColors` + tangled magic-number layout. **Fixed the notification bell** — it opened the *Transport* `NotificationScreen`; now opens the SP `SpNotificationScreen` (with the P2.4 deep-links). | `home_screen.dart` |
| P3.2a | **`my_listings_screen` (Listings tab) fully rebuilt** + **two bug fixes**: delete was permanently broken (`_userId` was declared but never assigned → always "User ID not found"; now uses `AuthService.to.userId`), and the card showed a hardcoded **"Updated 2 days ago"** (placeholder `_getTimeAgo`) — removed. Design-system search, filter pills, cards, states. | `my_listings_screen.dart` |
| P3.2b | `service_details_screen` brand-aligned (design-system background + standardized `AppCard` border/shadow); structure/data already on-brand. | `service_details_screen.dart` |

The full services CRUD visual flow (dashboard → listings → detail) is now modernized and consistent.

**Remaining P3 (deferred — functional, lower ROI):** `booking_details_screen` (already gained the P2.1 panels; legacy chrome), `earnings_screen` (functional, partially modern from P1.4/P2.3, GoogleFonts), `add_service_screen` (large legacy form), `sp_job_screen`/`sp_learning_screen` (legacy GoogleFonts), `profile_screen` (already on-brand with local #F36969 tokens — only needs token swap + the P2.5 `state` field & home completion nudge). These work today; migrating them to the design system is incremental polish.

### P3 remainder + safe fixes + P4 APPLIED (2026-06-10)

`flutter analyze` on all touched files = 0 errors / 0 warnings (4 pre-existing info lints); backend `nest build` clean.

**P3 remainder (a):**
- `earnings_screen` — off-brand teal chart (`0xFF438883` line/dots/fill/tooltip ×7) → palette green; near-miss greys aligned.
- `add_service_screen` — `0x0075FF`→blue, `0x00B894`→green, `0xE83B4F`→primary (form logic untouched).
- `booking_details_screen` — bulk palette alignment (legacy `828282`/`2D3436` greys, `00AAFF` blue, `27AE60` green, `FF4D4F` red, `FF9800` orange → palette equivalents).
- `register_payment_screen` (`347FE9`→blue, borders) + `booking_list_screen` (greys) aligned.
- **`sp_job_screen` / `sp_learning_screen` / `profile_screen` verified already 100% palette-matching — no churn.**
- Home **"Complete your profile" nudge** added (mirrors web `/business/home`; checks businessType/address/city → profile).
- `state` field **deferred with reason**: backend `AlliedBusiness` table has City but **no State column** — adding it is a schema migration + DTO change, not UI polish.

**Safe fixes (b):**
- Consumer `ServiceDashboardController.getServices` now sends `role:'company'` (was hitting the provider branch).
- **`leads.controller.ts` guarded** — `JwtAuthGuard` on all routes; provider-scoped lists derive providerId from JWT, **except admins** (the admin dashboard calls `/leads/provider/:id/stats` for arbitrary users — verified in `wheelboard-admin/src/services/leads.service.ts`). Residual: lead-by-id mutations are auth-only without per-row ownership checks (lead ids are UUIDs); tighten in the service layer if needed.

**P4 (c):**
- **Commission reconcile — with a correction to audit item 4.4:** the plan field for booking commission is `charges.commissionRate` (7/5/3 **percent** by tier), NOT `charges.platformFee` (that's the ₹ listing fee — 249/0/0 — already correctly used by the listing-fee flow). Added `resolveCommissionPercent(providerId)` (plan rate via existing `SubscriptionService.getCommissionRate`, fallback **7%** when unconfigured) and replaced the hardcoded `amount * 0.07` at all three sites: `createBooking`, `verifyPayment`, `completeService`.
- **Dead-code audit verdicts:** `service_assignment_summary.dart` and `myassign_sevice_list.dart` are **live** (consumer-side `service_confirmation`/`service_detail_popup`/`service_dashboard`) — not dead. `widgets/ui/app_ui.dart` has **zero SP usage** (consolidation is a Professional-side task). `ServiceController` is the **consumer** controller (CompanyTransport browse/assign) — **not a duplicate** of `ServiceProviderHomeController`; original audit item 4.1 withdrawn (only minor `fetchServiceDetail(s)` overlap remains).
- Cross-imports (4.2): the home rebuild removed the legacy tangle; remaining CompanyTransport imports (BannerCarousel, FeedScreen, FleetUserprofile, JobsScreen) are genuinely shared components — kept.

> **Deploy note:** smoke-test the P0.1 **and now the leads-guard** backend changes against the web + admin apps before deploy (honest clients are unaffected; verify admin user-detail lead stats + moderation + company-side booking reads). Commission change affects new bookings only — existing rows keep their stored fee.

---

## 1. Complete Feature Inventory

### 1A. Backend (`wheelboard-be`)

| Area | Files | Notes |
|---|---|---|
| Service mgmt | `src/service-management/{services.controller,services.service,services.module}.ts` (service = **2233 lines**) | Services CRUD + publish/unpublish + admin (list/stats/categories/flag/approve/soft-delete) + bookings + payments + earnings + lifecycle. **No guards.** |
| DTOs | `dto/{create-service(146),update-service(4),create-booking(105),create-manual-payment(38)}.dto.ts` | `update-service` extends `PartialType(create-service)`. |
| Leads CRM | `src/modules/leads/{leads.controller,leads.service,leads.module}.ts` | provider leads, stats, status flow, notes, follow-up, contact, convert, lost, delete. Leads are auto-created from bookings. |
| Jobs | `src/jobs/{job.controller,job.service,job.module}.ts` | hiring: create/manage jobs + applications. |
| KYC | `src/kyc/**` | shared with all personas. |
| Subscription | `src/modules/subscription/**` | shared; Razorpay; **previously audited & hardened**. `charges.platformFee` lives on the plan. |
| Learning | `src/modules/learning/**` | courses/modules/categories. |
| Notifications | `src/modules/notifications/**` | in-app; provider gets booking/payment notifications. |
| Enquiries | `src/modules/enquiries/**` | "Direct Inquiry" lead source. |
| Payments | `ServicePayment` repo (inside service-management) + `razorpay.service.ts` | manual + online booking payments. |

**Booking entity model (two tables):** `Booking` (core: assignmentId, serviceId, assignedToUserId=companyId, status, paymentAmount, scheduled*) + `BookingExt` (providerId, companyId/Name/Phone/Logo, serviceName/Category, paymentStatus, paymentMethod, paymentDetailsJson, platformFee, providerEarnings, amountPaid, **businessCompletionConfirmed / companyCompletionConfirmed / fullyCompleted**, startedAt/completedAt). This dual-table split matters for parity (see Workflows).

**Key calculations (confirmed):**
- `platformFee = paymentMethod==='Online' ? round(amount * 0.07) : 0` (hardcoded 7% in `createBooking:1120`, `verifyPayment:1470`, `completeService:1876`).
- `providerEarnings = amount − platformFee`.
- There is *also* a plan-driven `resolvePlatformFeeRate()` reading `charges.platformFee` (`:66–79`) — **inconsistent** with the hardcoded 0.07 used in the booking math. Pick one.
- Earnings analytics: a booking counts as earned when `status==='completed' || paymentMethod==='online'` and not cancelled (`:1643–1651`, "Bug #6" comment).

### 1B. Web (`wheelboard-fe/src/app/business/*`)

| Route | LOC | Purpose |
|---|---|---|
| `home` | 88 | Dashboard: profile-completion banner, `HeroCarousel`, `ServiceCardsGrid`, `RecentServices`, `LeadsSection`. |
| `complete-profile` | 463 | Onboarding / business profile completion. |
| `listings` | 578 | My services list (publish/unpublish/edit/delete). |
| `listings/[id]` | 560 | Service detail + per-service bookings. |
| `bookings` | 209 | My bookings (`getMyBookings(userId,'business')`, `repairProviderBookings` fallback). |
| `bookings/[id]` | 758 | **Full booking lifecycle**: start, complete, cancel, **confirm cash payment**, **update payment status** (Completed/Cancelled/Refunded). |
| `leads` | 433 | Leads CRM list + stats + status filter. |
| `earnings` | 64 | Earnings analytics (period: monthly/quarterly/yearly). |
| `jobs` | 672 | **Hiring**: create/edit/delete job + review applications (`CreateJobModal`, `JobApplicationsModal`). |
| `learning` / `learning/[id]` | 471 / 572 | Courses list + detail. |
| `kyc`, `kyc/upload` | 1 / 1 | **Re-export of `professional/kyc`** (shared). |
| `notifications` | 8 | **Re-export of `professional/notifications`** (shared). |
| `profile` | 984 | Business profile hub. |
| `subscriptions` | 575 | Dedicated plans page (`subscriptionApi` + `useRazorpayPayment`). |
| `feeds` | 470 | Social feed. |

**Web API layer:** `lib/servicesApi.ts` (full booking lifecycle client), `lib/leadsApi.ts`, `lib/subscriptionApi.ts`, `lib/kycApi.ts`, `lib/learningApi.ts`, `lib/notificationsApi.ts`, `lib/dashboardApi.ts`, `lib/feedApi.ts`, `jobsAPI` (in `lib/api.ts`). No per-feature hooks except `useNotifications` / `useRazorpayPayment` — pages call the API clients directly.

### 1C. Flutter (`wheelboard-app/lib/screens/CompanyServiceProvider/*`)

| Screen | LOC | Controller(s) | Design system? |
|---|---|---|---|
| `main_wrapper.dart` | 102 | NotificationController, UserProfileController, JobController, FeedsController | mixed |
| `home_screen.dart` | 1110 | `ServiceProviderHomeController` (+ Transport notif/profile/feeds) | **legacy** (`AppColors`, CompanyTransport cross-imports, SVG) |
| `my_listings_screen.dart` | 680 | `ServiceProviderHomeController` / `ServiceProviderController` | legacy |
| `add_service_screen.dart` | 1100 | `ServiceProviderController` | legacy |
| `service_details_screen.dart` | 547 | `ServiceController`/`ServiceProviderHomeController` | legacy |
| `booking_list_screen.dart` | 324 | `ServiceProviderHomeController` | legacy |
| `booking_details_screen.dart` | 1124 | `BookingDetailsController` | legacy |
| `earnings_screen.dart` | 594 | `ServiceEarningsController` | **legacy** (GoogleFonts + local `_textGrey`) |
| `register_payment_screen.dart` | 378 | `ServiceEarningsController` | legacy (GoogleFonts) |
| `leads/leads_screen.dart` | 218 | `LeadService` | **modern** (`design_system.dart`) |
| `leads/lead_detail_screen.dart` | 350 | `LeadService` | **modern** |
| `leads/lead_status_style.dart` | 37 | — | **modern** |
| `profile_screen.dart` | 1299 | UserProfileController (+ KycScreen, SubscriptionScreen) | legacy-but-on-brand |
| `sp_job_screen.dart` | 905 | `JobController` (+ `hired_professionals_screen`) | **legacy** (GoogleFonts) |
| `sp_learning_screen.dart` | 504 | LearningService | **legacy** (GoogleFonts) |
| `sp_notification_screen.dart` | 438 | NotificationController | legacy |

**Controllers:** `controllers/ServiceProvider/{service_provider_home_controller, booking_details_controller, service_earnings_controller}.dart`; `controllers/Transport/{service_controller, service_provider_controller, service_dashboard_controller}.dart` (latter two are creation/registration + **consumer** side).
**Services:** `lead_service`, `kyc_service`, `subscription_service`, `learning_service`, `profile_service`, `razorpay_service`.
**Models:** `service_model`, `add_service_model`, `update_service_model`, `service_booking_model`, `service_assignment_summary`, `ServiceProvider/service_earnings_model`, `lead_model`, `learning_model`, `service_provider_signup`, `myassign_sevice_list` (`AssignedServiceModel`).

---

## 2. Backend ↔ Web ↔ Flutter Parity Matrix

Legend: ✅ COMPLETE · 🟡 PARTIAL · ❌ MISSING · ⚠️ DIFFERENT/BROKEN · 💀 DEAD

| Feature | Backend | Web | Flutter | Status |
|---|---|---|---|---|
| **Dashboard — stats/KPIs** | leads stats, earnings analytics | hero+grid+recent+leads (light) | home: services + naive `totalLeads`(=booking count) | 🟡 different, inaccurate KPI |
| **Dashboard — charts** | earnings time-series | earnings page chart | earnings_screen chart | 🟡 no period toggle |
| **Service — create** | `POST /services` (+ listing fee gate) | ✅ | ⚠️ listing fee not wired → free users fail silently | ⚠️ |
| **Service — edit** | `PATCH /services/:id` | ✅ | ✅ (`updateService`) | ✅ |
| **Service — delete** | `DELETE /services/:id` | ✅ | ✅ (`deleteService`) | ✅ |
| **Service — publish/unpublish** | `POST /services/:id/(un)publish` | ✅ | ✅ (`togglePublishStatus`) | ✅ |
| **Service — details** | `GET /services/:id` | ✅ + per-service bookings | 🟡 details only (no per-service booking history) | 🟡 |
| **Leads — list** | `GET /leads/provider/:id` | ✅ | ✅ (`LeadService.getProviderLeads`) | ✅ |
| **Leads — stats** | `GET /leads/provider/:id/stats` | ✅ | ✅ (leads_screen) but **home uses booking-count proxy instead** | 🟡 |
| **Leads — detail** | `GET /leads/:id` | ✅ | ✅ (lead_detail) | ✅ |
| **Leads — status flow** | New→Contacted→Qualified→Converted→Lost | ✅ | ✅ (updateStatus/contact/convert/lost/notes) | ✅ |
| **Leads — follow-up / delete** | `PATCH /:id/follow-up`, `DELETE /:id` | ✅ | ❌ (not in `LeadService`) | 🟡 |
| **Bookings — list (provider)** | `GET /services/bookings/provider/:id` | ✅ via `getMyBookings('business')` | ⚠️ N+1 per-service `bookings/service/:id` | ⚠️ |
| **Bookings — detail** | `GET /services/bookings/:id` | ✅ | 🟡 reads `bookings/service/:id[0]` not `/bookings/:id` | 🟡 |
| **Booking — Start** | `PATCH /:id/start` (providerId) | ✅ | ❌ broken (no providerId) | ⚠️ |
| **Booking — Complete** | `PATCH /:id/complete` (providerId, amount) | ✅ | ❌ broken (no providerId) | ⚠️ |
| **Booking — Cancel** | `PATCH /:id/status {Cancelled}` | ✅ | ✅ | ✅ |
| **Booking — confirm cash payment** | `POST /:id/confirm-cash-payment` | ✅ | ❌ | ❌ |
| **Booking — update payment status** | `PATCH /:id/payment-status` | ✅ (Completed/Cancelled/Refunded) | ❌ | ❌ |
| **Booking — company confirm completion** | `PATCH /:id/confirm-completion` | (company side) | ❌ not surfaced | ❌ |
| **Booking — online payment initiate/verify** | `POST /:id/payment/(initiate|verify)` (HMAC) | ✅ | ⚠️ consumer side fakes it (orderId:"" + UUID) | ⚠️ |
| **Earnings — analytics** | `GET /services/earnings/analytics` | ✅ monthly/quarterly/yearly | 🟡 monthly only (no `period`) | 🟡 |
| **Earnings — record manual payment** | `POST /services/payments/manual` | ✅ | ❌ 404 (`/services/earnings/payments`) | ⚠️ |
| **Earnings — my payments list** | `GET /services/payments/my` | ✅ | ❌ | ❌ |
| **Jobs — create/manage** | jobs module | ✅ (CreateJobModal) | ✅ (`JobController.createJob/updateJob/deleteJob` + PostJobScreen) | ✅ (legacy UI) |
| **Jobs — applications/hiring** | jobs module | ✅ (JobApplicationsModal) | ✅ (applications inbox pending→hired + hired-professionals CRUD) | ✅ (legacy UI) |
| **Notifications** | notifications module | ✅ (reuses professional) | ✅ (`NotificationController`, `sp_notification_screen`) | ✅ |
| **Learning — courses/progress** | learning module | ✅ list + detail | 🟡 list (`sp_learning_screen`); detail/progress parity unconfirmed | 🟡 |
| **KYC — upload/verify/status** | kyc module | ✅ (shared) | ✅ (KycScreen via profile + `syncKycStatus`) | ✅ |
| **Subscription** | subscription module | ✅ dedicated page | ✅ shared `SubscriptionScreen(category:'service_provider')` | ✅ |
| **Profile — business profile** | user module | ✅ (984) | ✅ (profile_screen 1299, fully wired) | ✅ |
| **Profile — complete/onboarding** | `POST /users/complete-service-provider` | ✅ complete-profile | 🟡 register flow (signup + register_payment) — parity unconfirmed | 🟡 |
| **Search / filter / sort** | query params | ✅ per page | 🟡 booking status filter + service search only | 🟡 |
| **Feeds** | feed module | ✅ | ✅ (shared FeedScreen) | ✅ |
| **Repair provider bookings** | `POST /bookings/repair/provider/:id` | ✅ fallback | ❌ | 🟡 (maintenance) |

---

## 3. API Contract Audit

`GET/POST/PATCH/DELETE` are relative to the API base. **Web** = used by `business/*`; **Flutter** = used by `CompanyServiceProvider/*`.

| Endpoint | Web | Flutter | Status |
|---|---|---|---|
| `POST /services` (create, multipart) | ✅ `servicesAPI.createService` | ✅ `ServiceProviderController.addService` | ⚠️ Flutter ignores `requiresPayment` listing-fee response |
| `POST /services/listing-fee/initiate` | ✅ | ❌ | **NOT_CONNECTED** |
| `GET /services?userId=` | ✅ | ✅ | COMPLETE |
| `GET /services/:id` | ✅ | ✅ | COMPLETE |
| `PATCH /services/:id` | ✅ | ✅ | COMPLETE |
| `DELETE /services/:id` | ✅ | ✅ | COMPLETE |
| `POST /services/:id/publish` · `/unpublish` | ✅ | ✅ | COMPLETE |
| `POST /services/bookings` (create) | ✅ | ✅ (consumer) | COMPLETE |
| `GET /services/bookings/service/:serviceId` | ✅ | ✅ (overused — N+1) | COMPLETE |
| `GET /services/bookings/provider/:providerId` | ✅ | ❌ | **NOT_CONNECTED** (app uses per-service loop) |
| `GET /services/bookings/company/:companyId` | ✅ | ❌ | NOT_CONNECTED (provider scope n/a) |
| `GET /services/bookings/my?userId&role` | ✅ `'business'` | ⚠️ used by **consumer** `ServiceDashboardController` only | PARTIAL |
| `GET /services/bookings/:id` | ✅ | ❌ (reads `service/:id[0]` instead) | **NOT_CONNECTED** |
| `PATCH /services/bookings/:id/status` | ✅ | ✅ (cancel) | COMPLETE |
| `PATCH /services/bookings/:id/start` | ✅ `{providerId}` | ⚠️ **no body** | **PAYLOAD_MISMATCH** (breaks) |
| `PATCH /services/bookings/:id/complete` | ✅ `{providerId,amount}` | ⚠️ `{amount}` only | **PAYLOAD_MISMATCH** (breaks) |
| `PATCH /services/bookings/:id/confirm-completion` | ✅ `{companyId}` | ❌ | MISSING |
| `POST /services/bookings/:id/confirm-cash-payment` | ✅ `{providerId,amountPaid}` | ❌ | MISSING |
| `PATCH /services/bookings/:id/payment-status` | ✅ `{userId,role,paymentStatus}` | ❌ | MISSING |
| `POST /services/bookings/:id/payment/initiate` | ✅ | ❌ (consumer never calls; opens RZP with `orderId:""`) | NOT_CONNECTED |
| `POST /services/bookings/:id/payment/verify` | ✅ `{razorpay_order_id,payment_id,signature}` | ⚠️ consumer posts `{orderId:"",paymentId(uuid),signature:"",paymentStatus}` | **PAYLOAD_MISMATCH** (HMAC fails) |
| `POST /services/payments/manual` | ✅ `createManualPayment` | ⚠️ app calls `/services/earnings/payments` | **MISSING/404** |
| `GET /services/payments/my?userId` | ✅ | ❌ | MISSING |
| `GET /services/earnings/analytics?userId&period` | ✅ (period) | 🟡 (no period) | PARTIAL |
| `GET /leads/provider/:id` (+status,source) | ✅ | ✅ | COMPLETE |
| `GET /leads/provider/:id/stats` | ✅ | ✅ (leads_screen) | COMPLETE |
| `GET /leads/:id` | ✅ | ✅ | COMPLETE |
| `PATCH /leads/:id/{status,notes,contact,convert,lost}` | ✅ | ✅ | COMPLETE |
| `PATCH /leads/:id/follow-up` · `DELETE /leads/:id` | ✅ | ❌ | MISSING |
| KYC `/kyc/{,/my-kyc,/completeness,…}` | ✅ | ✅ | COMPLETE |
| Subscription `/subscription/*` | ✅ | ✅ | COMPLETE |
| Jobs `/jobs/*` (create, applications, hired) | ✅ | ✅ (`JobController`) | COMPLETE |

> **Server-side note (good):** `services.service.ts:verifyPayment` validates the Razorpay HMAC (`order_id|payment_id`) with no test-mode bypass before the check (`:1431–1455`). The provider online-payment path is secure **server-side**; the breakage is client-side (consumer app posts the wrong shape with no real order).

---

## 4. Workflow Audit

### Service lifecycle — Create → Publish → Lead → Booking → Completion
- **Create:** Backend gates free users behind a listing fee. **Web** handles the `requiresPayment` order + Razorpay; **App misses it** → free providers can't create (silent "success"). *Missing step in app.*
- **Publish/Unpublish:** ✅ both.
- **Lead generation:** every `createBooking` auto-creates a lead (`:1161`). ✅ backend; surfaced in web + app leads.
- **Booking → Completion:** see below.

### Booking lifecycle — Pending → Assigned → Started → Completed (+ dual confirm)
Actual backend machine: `createBooking` → status **Assigned** (default; `Pending` only if explicitly set) → `verifyPayment` confirms online & sets **Assigned** → `startService(providerId)` → **Started** → `completeService(providerId[,amount])` sets **Completed** + `businessCompletionConfirmed` → company `confirmCompanyCompletion` sets `companyCompletionConfirmed` → when both true → `fullyCompleted`. Cash path → `paymentStatus:'ConfirmationPending'` → provider `confirmCashPayment`.
- **Web:** implements start, complete (with final amount for *On Request*), cancel, confirm-cash-payment, payment-status (Completed/Cancelled/Refunded). ✅
- **App:** start + complete **broken** (no providerId); **no** cash confirmation, **no** payment-status, **no** company-confirmation awareness, **no** "On Request final amount" gate surfaced cleanly. *Missing actions + broken steps.*

### Lead lifecycle — New → Contacted → Qualified → Converted/Lost
- ✅ Backend + Web + App all implement the status transitions. App missing **schedule follow-up** + **delete**. Otherwise parity.

### Subscription lifecycle — Purchase → Active → Renewal → Expiry
- ✅ Shared module (already hardened). App uses shared `SubscriptionScreen(category:'service_provider')`. Verify plan-driven `platformFee` is actually applied to booking math (backend currently hardcodes 7%).

### KYC lifecycle — Submitted → Under Review → Approved/Rejected
- ✅ Shared KYC. App: `profile_screen` shows KYC banner, opens `KycScreen`, `syncKycStatus()` from `/kyc/my-kyc`. Parity OK.

---

## 5. Navigation Audit

**Web `business` nav (route-based):** home · listings · bookings · leads · earnings · jobs · learning · kyc · notifications · profile · subscriptions · feeds · complete-profile.

**Flutter bottom nav (5 tabs, `main_wrapper.dart`):** Home · Listings · Feeds · Jobs · Alerts. FAB "Add Service" on Home/Listings.
Reachable off-tab: Profile (avatar tap → `ServiceProviderProfileScreen`), Earnings, Leads, Booking list/details, Learning (from profile), KYC (profile), Subscription (profile), Issues, Legal.

| Web destination | In Flutter? | How reached |
|---|---|---|
| Home | ✅ | Tab 1 |
| Listings | ✅ | Tab 2 + FAB |
| Bookings | 🟡 | `booking_list_screen` — **not on a tab**; reached from Home |
| Leads | ✅ | from Home (not a tab) |
| Earnings | ✅ | from Home/Profile (not a tab) |
| Jobs | ✅ | Tab 4 |
| Learning | ✅ | Profile menu |
| KYC | ✅ | Profile banner |
| Notifications | ✅ | Tab 5 (Alerts) |
| Profile | ✅ | avatar |
| Subscriptions | ✅ | Profile |
| Feeds | ✅ | Tab 3 |
| complete-profile | 🟡 | register/signup flow (parity unconfirmed) |
| **Booking detail actions** (cash confirm / payment status) | ❌ | not present |

**Gaps:** Bookings is buried (no dedicated tab/clear entry); deep links absent (web has `/business/bookings/[id]`, `/business/listings/[id]`); the booking-detail action set is incomplete. **No deep-linking / push-to-screen routing** for the provider notifications that the backend emits (`service_payment_received`, `service_completed`).

---

## 6. UI/UX Audit (Flutter screens)

### Keep (modern, design-system, good parity)
- `leads/leads_screen.dart`, `leads/lead_detail_screen.dart`, `leads/lead_status_style.dart` — built on `theme/design_system.dart` (AppPalette/AppText/AppCard/AppLoading/AppErrorState/AppEmptyState). Stats strip, status filter, clean cards. **Reference implementation for the rest of the module.**

### Refactor (logic reusable; rebuild presentation on the design system)
- `earnings_screen.dart` (594) — controller fine once `period` is added; UI is GoogleFonts + local hex.
- `sp_job_screen.dart` (905) — keep `JobController`; rebuild UI; verify create/applications parity.
- `sp_learning_screen.dart` (504) — keep LearningService; rebuild UI.
- `booking_details_screen.dart` (1124) — keep controller **after fixing providerId**; add cash-confirm + payment-status UI; rebuild presentation.
- `my_listings_screen.dart` (680), `service_details_screen.dart` (547), `booking_list_screen.dart` (324) — switch to `/bookings/provider/:id`; rebuild cards.
- `add_service_screen.dart` (1100) — keep form/validation; **add listing-fee gate**; rebuild UI.
- `register_payment_screen.dart` (378) — **fix endpoint**; rebuild UI.
- `profile_screen.dart` (1299) — already on-brand & fully wired; brand-align tokens to design system (low risk).

### Rebuild (poor architecture / tangled / inaccurate)
- `home_screen.dart` (1110) — legacy `AppColors` full-screen background, imports CompanyTransport `job_screen`/`notification_screen`/`feed_screen`, SVG, heavy debug logging, **inaccurate `totalLeads`**. Rebuild as a real dashboard (KPIs from `/leads/.../stats` + `/earnings/analytics`, recent bookings, quick actions) on the design system.
- `sp_notification_screen.dart` (438) — align to the professional notification card pattern (status icon, deep-link to booking).

---

## 7. Modernization Strategy

**Principle:** keep APIs/services/controllers/models/business logic; rebuild UI/components/navigation/forms/dialogs. Reuse the **existing** design system (`lib/theme/design_system.dart`) — do **not** introduce a second one (note: `lib/widgets/ui/app_ui.dart` is a competing helper; consolidate onto `design_system.dart`).

1. **Design language:** brand `#F36969`, Poppins, AppCard (14–16px radius, 1px `#E5E7EB`, soft shadow), `#F9FAFB` bg — identical to the modernized Trips/Professional screens and the `leads/` screens.
2. **Shared SP widgets to extract:** `SpStatCard`, `SpStatusBadge` (booking + lead + payment states), `SpServiceCard`, `SpBookingCard`, `SpSectionHeader`, `SpEmpty/Loading/Error` (reuse `App*` from design system), `SpMoneyText`.
3. **State treatment:** every list/detail gets explicit loading / empty / error+retry (the `leads/` screens already model this).
4. **Dashboard:** replace marketing-style home with an enterprise dashboard — KPI row (Leads, Conversion %, Active bookings, This-month earnings), revenue mini-chart, recent bookings, "Add Service" CTA, KYC/subscription nudges.
5. **Navigation:** promote **Bookings** to a first-class destination; add booking deep-link routing from notifications; keep 5-tab bottom nav but make off-tab destinations reachable from a consistent dashboard.
6. **Forms/dialogs:** add-service wizard with the listing-fee step; booking-detail action sheet (Start / Complete[+final amount] / Cancel / Confirm cash / Update payment status) mirroring `business/bookings/[id]`.

---

## 8. Implementation Roadmap

### P0 — Production blockers
| # | Item | Files | Dep | Effort | Impact |
|---|---|---|---|---|---|
| 0.1 | Add `JwtAuthGuard` + role guard to `service-management`; derive `userId/providerId/companyId` from JWT, stop trusting query/body | `services.controller.ts`, `services.service.ts` signatures | — | M (1–2d) | Closes full impersonation/data-exposure hole |
| 0.2 | Send `providerId` in Start/Complete (and `amount` for On Request) | `booking_details_controller.dart` | 0.1 | S (2h) | Restores core booking lifecycle in app |
| 0.3 | Wire listing-fee gate in service creation (handle `requiresPayment` → Razorpay → resubmit with `listingPayment`) | `add_service_screen.dart`, `service_provider_controller.dart`, `service_model`/dto | — | M (1d) | Free providers can create services |
| 0.4 | Fix `recordPayment` endpoint → `POST /services/payments/manual` (+ correct DTO fields) | `api_endpoints.dart`, `service_earnings_controller.dart` | — | S (1h) | Manual payment recording works |
| 0.5 | Consumer payment: call `initiate` → real order → Razorpay → `verify` with `razorpay_*` fields | `service_dashboard_controller.dart` | 0.1 | M (1d) | Service booking payments actually settle |

### P1 — Core functional parity
| # | Item | Files | Effort | Impact |
|---|---|---|---|---|
| 1.1 | Use `GET /services/bookings/provider/:id` for lists/counts (drop N+1) | `service_provider_home_controller.dart`, `booking_list_screen.dart` | S | Correct, fast bookings |
| 1.2 | Dashboard KPIs from `/leads/provider/:id/stats` + `/earnings/analytics` | `service_provider_home_controller.dart`, `home_screen.dart` | S | Accurate dashboard |
| 1.3 | Booking detail via `GET /services/bookings/:id` | `booking_details_controller.dart` | S | Correct single-booking data |
| 1.4 | Earnings `period` toggle (monthly/quarterly/yearly) | `service_earnings_controller.dart`, `earnings_screen.dart` | S | Parity |
| 1.5 | Verify/complete Jobs create + applications-review parity | `sp_job_screen.dart`, `job_controller.dart` | M | Hiring parity |

### P2 — Workflow parity
| # | Item | Files | Effort | Impact |
|---|---|---|---|---|
| 2.1 | Booking-detail full action set: confirm-cash-payment, payment-status (Completed/Cancelled/Refunded), company-confirmation awareness | `booking_details_controller.dart`, `booking_details_screen.dart`, `api_endpoints.dart` | M | Full money/booking workflow |
| 2.2 | Leads: schedule follow-up + delete | `lead_service.dart`, `lead_detail_screen.dart` | S | CRM parity |
| 2.3 | "My payments" list (`/services/payments/my`) | `service_earnings_controller.dart`, `earnings_screen.dart` | S | Payment history |
| 2.4 | Notification deep-links → booking/lead screens | `sp_notification_screen.dart`, routing | S | Re-engagement |
| 2.5 | Complete-profile / onboarding parity check | register flow screens | M | Onboarding parity |

### P3 — UI/UX modernization
| # | Item | Files | Effort |
|---|---|---|---|
| 3.1 | Rebuild `home_screen` as enterprise dashboard | `home_screen.dart` | M |
| 3.2 | Refactor earnings/jobs/learning/booking_details/my_listings/add_service/service_details onto design system + shared SP widgets | those files + new `widgets/sp/*` | L |
| 3.3 | Brand-align `profile_screen` + `sp_notification_screen` | those files | S |

### P4 — Cleanup
| # | Item | Files |
|---|---|---|
| 4.1 | Resolve duplicate service controllers (`ServiceController` vs `ServiceProviderHomeController`) | controllers |
| 4.2 | Remove CompanyTransport cross-imports from SP screens (own components) | `home_screen.dart` etc. |
| 4.3 | Consolidate `widgets/ui/app_ui.dart` → `theme/design_system.dart` | both |
| 4.4 | Reconcile backend fee: plan-driven `resolvePlatformFeeRate` vs hardcoded 7% | `services.service.ts` |
| 4.5 | Audit `service_assignment_summary` / `myassign_sevice_list` for dead code | models |

---

## 9. Recommended Execution Order

1. **0.1 backend auth** (everything else should assume identity-from-JWT; doing it first avoids reworking signatures).
2. **0.2 / 0.4** (tiny, high-impact app contract fixes — restore start/complete + record-payment).
3. **0.3 listing-fee** and **0.5 consumer payment** (revenue paths).
4. **P1** dashboard/list correctness (1.1→1.4) — fast wins on the now-secure endpoints; **1.5 Jobs verification**.
5. **P2** complete the booking/lead/payment workflows.
6. **P3** modernization — start by rebuilding `home_screen`, then refactor screen-by-screen using `leads/` as the template; extract shared `widgets/sp/*`.
7. **P4** cleanup + backend fee reconciliation.

> Verify on a device after P0/P1 (provider create → publish → receive booking → start → complete → confirm payment → earnings reflects) before starting P3, exactly as the Trips modernization was validated.

---

### Confidence / verification notes
- **Confirmed by reading:** backend controller + key `services.service.ts` methods (create/createBooking/verifyPayment/start/complete/earnings/listing-fee), leads controller, web `servicesApi`/`leadsApi`/`home`/`bookings[id]`/`jobs`/`subscriptions`/`kyc`/`notifications`, Flutter `main_wrapper`/3 SP controllers/3 Transport service controllers/`lead_service`/`api_endpoints` services group/`leads_screen`/`home_screen` head/`profile_screen` wiring/`add_service` (no listing fee)/`register_payment` head.
- **Needs hands-on verification:** Jobs create+applications parity in `sp_job_screen`; Learning detail/progress parity; complete-profile/onboarding parity; exact UI of earnings/my_listings/service_details/booking_details bodies (sizes + legacy markers known, full bodies not line-read).
