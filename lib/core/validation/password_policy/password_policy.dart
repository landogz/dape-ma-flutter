class PasswordPolicyChecks {
  const PasswordPolicyChecks({
    required this.length,
    required this.mixed,
    required this.number,
    required this.symbol,
  });

  final bool length;
  final bool mixed;
  final bool number;
  final bool symbol;

  bool get allMet => length && mixed && number && symbol;
}

class PasswordPolicy {
  PasswordPolicy._();

  static const minLength = 8;

  static const hint =
      'Password must include at least 8 characters, upper and lower case, a number, a symbol.';

  static final RegExp _lower = RegExp(r'[a-z]');
  static final RegExp _upper = RegExp(r'[A-Z]');
  static final RegExp _number = RegExp(r'\d');
  static final RegExp _symbol = RegExp(r'[\p{P}\p{S}]', unicode: true);

  static PasswordPolicyChecks checks(String? value) {
    final password = value ?? '';
    return PasswordPolicyChecks(
      length: password.length >= minLength,
      mixed: _lower.hasMatch(password) && _upper.hasMatch(password),
      number: _number.hasMatch(password),
      symbol: _symbol.hasMatch(password),
    );
  }

  static bool isValid(String? value) => checks(value).allMet;
}
