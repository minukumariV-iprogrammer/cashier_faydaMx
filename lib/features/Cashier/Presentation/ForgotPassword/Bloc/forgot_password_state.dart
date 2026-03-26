import 'package:equatable/equatable.dart';

import '../enums/forgot_password_status.dart';

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.status = ForgotPasswordStatus.initial,
    this.username = '',
    this.isUsernameValid = false,
    this.errorMessage,
    this.otpForNavigation,
    this.successMessage,
  });

  final ForgotPasswordStatus status;
  final String username;
  final bool isUsernameValid;
  final String? errorMessage;
  final String? otpForNavigation;
  final String? successMessage;

  bool get canSubmit => isUsernameValid;

  @override
  List<Object?> get props => [
        status,
        username,
        isUsernameValid,
        errorMessage,
        otpForNavigation,
        successMessage,
      ];

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? username,
    bool? isUsernameValid,
    String? errorMessage,
    String? otpForNavigation,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearNavigationPayload = false,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      username: username ?? this.username,
      isUsernameValid: isUsernameValid ?? this.isUsernameValid,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      otpForNavigation:
          clearNavigationPayload ? null : otpForNavigation ?? this.otpForNavigation,
      successMessage:
          clearNavigationPayload ? null : successMessage ?? this.successMessage,
    );
  }
}
