import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/network/handle_api_call.dart';
import '../../Cashier/data/api/cashier_api_service.dart';
import '../domain/entities/app_init_entity.dart';
import 'models/app_init_models.dart';

abstract class AppInitRepository {
  Future<AppInitEntity> getAppInit();
}

class AppInitRepositoryImpl implements AppInitRepository {
  AppInitRepositoryImpl(this._api);

  final ApiService _api;

  @override
  Future<AppInitEntity> getAppInit() async {
    final info = await PackageInfo.fromPlatform();
    final platform = Platform.isAndroid ? 'cashier_app_android' : 'cashier_app_ios';
    final request = AppInitRequestModel(
      platform: platform,
      currentVersion: info.version,
    );
    final model = await handleApiCall(
      _api.getAppInit(request),
    );
    return model.toEntity();
  }
}
