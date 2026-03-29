/// Flavor enum and config (dev, stage, prod). Init from main_dev.dart, main_stage.dart, main_prod.dart.
enum Flavor {
  dev,
  stage,
  prod,
}

class FlavorConfig {
  final Flavor flavor;
  final String apiBaseUrl;
  final bool addEncryption;

  /// Sent on cashier login as `projectId` (backend / CMS project key).
  final String loginProjectId;

  FlavorConfig._internal({
    required this.flavor,
    required this.apiBaseUrl,
    required this.addEncryption,
    required this.loginProjectId,
  });

  static FlavorConfig? _instance;

  static void init({required Flavor flavor}) {
    if (_instance == null) {
      switch (flavor) {
        case Flavor.dev:
          _instance = FlavorConfig._internal(
            flavor: Flavor.dev,
            apiBaseUrl: 'https://fmx-api.iprotec.in',
            addEncryption: false,
            loginProjectId: 'cashier-debug',
          );
          break;
        case Flavor.stage:
          _instance = FlavorConfig._internal(
            flavor: Flavor.stage,
            apiBaseUrl: 'https://stage-api.faydamx.com',
            addEncryption: true,
            loginProjectId: 'cashier-staging',
          );
          break;
        case Flavor.prod:
          _instance = FlavorConfig._internal(
            flavor: Flavor.prod,
            apiBaseUrl: 'https://api.faydamx.com',
            addEncryption: true,
            loginProjectId: 'cashier-prod',
          );
          break;
      }
    }
  }

  static FlavorConfig get instance {
    if (_instance == null) {
      throw Exception(
        'FlavorConfig not initialized. Call FlavorConfig.init() first.',
      );
    }
    return _instance!;
  }

  /// True after [init] has been called (dev, stage, or prod).
  static bool get isInitialized => _instance != null;

  static bool isDevelopment() => _instance?.flavor == Flavor.dev;
  static bool isStaging() => _instance?.flavor == Flavor.stage;
  static bool isProduction() => _instance?.flavor == Flavor.prod;
  static bool isEncryptionEnabled() => _instance?.addEncryption ?? false;

  /// CDN base for `storeLogo` paths (no trailing slash).
  static String get s3BucketPathWithoutSlash =>
      isProduction()
          ? 'https://assets.faydamx.com'
          : 'https://d2vrc2fo4lveiz.cloudfront.net';
}
