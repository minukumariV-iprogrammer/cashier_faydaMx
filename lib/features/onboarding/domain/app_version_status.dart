/// Backend `data.status` values for app-version / app-init.
abstract class AppVersionStatus {
  AppVersionStatus._();

  static const String maintenanceMode = 'MAINTENANCE_MODE';
  static const String forceUpdate = 'FORCE_UPDATE';
  static const String softUpdate = 'SOFT_UPDATE';
}

