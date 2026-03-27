import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shown when maintenance mode is active or API returns 503.
class DowntimeScreen extends StatelessWidget {
  const DowntimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.build_circle_outlined,
                size: 72.r,
                color: const Color(0xFF637487),
              ),
              SizedBox(height: 24.h),
              Text(
                'We\'ll be back soon',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C252E),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'FaydaMX Central is temporarily unavailable due to maintenance. '
                'Please try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.4,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                height: 48.h,
                child: OutlinedButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: Text(
                    'Close app',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
