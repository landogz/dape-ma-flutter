class PasswordPolicy {
  PasswordPolicy._();

  static const minLength = 8;

  static const hint =
      'Password must include at least 8 characters, upper and lower case, a number, a symbol.';

  static final RegExp _lower = RegExp(r'[a-z]');
  static final RegExp _upper = RegExp(r'[A-Z]');
  static final RegExp _number = RegExp(r'\d');
  static final RegExp _symbol = RegExp(r'[\p{P}\p{S}]', unicode: true);

  static bool isValid(String? value) {
    final password = value ?? '';
    if (password.length < minLength) {
      return false;
    }
    if (!_lower.hasMatch(password) || !_upper.hasMatch(password)) {
      return false;
    }
    if (!_number.hasMatch(password)) {
      return false;
    }
    if (!_symbol.hasMatch(password)) {
      return false;
    }
    return true;
  }
}
