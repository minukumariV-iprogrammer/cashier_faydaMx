import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/errors/exceptions.dart';
import '../../data/app_init_repository.dart';
import '../../domain/entities/app_init_entity.dart';

enum AppInitLoadStatus { initial, loading, success, failure }

class AppInitState extends Equatable {
  const AppInitState({
    this.status = AppInitLoadStatus.initial,
    this.data,
    this.httpStatusCode,
  });

  final AppInitLoadStatus status;
  final AppInitEntity? data;

  /// Set when [status] is [AppInitLoadStatus.failure] (e.g. 503 → maintenance).
  final int? httpStatusCode;

  @override
  List<Object?> get props => [status, data, httpStatusCode];
}

/// Fetches app version / maintenance status for splash (all environments).
class AppInitCubit extends Cubit<AppInitState> {
  AppInitCubit(this._repository) : super(const AppInitState());

  final AppInitRepository _repository;

  Future<AppInitEntity?> getAppInitData() async {
    emit(const AppInitState(status: AppInitLoadStatus.loading));
    try {
      final entity = await _repository.getAppInit();
      emit(AppInitState(status: AppInitLoadStatus.success, data: entity));
      return entity;
    } on ServerException catch (e) {
      emit(AppInitState(
        status: AppInitLoadStatus.failure,
        httpStatusCode: e.statusCode,
      ));
      return null;
    } catch (_) {
      emit(const AppInitState(status: AppInitLoadStatus.failure));
      return null;
    }
  }
}
