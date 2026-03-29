import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/errors/exceptions.dart';
import '../../../../../core/network/token_service.dart';
import '../../../../../core/session/session_timeout_service.dart';
import '../../../domain/entities/store_full_entity.dart';
import '../../../domain/entities/store_summary_entity.dart';
import '../../../domain/usecases/get_store_detail_usecase.dart';
import '../../../domain/usecases/get_store_summary_usecase.dart';
import 'cashier_dashboard_event.dart';
import 'cashier_dashboard_state.dart';
import 'cashier_dashboard_status.dart';

class CashierDashboardBloc
    extends Bloc<CashierDashboardEvent, CashierDashboardState> {
  CashierDashboardBloc({
    required GetStoreSummaryUseCase getStoreSummaryUseCase,
    required GetStoreDetailUseCase getStoreDetailUseCase,
    required TokenService tokenService,
    required SessionTimeoutService sessionTimeoutService,
  })  : _getStoreSummaryUseCase = getStoreSummaryUseCase,
        _getStoreDetailUseCase = getStoreDetailUseCase,
        _tokenService = tokenService,
        _sessionTimeoutService = sessionTimeoutService,
        super(const CashierDashboardState()) {
    on<CashierDashboardLoadRequested>(_onLoadRequested);
  }

  final GetStoreSummaryUseCase _getStoreSummaryUseCase;
  final GetStoreDetailUseCase _getStoreDetailUseCase;
  final TokenService _tokenService;
  final SessionTimeoutService _sessionTimeoutService;

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
      final results = await Future.wait([
        _getStoreSummaryUseCase(storeId: storeId),
        _getStoreDetailUseCase(storeId: storeId),
      ]);
      final storeFull = results[1] as StoreFullEntity;
      await _sessionTimeoutService.configureAndStart(
        storeFull.sessionTimeoutMinutes,
      );
      emit(state.copyWith(
        status: CashierDashboardStatus.success,
        summary: results[0] as StoreSummaryEntity,
        storeDetail: storeFull.detail,
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
