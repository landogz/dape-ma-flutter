/// Firebase / FCM configuration gate for DAPE-MA Mobile.
///
/// Push stays disabled until you run FlutterFire configure (or paste real
/// options) AND place platform credential files. See
/// `docs/PUSH_NOTIFICATIONS.md`.
class FirebasePushConfig {
  const FirebasePushConfig._();

  /// Flip to `true` after adding real `DefaultFirebaseOptions` values and
  /// `google-services.json` / `GoogleService-Info.plist`.
  static const bool isConfigured = false;
}
