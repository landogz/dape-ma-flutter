# Mobile Push Notifications (FCM)

Admin **Send Push Notification** (`/admin/notifications`) delivers:

1. **FCM device push** to registered mobile tokens  
2. **In-app inbox** rows (`user_notifications`, type `admin_push`)

## Laravel

1. Set the legacy FCM server key in `.env`:

```env
FCM_SERVER_KEY=your_firebase_cloud_messaging_server_key
```

2. Config is read from `config/services.php` → `services.fcm.server_key`.

3. Device registration API (auth required):

- `PUT /api/v1/device/fcm-token` — body `{ "fcm_token": "...", "platform": "android"|"ios"|"web" }`
- `DELETE /api/v1/device/fcm-token` — clears token (also cleared on logout)

4. Campaign send: `POST /api/v1/admin/notifications/send`  
   Audience: `all` | `android` | `ios` (filters by `users.fcm_platform`).

## Flutter

1. Create a Firebase project and add Android + iOS apps matching:

- Android applicationId: `com.example.dape_ma_mobile` (or update both Gradle + Firebase)
- iOS bundle id: your Runner product bundle identifier

2. Download credentials (do **not** commit secrets to public remotes if policy forbids it):

- Copy `android/app/google-services.json.example` → `android/app/google-services.json` and paste Firebase contents  
- Copy `ios/Runner/GoogleService-Info.plist.example` → `ios/Runner/GoogleService-Info.plist` and paste Firebase contents  

3. Enable push in code:

- Open `lib/features/push/firebase_push_config.dart`
- Set `FirebasePushConfig.isConfigured = true`
- Prefer generating options with FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

If you use generated `firebase_options.dart`, call `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` inside `PushNotificationService` (replace the bare `Firebase.initializeApp()` call).

4. iOS: enable **Push Notifications** + **Background Modes → Remote notifications** in Xcode; upload an APNs key to Firebase.

5. Install packages and run:

```bash
flutter pub get
flutter run
```

6. Sign in on a **physical device** when possible (simulators have limited push support). Confirm `users.fcm_token` and `fcm_platform` are populated, then send from admin.

## Notes

- Without `FCM_SERVER_KEY`, admin send returns an error but may still write in-app inbox rows.
- Without Firebase app files / `isConfigured = true`, the Flutter app runs normally and skips push registration.
- Android Google Services Gradle plugin applies only when `google-services.json` exists.
