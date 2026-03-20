import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/constants/flavor_constants.dart';

/// Production entry point. Select "main_prod.dart" in run configuration.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.init(flavor: Flavor.prod);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runCashierApp();
}
