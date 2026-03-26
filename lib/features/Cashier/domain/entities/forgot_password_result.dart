/// Result of a successful forgot-password request (OTP + message from API).
class ForgotPasswordResult {
  const ForgotPasswordResult({
    required this.otp,
    required this.message,
  });

  final String otp;
  final String message;
}
