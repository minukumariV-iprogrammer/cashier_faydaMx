
import 'package:equatable/equatable.dart';

import '../enums/cashier_login_status.dart';

class CashierLoginState extends Equatable{




  final CashierLoginStatus status;
  final String username;
  final String password;
  final bool isUsernameValid;
  final bool isPasswordValid;
  final String? errorMessage;



  const CashierLoginState({
    this.status = CashierLoginStatus.initial,
    this.username = '',
    this.password = '',
    this.isUsernameValid = false,
    this.isPasswordValid = false,
    this.errorMessage,
  });


  @override
  List<Object?> get props => [
    status,
    username,
    password,
    isUsernameValid,
    isPasswordValid,
    errorMessage,
  ];



  CashierLoginState copyWith({
    CashierLoginStatus? status,
    String? username,
    String? password,
    bool? isUsernameValid,
    bool? isPasswordValid,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CashierLoginState(
      status: status ?? this.status,
      username: username ?? this.username,
      password: password ?? this.password,
      isUsernameValid: isUsernameValid ?? this.isUsernameValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }



  bool get isSubmissionAllowed =>
      isUsernameValid && isPasswordValid;

}