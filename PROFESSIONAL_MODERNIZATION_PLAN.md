# Professional Experience Modernization Plan

**Goal:** Rebuild & modernize the Professional experience in `wheelboard-app` (Flutter/GetX) with an
Uber/Rapido-grade UI, while preserving **100% functional parity** with `wheelboard-fe`
(Next.js) — same APIs, same trip statuses, same business rules.

**Date:** 2026-06-06
**Reference of truth:** `wheelboard-fe/src/app/professional/*` + `src/hooks/useTrips.ts` + `src/lib/tripsTransform.ts`

---

## Starting point (verified by audit)

The app is **not** green-field. It already has:

- A complete **design system** at `lib/theme/` (`AppPalette`, `AppText`, `AppSpacing`/`AppRadius`,
  `AppPrimaryButton`/`AppSecondaryButton`/`AppCard`, `AppLoading`/`AppEmptyState`/`AppErrorState`/`AppBanner`,
  `AppSheetScaffold`) — brand `#F36969`, Poppins.
- **~92–98% functional parity** already implemented (auth, Dio + Bearer, secure storage, trips API,
  LR/POD, payments, socket realtime tracking — see `parity_audit_report.md`).
- A working **trip step-machine** controller (`trip_navigation_controller.dart`) mirroring the web
  `navigate` flow: `confirmOtp → readyToStart → navigatingToPickup → atPickup → inTransit →
  atDestination → podUpload → completed`.

### The real divergence
The Professional **Trips tab is a "smart router"** (`ProfessionalTripsScreen`) that jumps straight into
`TrackTripScreen` or falls back to `TripDashboardScreen`. The web instead shows a proper **"My Trips"
list** (stats grid + filter tabs `All/Assigned/In-Process/Completed` + route cards → `/navigate`).

So this is **redesign-on-top-of-parity**, executed in phases. Each phase keeps the app compiling and
preserves existing backend integrations; only frontend structure is refactored where needed.

---

## Single source of truth (cross-cutting)

- **Trip data:** `AssignedTripController.assignedTrips` (already permanent in the Professional wrapper)
  is the canonical store. No screen fetches trips independently.
- **Status mapping:** one `TripStatusMapper` (`lib/utils/trip_status.dart`) mirrors the web
  `mapBackendStatus` + `calculateProgress`. All Professional screens classify trips through it — no
  per-screen status string sets.

---

## Phases

### Phase 1 — Trips module foundation + "My Trips" list  ← in progress
1a. `lib/utils/trip_status.dart` — single-source status→bucket + progress mapper (web-exact).
1b. Enrich `AssignedTripController` — derived stats (completed/in-process/assigned/earnings/rating),
    `selectedFilter`, and real `hasError`/`errorMessage` for retry states.
1c. Rebuild `ProfessionalTripsScreen` → modern **My Trips** list: header, 2×2 stats grid, filter tabs,
    animated route cards (gradient header, timeline, date/distance/duration, in-process progress bar),
    loading/error/empty/retry, pull-to-refresh. Card tap → `TrackTripScreen` (step machine), web parity.
1d. `flutter analyze` (changed files) → 0 errors.

### Phase 2 — Trip lifecycle (navigate / track / LR-OTP / POD / completed)
Modernize the step-machine screens to Uber/Rapido style while keeping the exact state transitions and
endpoints already wired in `trip_navigation_controller`:
- `TrackTripScreen` — full-bleed map, bottom action sheet per step, LR-OTP confirm sheet,
  arrival confirmations, call/ navigate buttons.
- `PodCollectionScreen` / `TripCompletedScreen` — modern capture + summary.
- Keep socket + REST location pinging untouched.

### Phase 3 — Notifications parity
Rework `Notification1Screen` to match web information density, including **LR OTP** display when the
notification type requires it, with the full trip context (route, pay, vehicle, action CTA).

### Phase 4 — Remaining Professional screens
Apply the same design system + state patterns to Home, Find Jobs / Job Details / Job Progress, Earnings/
Transactions, Profile/Edit, Calendar, Rewards/Referrals, Subscription, Search, SOS, Learning.

### Phase 5 — Cleanup
Remove obsolete/duplicate/legacy code surfaced by the audit (e.g. `AddReferral2/`, `CalendarInactive/`
if dead, empty stubs), dead controllers, and any leftover mock UI — verified safe before deletion.

---

## Guardrails
- No backend/endpoint changes; reuse existing services & controllers.
- Every phase ends compiling (`flutter analyze`) with no new errors.
- Status/flow parity is mechanical (via `TripStatusMapper`); UI is the only thing modernized.
- Trip module (Phase 1–2) completed before moving to other modules.
</content>
</invoke>
