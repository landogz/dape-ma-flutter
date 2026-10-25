class EmailAddress {
  EmailAddress._();

  static final RegExp _pattern = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$',
  );

  static String normalize(String value) => value.trim().toLowerCase();

  static bool isValid(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty || email.length > 255) {
      return false;
    }
    if (email.contains('..') || email.startsWith('.') || email.endsWith('.')) {
      return false;
    }
    return _pattern.hasMatch(email);
  }
}
