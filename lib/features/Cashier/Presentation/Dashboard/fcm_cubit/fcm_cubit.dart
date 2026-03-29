import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/push/fcm_service.dart';

/// Mirrors legacy FaydaMX flow: sync FCM with backend on token rotation and when dashboard opens.
class FcmCubit extends Cubit<FcmState> {
  FcmCubit(this._fcmService) : super(const FcmInitial());

  final FcmService _fcmService;

  /// Sync current Firebase token to BE (logged-in only). Safe to call on every dashboard open / resume.
  Future<void> listenForTokenChanges() async {
    await _fcmService.syncFromDashboard();
  }
}

abstract class FcmState extends Equatable {
  const FcmState();

  @override
  List<Object?> get props => [];
}

class FcmInitial extends FcmState {
  const FcmInitial();
}
