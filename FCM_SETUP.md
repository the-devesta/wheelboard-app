# FCM Push Notifications — Setup

Code is **fully wired**. Every in-app notification the backend creates
(`NotificationsService.createNotification → pushToDevice`) is sent as an FCM
message to the user's stored `deviceId`. The app obtains the FCM token and
registers it (`POST /notifications/register-device`), renders foreground pushes,
and routes taps to the role's notifications screen.

The only thing missing is the **Firebase credentials/config** (which can't live
in source control). Add the items below; no code changes are required.

Until these are added, push is **disabled gracefully** — `PushNotificationService.init()`
catches the missing-config error, logs it, and the rest of the app runs normally.

---

## 1. Firebase project

Create (or reuse) a Firebase project. Use the **same** project whose service
account the backend already uses for Firebase Storage, so server-side FCM sends
work with the existing credentials.

## 2. Android  (package `com.wheelboard.app`)

1. Firebase console → Add app → Android → package name `com.wheelboard.app`.
2. Download **`google-services.json`** → place at `android/app/google-services.json`.
3. `android/settings.gradle.kts` — add to the `plugins { }` block:
   ```kotlin
   id("com.google.gms.google-services") version "4.4.2" apply false
   ```
4. `android/app/build.gradle.kts` — add to its `plugins { }` block:
   ```kotlin
   id("com.google.gms.google-services")
   ```
5. Ensure `minSdk` ≥ 21 (currently `flutter.minSdkVersion`; bump in
   `android/app/build.gradle.kts` if Flutter's default is lower).
   `POST_NOTIFICATIONS` (Android 13+) is contributed by the `firebase_messaging`
   plugin manifest; the in-app permission prompt is already requested at runtime.

## 3. iOS  (bundle id `com.wheelboard.app`)

1. Firebase console → Add app → iOS → bundle id `com.wheelboard.app`.
2. Download **`GoogleService-Info.plist`** and add it to `ios/Runner/` **via
   Xcode** (so it's added to the target, not just the folder).
3. Apple Developer → create an **APNs Auth Key (.p8)**; upload it in Firebase
   console → Project settings → Cloud Messaging → Apple app config.
4. Xcode → Runner target → Signing & Capabilities → add **Push Notifications**
   and **Background Modes → Remote notifications**.
5. Podfile platform is already `14.0` (Firebase needs ≥ 13). Run `pod install`.

## 4. Backend (already coded)

`wheelboard-be` already sends via `firebase-admin`
(`FirebaseService.sendPushNotification` → `admin.messaging().send`). It uses the
same Firebase Admin credentials as Storage:

- `FIREBASE_SERVICE_ACCOUNT_JSON` (or the `firebase-adminsdk.json` service-account
  file `firebase.service.ts` looks for) and `FIREBASE_STORAGE_BUCKET`.

If Storage uploads already work in your environment, FCM sending works too — no
extra backend env is needed. New endpoints added:

- `POST   /notifications/register-device`  `{ deviceId }` — store the FCM token
- `DELETE /notifications/device/unregister` — clear it (called on logout)

## 5. Verify

1. `flutter pub get` (Firebase deps already in `pubspec.yaml`).
2. Run on a real device (FCM doesn't work on iOS simulators).
3. Log in → check the server log for the token being stored on the user
   (`Device token registered for user …`).
4. Trigger any action that creates a notification (assign a trip, book a service,
   apply to a job, etc.) → the device should receive a push in
   foreground / background / terminated; tapping it opens the notifications screen.

---

### How it's wired (for reference)

- `lib/services/push_notification_service.dart` — init, permissions, token
  register/refresh, foreground local-notification display, tap routing.
- `lib/main.dart` — `PushNotificationService.instance.init()` at startup;
  `registerForCurrentUser()` for an already-logged-in session.
- `lib/core/auth/auth_service.dart` — registers the token after every login
  (`_persistSession`) and clears it on `logout()`.
- Backend: `notifications.service.ts registerDevice` + the two controller routes.
