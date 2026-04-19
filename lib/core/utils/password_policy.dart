/// Strong password rules for change / reset password flows.
/// Hint text lists only what is still missing; it shortens as the user types.
class PasswordPolicy {
  PasswordPolicy._();

  static const int minLength = 8;

  static final RegExp _upper = RegExp(r'[A-Z]');
  static final RegExp _lower = RegExp(r'[a-z]');
  static final RegExp _digit = RegExp(r'[0-9]');
  static final RegExp _alnum = RegExp(r'[0-9A-Za-z]');

  static bool hasUppercase(String value) => _upper.hasMatch(value);
  static bool hasLowercase(String value) => _lower.hasMatch(value);
  static bool hasDigit(String value) => _digit.hasMatch(value);

  /// Any non–letter/digit character (excluding whitespace-only).
  static bool hasSpecialCharacter(String value) {
    for (final i in value.runes) {
      final ch = String.fromCharCode(i);
      if (ch.trim().isEmpty) continue;
      if (!_alnum.hasMatch(ch)) return true;
    }
    return false;
  }

  /// `true` when all rules pass.
  static bool isValid(String password) {
    if (password.length < minLength) return false;
    if (!hasUppercase(password)) return false;
    if (!hasLowercase(password)) return false;
    if (!hasDigit(password)) return false;
    if (!hasSpecialCharacter(password)) return false;
    return true;
  }

  /// Non-empty red hint below the field: only missing requirements, comma-separated.
  /// Empty string when [password] is empty (caller hides) or when valid.
  static String requirementHint(String password) {
    if (password.isEmpty) return '';
    final parts = <String>[];
    if (password.length < minLength) {
      parts.add('At least $minLength characters');
    }
    if (!hasUppercase(password)) {
      parts.add('One uppercase letter');
    }
    if (!hasLowercase(password)) {
      parts.add('One lowercase letter');
    }
    if (!hasDigit(password)) {
      parts.add('One number');
    }
    if (!hasSpecialCharacter(password)) {
      parts.add('One special character');
    }
    if (parts.isEmpty) return '';
    return 'Required: ${parts.join(', ')}.';
  }
}
