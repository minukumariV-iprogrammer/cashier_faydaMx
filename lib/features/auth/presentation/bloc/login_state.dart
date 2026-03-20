part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  const LoginSuccess(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

class LoginFailure extends LoginState {
  const LoginFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
