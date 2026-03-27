import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/navigation/app_routers.dart';
import '../../../../core/network/token_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/screen_wrapper.dart';
import '../../../../di/injection.dart';

class UpdateScreen extends StatefulWidget {
  final bool isForceUpdate;
  final String storeUrl;
  final bool skipAllowed;
  final String window;
  const UpdateScreen({
    super.key,
    required this.isForceUpdate,
    required this.storeUrl,
    required this.skipAllowed,
    required this.window
  });

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  @override
  void initState() {
    super.initState();
    // _markUserOnUpdateScreen();
  }

  // Future<void> _markUserOnUpdateScreen() async {
  //   final saveData = sl<SaveSecureDataUseCase>();
  //
  //   await saveData(
  //     key: SharedPreferenceKeys.softUpdateLastSkipped,
  //     value: "0", // 🔥 means user has NOT skipped yet
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      child: Stack(
        children: [

          //Full Background Image
          Positioned.fill(
            child:
            // Image.asset(
            //   'assets/images/forceupdtebanner.webp',
            //   fit: BoxFit.cover,
            // ),
            Image.asset('assets/images/splash_bg.webp', fit: BoxFit.cover),
          ),

          // Logo Circle
          Positioned(
            top: 160.h,
            left: 0,
            right: 0,
            child: Center(
              child:
              Container(
                width: 200.w,
                height: 200.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Padding(
                    padding: EdgeInsets.all(30.w),
                    child: Image.asset(
                      'assets/images/rocket.webp',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          //Title
          Positioned(
            top: 392.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                widget.isForceUpdate ? "Get the Best Experience": "A Better Version is Here",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),


          // Subtitle
          Positioned(
            top: 439.h,
            left: 17.w,
            right: 17.w,
            child: Text(
              widget.isForceUpdate
                  ? "Update to the latest version to track your coins, coupons, and orders seamlessly."
                  :
              "A newer version of Fayda MX is available with enhancements and stability updates.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),

          // Update Button
          Positioned(
            top: 603.h,
            left: 17.w,
            right: 17.w,
            child: SizedBox(
              width: 320.w,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () async {
                  await launchUrl(
                    Uri.parse(widget.storeUrl),
                    mode: LaunchMode.externalApplication,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                ),
                child: Center( // 🔥 force perfect centering
                  child: Text(
                    "Update Now",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.2, // 🔥 prevent clipping
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Skip for Now
          if (!widget.isForceUpdate)
            Positioned(
              top: 659.h,
              left: 0,
              right: 0,
              child: TextButton(
                onPressed: () async {
                  // final saveData = sl<SaveSecureDataUseCase>();
                  // final now = DateTime.now().millisecondsSinceEpoch;
                  // await saveData(
                  //   key: SharedPreferenceKeys.softUpdateLastSkipped,
                  //   value: now.toString(),
                  // );
                  // await saveData(
                  //   key: "soft_update_last_window",
                  //   value: widget.window.toString(),
                  // );
                  final tokenService = sl<TokenService>();
                  final accessToken = await tokenService.getAccessToken();

                  if (accessToken != null && accessToken.isNotEmpty) {
                    context.replace(AppRoutes.cashierDashboard);
                  } else {
                    context.replace(AppRoutes.cashierLoginScreen);
                  }
                },
                child:  Text(
                  "Skip for Now",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.grey,
                    decorationThickness: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}