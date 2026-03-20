part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({required this.userName, required this.password});

  final String userName;
  final String password;

  @override
  List<Object?> get props => [userName, password];
}
