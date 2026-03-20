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

  FlavorConfig._internal({
    required this.flavor,
    required this.apiBaseUrl,
    required this.addEncryption,
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
          );
          break;
        case Flavor.stage:
          _instance = FlavorConfig._internal(
            flavor: Flavor.stage,
            apiBaseUrl: 'https://stage-api.faydamx.com',
            addEncryption: true,
          );
          break;
        case Flavor.prod:
          _instance = FlavorConfig._internal(
            flavor: Flavor.prod,
            apiBaseUrl: 'https://api.faydamx.com',
            addEncryption: true,
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

  static bool isDevelopment() => _instance?.flavor == Flavor.dev;
  static bool isStaging() => _instance?.flavor == Flavor.stage;
  static bool isProduction() => _instance?.flavor == Flavor.prod;
  static bool isEncryptionEnabled() => _instance?.addEncryption ?? false;
}
