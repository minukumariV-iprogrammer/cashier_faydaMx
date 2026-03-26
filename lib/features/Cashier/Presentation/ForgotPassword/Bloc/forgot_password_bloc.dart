import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/errors/exceptions.dart';
import '../../../domain/usecases/forgot_password_usecase.dart';
import '../enums/forgot_password_status.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc({required this.forgotPasswordUseCase})
      : super(const ForgotPasswordState()) {
    on<ForgotPasswordUsernameChanged>(_onUsernameChanged);
    on<ForgotPasswordSendPressed>(_onSendPressed);
    on<ForgotPasswordReset>(_onReset);
  }

  final ForgotPasswordUseCase forgotPasswordUseCase;

  void _onReset(
    ForgotPasswordReset event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(const ForgotPasswordState());
  }

  void _onUsernameChanged(
    ForgotPasswordUsernameChanged event,
    Emitter<ForgotPasswordState> emit,
  ) {
    final trimmed = event.username.trim();
    emit(
      state.copyWith(
        username: event.username,
        isUsernameValid: trimmed.isNotEmpty,
        clearErrorMessage: true,
        clearNavigationPayload: true,
        status: ForgotPasswordStatus.initial,
      ),
    );
  }

  Future<void> _onSendPressed(
    ForgotPasswordSendPressed event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    if (!state.canSubmit) {
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          errorMessage: 'Please enter your username',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ForgotPasswordStatus.loading,
        clearErrorMessage: true,
        clearNavigationPayload: true,
      ),
    );

    try {
      final result = await forgotPasswordUseCase(username: state.username.trim());
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.success,
          otpForNavigation: result.otp,
          successMessage: result.message,
        ),
      );
    } on InputValidationException catch (e) {
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          errorMessage: e.message ?? e.toString(),
        ),
      );
    } on NetworkException {
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          errorMessage: 'No internet connection',
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          errorMessage: 'Something went wrong',
        ),
      );
    }
  }
}
