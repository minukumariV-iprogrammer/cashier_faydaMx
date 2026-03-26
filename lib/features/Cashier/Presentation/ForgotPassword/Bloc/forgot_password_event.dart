import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordUsernameChanged extends ForgotPasswordEvent {
  const ForgotPasswordUsernameChanged(this.username);

  final String username;

  @override
  List<Object?> get props => [username];
}

class ForgotPasswordSendPressed extends ForgotPasswordEvent {
  const ForgotPasswordSendPressed();
}

/// Clears form state when returning from the reset-password flow.
class ForgotPasswordReset extends ForgotPasswordEvent {
  const ForgotPasswordReset();
}
