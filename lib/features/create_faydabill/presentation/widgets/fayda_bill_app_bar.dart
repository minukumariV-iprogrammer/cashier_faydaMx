import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// App bar for Create Fayda Bill — white bar, menu + title (Figma reference).
class FaydaBillAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FaydaBillAppBar({
    super.key,
    this.title = 'FaydaBill',
    this.onMenuPressed,
  });

  final String title;
  final VoidCallback? onMenuPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 26),
        color: Colors.black54,
        onPressed: onMenuPressed ?? () {},
        tooltip: 'Menu',
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Colors.black,
          letterSpacing: -0.2,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: const Color(0xFFE8E8E8),
        ),
      ),
    );
  }
}

/// Dark status bar (navy) + light icons — use above white app bar + white body.
class FaydaBillStatusBar extends StatelessWidget {
  const FaydaBillStatusBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: child,
    );
  }
}
