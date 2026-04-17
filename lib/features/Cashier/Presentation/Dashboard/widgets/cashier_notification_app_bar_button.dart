import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/navigation/app_routers.dart';
import '../../../../../core/notifications/notification_inbox_store.dart';
import '../../../../../di/injection.dart';

/// Bell + unread badge; opens [AppRoutes.notifications].
class CashierNotificationAppBarButton extends StatelessWidget {
  const CashierNotificationAppBarButton({super.key});

  @override
  Widget build(BuildContext context) {
    final store = sl<NotificationInboxStore>();
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final n = store.unreadCount;
        return Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(AppRoutes.notifications),
              borderRadius: BorderRadius.circular(24.r),
              child: SizedBox(
                width: 40.w,
                height: 40.w,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 26.sp,
                      color: const Color(0xFF101828),
                    ),
                    if (n > 0)
                      Positioned(
                        right: 2.w,
                        top: 4.h,
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: 16.r,
                            minHeight: 16.r,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: n > 9 ? 4.w : 5.w,
                            vertical: 2.h,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE53935),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            n > 99 ? '99+' : '$n',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
