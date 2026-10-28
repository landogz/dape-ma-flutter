/// Client-side username rules — keep aligned with
/// `App\Support\Username\Username` on the API.
class UsernamePolicy {
  UsernamePolicy._();

  static const minLength = 3;
  static const maxLength = 30;
  static final RegExp pattern = RegExp(r'^[A-Za-z0-9._-]+$');

  static String normalize(String value) {
    var username = value.trim();
    if (username.startsWith('@')) {
      username = username.substring(1).trim();
    }
    return username;
  }

  /// Returns an l10n key hint: `required`, `invalid`, or null when valid.
  static String? validate(String raw) {
    final username = normalize(raw);
    if (username.isEmpty) return 'required';
    if (username.length < minLength ||
        username.length > maxLength ||
        !pattern.hasMatch(username)) {
      return 'invalid';
    }
    return null;
  }
}
