import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/errors/exceptions.dart';
import '../../../../../core/network/token_service.dart';
import '../../../domain/usecases/get_store_summary_usecase.dart';
import 'cashier_dashboard_event.dart';
import 'cashier_dashboard_state.dart';
import 'cashier_dashboard_status.dart';

class CashierDashboardBloc
    extends Bloc<CashierDashboardEvent, CashierDashboardState> {
  CashierDashboardBloc({
    required GetStoreSummaryUseCase getStoreSummaryUseCase,
    required TokenService tokenService,
  })  : _getStoreSummaryUseCase = getStoreSummaryUseCase,
        _tokenService = tokenService,
        super(const CashierDashboardState()) {
    on<CashierDashboardLoadRequested>(_onLoadRequested);
  }

  final GetStoreSummaryUseCase _getStoreSummaryUseCase;
  final TokenService _tokenService;

  Future<void> _onLoadRequested(
    CashierDashboardLoadRequested event,
    Emitter<CashierDashboardState> emit,
  ) async {
    emit(state.copyWith(
      status: CashierDashboardStatus.loading,
      clearErrorMessage: true,
    ));

    final storeId = await _tokenService.getStoreId();
    if (storeId == null || storeId.isEmpty) {
      emit(state.copyWith(
        status: CashierDashboardStatus.failure,
        errorMessage: 'No store assigned. Please log in again.',
      ));
      return;
    }

    try {
      final summary =
          await _getStoreSummaryUseCase(storeId: storeId);
      emit(state.copyWith(
        status: CashierDashboardStatus.success,
        summary: summary,
      ));
    } on InputValidationException catch (e) {
      emit(state.copyWith(
        status: CashierDashboardStatus.failure,
        errorMessage: e.message ?? e.toString(),
      ));
    } on UnauthorizedException catch (e) {
      emit(state.copyWith(
        status: CashierDashboardStatus.failure,
        errorMessage: e.message ?? 'Unauthorized',
      ));
    } on NetworkException catch (e) {
      emit(state.copyWith(
        status: CashierDashboardStatus.failure,
        errorMessage: e.message ?? 'No internet connection',
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        status: CashierDashboardStatus.failure,
        errorMessage: e.message ?? 'Something went wrong',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CashierDashboardStatus.failure,
        errorMessage: 'Something went wrong',
      ));
    }
  }
}
