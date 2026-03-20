import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Design size for [ScreenUtilInit] (e.g. Figma 375x812).
const Size kDesignSize = Size(375, 812);

/// Screen utils for responsive sizing (FaydaMX-style).
/// Use [ScreenUtilInit] at app root with [kDesignSize], then use .w, .h, .sp on num:
/// ```dart
/// Container(width: 24.w, height: 16.h)
/// Text('Hello', style: TextStyle(fontSize: 16.sp))
/// ```
/// This file re-exports helpers; the package provides the extensions.
abstract class ScreenUtils {
  ScreenUtils._();

  static double get screenWidth => 1.sw;
  static double get screenHeight => 1.sh;
  static double get statusBarHeight => ScreenUtil().statusBarHeight;
  static double get bottomBarHeight => ScreenUtil().bottomBarHeight;
}
