/// Normalized app-init / app-version payload for splash routing.
class AppInitEntity {
  const AppInitEntity({
    required this.statusRaw,
    this.minimumSupportedVersion,
    this.latestVersion,
    this.termAndConditionsUrl,
    this.storeUrl,
    this.softUpdateWindow
  });

  final String statusRaw;
  final String? minimumSupportedVersion;
  final String? latestVersion;
  final String? termAndConditionsUrl;
  final String? storeUrl;
  final String? softUpdateWindow;
}
