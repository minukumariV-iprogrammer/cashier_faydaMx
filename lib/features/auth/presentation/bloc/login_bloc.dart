import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._loginUseCase) : super(LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  final LoginUseCase _loginUseCase;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    final result = await _loginUseCase(
      userName: event.userName,
      password: event.password,
    );
    result.fold(
      (failure) => emit(LoginFailure(failure.message ?? 'Login failed')),
      (user) => emit(LoginSuccess(user)),
    );
  }
}
