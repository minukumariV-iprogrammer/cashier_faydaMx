import '../constants/flavor_constants.dart';

/// Builds full URL for store images (`storeLogo`, etc.) from API-relative paths.
String storeAssetUrl(String? relativePath) {
  if (relativePath == null || relativePath.isEmpty) return '';
  final base = FlavorConfig.s3BucketPathWithoutSlash;
  final path =
      relativePath.startsWith('/') ? relativePath : '/$relativePath';
  return '$base$path';
}
