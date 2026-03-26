/// Arguments passed to [CashierResetPasswordScreen] after forgot-password succeeds.
class CashierResetPasswordArgs {
  const CashierResetPasswordArgs({
    required this.username,
    this.serverOtp,
  });

  final String username;

  /// OTP returned by forgot-password API (for reference; user still enters digits in UI).
  final String? serverOtp;
}
