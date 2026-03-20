

import 'package:equatable/equatable.dart';

abstract class CashierLoginEvent extends Equatable{

  const CashierLoginEvent();

  @override

  List<Object?> get props => [];
}




class LoginButtonPressed extends CashierLoginEvent{}







class UsernameChanged extends CashierLoginEvent {
  final String username;
  const UsernameChanged(this.username);

  @override
  List<Object?> get props => [username];
}



class PasswordChanged extends CashierLoginEvent {
  final String password;
  const PasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}


class CashierLoginStatusReset extends CashierLoginEvent {}


