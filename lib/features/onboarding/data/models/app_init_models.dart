import '../../domain/entities/app_init_entity.dart';

/// POST `/api/masters/app-version` request body.
class AppInitRequestModel {
  const AppInitRequestModel({
    required this.platform,
    required this.currentVersion,
  });

  final String platform;
  final String currentVersion;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'platform': platform,
        'currentVersion': currentVersion,
      };
}

class AppInitResponseModel {
  const AppInitResponseModel({
    required this.success,
    this.data,
  });

  final bool success;
  final AppInitDataModel? data;

  factory AppInitResponseModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? dataJson;
    final raw = json['data'];
    if (raw is Map<String, dynamic>) {
      dataJson = raw;
    }
    return AppInitResponseModel(
      success: json['success'] as bool? ?? false,
      data: dataJson != null ? AppInitDataModel.fromJson(dataJson) : null,
    );
  }

  AppInitEntity toEntity() {
    final d = data;
    if (d == null) {
      return const AppInitEntity(statusRaw: '');
    }
    return AppInitEntity(
      statusRaw: d.status,
      minimumSupportedVersion: d.minimumSupportedVersion,
      latestVersion: d.latestVersion,
      termAndConditionsUrl: d.termAndConditionsUrl,
      storeUrl: d.storeUrl,
        softUpdateWindow:d.softUpdateWindow,
    );
  }
}

class AppInitDataModel {
  const AppInitDataModel({
    required this.status,
    this.minimumSupportedVersion,
    this.latestVersion,
    this.termAndConditionsUrl,
    this.storeUrl,
    this.softUpdateWindow,
  });

  final String status;
  final String? minimumSupportedVersion;
  final String? latestVersion;
  final String? termAndConditionsUrl;
  final String? storeUrl;
  final String? softUpdateWindow;

  factory AppInitDataModel.fromJson(Map<String, dynamic> json) {
    return AppInitDataModel(
      status: json['status']?.toString() ?? '',
      minimumSupportedVersion: json['minimumSupportedVersion']?.toString(),
      latestVersion: json['latestVersion']?.toString(),
      termAndConditionsUrl: json['termAndConditionsUrl']?.toString(),
      storeUrl: json['storeUrl']?.toString(),
        softUpdateWindow : json['softUpdateWindow'],
    );
  }
}
