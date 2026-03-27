import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class ScreenWrapper extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final SystemUiOverlayStyle? systemUiOverlayStyle;

  /// Determines if the Scaffold body should extend behind the AppBar.
  /// Defaults to `true` for a seamless edge-to-edge experience.
  final bool extendBodyBehindAppBar;

  /// Determines if the Scaffold body should extend behind the BottomNavigationBar.
  /// Defaults to `true` for a seamless edge-to-edge experience.
  final bool extendBody;

  const ScreenWrapper({
    required this.child, super.key,
    this.backgroundColor,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.systemUiOverlayStyle,
    this.extendBodyBehindAppBar = true,
    this.extendBody = true,
  });

  Brightness _getBrightnessForColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Brightness.light // Dark background -> light icons
        : Brightness.dark; // Light background -> dark icons
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    // Determine the colors that will be behind the system bars
    final finalAppBarColor =  currentTheme.appBarTheme.backgroundColor ?? currentTheme.primaryColor;

    // For the bottom bar, the color behind it will be the scaffold's background
    final finalScaffoldColor = backgroundColor ?? currentTheme.scaffoldBackgroundColor;

    final defaultStyle = SystemUiOverlayStyle(
      // --- Status Bar ---
      // Transparent to let the AppBar color show through.
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: _getBrightnessForColor(finalAppBarColor),
      statusBarBrightness: _getBrightnessForColor(finalAppBarColor) == Brightness.dark
          ? Brightness.light
          : Brightness.dark,

      // --- System Navigation Bar (Android bottom bar / iOS home indicator area) ---
      // Transparent to let the body content show through.
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      // The brightness of the navigation bar icons (e.g., the 3 buttons on Android).
      systemNavigationBarIconBrightness: _getBrightnessForColor(finalScaffoldColor),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle ?? defaultStyle,
      child: Scaffold(
        backgroundColor: finalScaffoldColor,
        appBar: appBar,
        body: Column(
          children: [
            Container(
              height: MediaQuery.viewPaddingOf(context).top,color: currentTheme.primaryColorDark,
            ),
            Expanded(child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom),
              child: child,
            )),
          ],
        ),
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        extendBody: extendBody,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
