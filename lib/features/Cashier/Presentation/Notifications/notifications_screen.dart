import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/notifications/notification_inbox_store.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../../../di/injection.dart';

/// Lists FCM-driven notifications; empty state matches product design.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

Future<void> _deleteAfterSwipe(BuildContext context, String id) async {
  await sl<NotificationInboxStore>().deleteById(id);
  if (context.mounted) {
    ToastUtils.showSuccessToast(message: 'Notification deleted');
  }
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final store = sl<NotificationInboxStore>();
      await store.reloadFromStorage();
      await store.markAllRead();
    });
  }

  Future<void> _confirmDeleteAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all notifications?'),
        content: const Text(
          'This will remove every notification from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete all'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await sl<NotificationInboxStore>().clear();
    if (!mounted) return;
    ToastUtils.showSuccessToast(message: 'All notifications deleted');
  }

  @override
  Widget build(BuildContext context) {
    final store = sl<NotificationInboxStore>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF101828), size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF000000),
          ),
        ),
        centerTitle: false,
        actions: [
          ListenableBuilder(
            listenable: store,
            builder: (context, _) {
              if (store.notifications.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: 'Delete all',
                icon: Icon(
                  Icons.delete_sweep,
                  color: const Color(0xFF0040B8),
                  size: 24.sp,
                ),
                onPressed: _confirmDeleteAll,
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final items = store.notifications;
          if (items.isEmpty) {
            return const _EmptyNotificationsBody();
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final n = items[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DismissibleNotificationTile(notification: n),
                  if (index < items.length - 1)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: const _DashedDivider(),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DismissibleNotificationTile extends StatelessWidget {
  const _DismissibleNotificationTile({required this.notification});

  final AppInboxNotification notification;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<String>('inbox_${notification.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.redAccent,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        alignment: Alignment.centerLeft,
        child: Icon(Icons.delete_sweep, color: Colors.white, size: 28.sp),
      ),
      secondaryBackground: Container(
        color: Colors.redAccent,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete_sweep, color: Colors.white, size: 28.sp),
      ),
      onDismissed: (direction) {
        unawaited(_deleteAfterSwipe(context, notification.id));
      },
      child: _NotificationTile(notification: notification),
    );
  }
}

class _EmptyNotificationsBody extends StatelessWidget {
  const _EmptyNotificationsBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 88.sp,
              color: const Color(0xFF9E9E9E),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Notifications',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF000000),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "We'll let you know when there will be something to update you.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                height: 1.35,
                color: const Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppInboxNotification notification;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ),
                Text(
                  _formatDateTime(notification.createdAtMs),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              notification.subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                height: 1.3,
                color: const Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  final now = DateTime.now();
  final diff = now.difference(d);
  if (diff.inSeconds < 60) {
    return 'just now';
  }
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final h24 = d.hour;
  final h12 = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
  final amPm = h24 >= 12 ? 'PM' : 'AM';
  final min = d.minute.toString().padLeft(2, '0');
  return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year} • $h12:$min $amPm';
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedLinePainter(color: const Color(0xFFE0E0E0)),
      size: Size(double.infinity, 1.h),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const gap = 4.0;
    var x = 0.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
