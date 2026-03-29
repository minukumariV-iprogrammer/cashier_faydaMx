import 'dart:io';

import '../../../../core/constants/flavor_constants.dart';
import '../../../../core/push/fcm_service.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/cashier_entity.dart';
import '../../domain/entities/forgot_password_result.dart';
import '../../domain/repositories/cashier_auth_repository.dart';
import '../datasource/cashier_auth_remote_ds.dart';
import '../models/cashier_login_request_model.dart';

class CashierAuthRepositoryImpl implements CashierAuthRepository {
  CashierAuthRepositoryImpl(this.remoteDataSource);

  final CashierAuthRemoteDataSource remoteDataSource;

  @override
  Future<CashierAuthEntity> login({
    required String username,
    required String password,
  }) async {
    final fcmToken = await sl<FcmService>().getToken();
    final request = CashierLoginRequestModel(
      username: username,
      password: password,
      portal: 'merchant',
      projectId: FlavorConfig.instance.loginProjectId,
      fcmToken: fcmToken ?? '',
      platform: Platform.isAndroid ? 'android' : 'ios',
    );

    final response = await remoteDataSource.login(request);

    final profile = response.data.profile;
    final stores = profile.storeList;
    final storeId = stores.isNotEmpty ? stores.first.id : '';

    var cityId = '';
    if (stores.isNotEmpty && stores.first.cityId.isNotEmpty) {
      cityId = stores.first.cityId;
    } else if (profile.userRoles.isNotEmpty) {
      cityId = profile.userRoles.first.cityId;
    }

    final roleId = profile.userRoles.isNotEmpty
        ? profile.userRoles.first.roleId
        : 0;

    var locationLabel = '';
    if (profile.userRoles.isNotEmpty) {
      final role = profile.userRoles.first;
      final cn = role.cityName;
      final sl = role.stateLabel;
      if (cn.isNotEmpty && sl.isNotEmpty) {
        locationLabel = '$cn, $sl';
      } else if (cn.isNotEmpty) {
        locationLabel = cn;
      }
    }

    // `profile.full_name` / `fullName` from login `data.profile`
    final rawFullName = profile.fullName.trim();
    final displayName =
        rawFullName.isNotEmpty ? rawFullName : profile.username.trim();

    return CashierAuthEntity(
      accessToken: response.data.accessToken,
      refreshToken: response.data.refreshToken,
      userId: profile.userId,
      username: profile.username,
      role: profile.userRoles.first.name,
      storeId: storeId,
      cityId: cityId,
      fullName: displayName,
      email: profile.email.trim(),
      phone: profile.phone.trim(),
      locationLabel: locationLabel,
      roleId: roleId,
    );
  }

  @override
  Future<ForgotPasswordResult> forgotPassword({
    required String username,
  }) async {
    final response = await remoteDataSource.forgotPassword(username: username);
    final otp = response.data?.otp ?? '';
    return ForgotPasswordResult(
      otp: otp,
      message: response.message ?? '',
    );
  }

  @override
  Future<void> verifyForgotPasswordOtp({
    required String username,
    required String otp,
    required String newPassword,
  }) async {
    await remoteDataSource.verifyForgotPasswordOtp(
      username: username,
      otp: otp,
      newPassword: newPassword,
    );
  }
}

