import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/constants/flavor_constants.dart';
import 'core/firebase/firebase_bootstrap.dart';

/// Stage entry point. Select "main_stage.dart" in run configuration.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.init(flavor: Flavor.stage);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await ensureFirebaseInitialized();
  runCashierApp();
}
