import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routers.dart';
import '../../../../core/navigation/dashboard_refresh_notifier.dart';
import '../../../../core/network/errors/exceptions.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../../../core/notifications/notification_inbox_store.dart';
import '../../../../core/push/in_app_payment_popup_queue.dart';
import '../../../../core/push/local_notification_service.dart';
import '../../../../di/injection.dart';
import '../../../../core/network/season_holder.dart';
import '../../../../core/network/tenant_holder.dart';
import '../../../../core/network/token_service.dart';
import '../../../../core/session/session_timeout_service.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/cashier_auth_repository.dart';
import 'Bloc/cashier_dashboard_bloc.dart';
import 'Bloc/cashier_dashboard_event.dart';
import 'Bloc/cashier_dashboard_state.dart';
import 'Bloc/cashier_dashboard_status.dart';
import 'widgets/cashier_dashboard_shimmer.dart';
import 'widgets/cashier_notification_app_bar_button.dart';
import 'widgets/cashier_profile_app_bar_button.dart';
import 'widgets/cashier_profile_drawer.dart';
import 'widgets/cashier_store_header_pill.dart';
import 'fcm_cubit/fcm_cubit.dart';

class cashierDashBoardScreen extends StatefulWidget {
  const cashierDashBoardScreen({super.key});

  @override
  State<cashierDashBoardScreen> createState() => _cashierDashBoardScreenState();
}

class _cashierDashBoardScreenState extends State<cashierDashBoardScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _syncFcmToken() {
    if (!mounted) return;
    context.read<FcmCubit>().listenForTokenChanges();
  }

  void _onDashboardRefreshRequested() {
    if (!mounted) return;
    context.read<CashierDashboardBloc>().add(
          const CashierDashboardLoadRequested(),
        );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    dashboardRefreshNotifier.addListener(_onDashboardRefreshRequested);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFcmToken());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    dashboardRefreshNotifier.removeListener(_onDashboardRefreshRequested);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncFcmToken();
    }
  }

  void _onUserIconTap() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Future<void> _onLogoutFromDrawer() async {
    _scaffoldKey.currentState?.closeEndDrawer();
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? All your data will be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final refresh = await sl<TokenService>().getRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      ToastUtils.showErrorToast(
        message: 'Unable to logout: missing refresh token.',
      );
      return;
    }

    try {
      await sl<CashierAuthRepository>().logoutRemote(
        refreshToken: refresh,
        logoutType: 'manual_logout',
      );
    } on NetworkException catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(
        message: e.message ?? 'No internet connection',
      );
      return;
    } on UnauthorizedException catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(
        message: e.message ?? 'Logout failed',
      );
      return;
    } on ServerException catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(
        message: e.message ?? 'Logout failed',
      );
      return;
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(message: 'Logout failed');
      return;
    }

    if (!mounted) return;

    sl<SessionTimeoutService>().cancel();
    await sl<TokenService>().clearTokens();
    await sl<NotificationInboxStore>().clear();
    await sl<PaymentPopupQueueStore>().clearAll();
    await sl<LocalNotificationService>().cancelAll();
    sl<TenantHolder>().clear();
    sl<SeasonHolder>().clear();
    await sl<AuthRepository>().logout();
    if (!mounted) return;
    context.go(AppRoutes.cashierLoginScreen);
  }

  Widget _buildStoreHeaderTitle(CashierDashboardState state) {
    final loading = state.status == CashierDashboardStatus.loading;
    final store = state.storeDetail;

    if (loading && store == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    // color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.swap_vert, size: 22, color: Colors.grey.shade600),
              ],
            ),
          ),
        ],
      );
    }

    if (store != null) {
      return CashierStoreHeaderPill(store: store);
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CashierDashboardBloc, CashierDashboardState>(
      listenWhen: (previous, current) =>
          current.status == CashierDashboardStatus.failure &&
          current.errorMessage != null &&
          current.errorMessage!.isNotEmpty,
      listener: (context, state) {
        ToastUtils.showErrorToast(message: state.errorMessage!);
      },
      builder: (context, state) {
        final summary = state.summary;
        final loading = state.status == CashierDashboardStatus.loading;
        final showInitialLoader = loading && summary == null;

        return Scaffold(
          key: _scaffoldKey,
          endDrawer: CashierProfileDrawer(
            onClose: () => _scaffoldKey.currentState?.closeEndDrawer(),
            onLogoutPressed: _onLogoutFromDrawer,
          ),
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            centerTitle: false,
            titleSpacing: 16.w,
            title: _buildStoreHeaderTitle(state),
            actions: [
              const CashierNotificationAppBarButton(),
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: CashierProfileAppBarButton(onTap: _onUserIconTap),
              ),
            ],
          ),
          body: showInitialLoader
              ? const CashierDashboardShimmer()
              : Container(
              child: _buildBody(context, state, loading)),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context,
      CashierDashboardState state,
      bool loading,
      ) {
    final s = state.summary;
    final gift = s?.giftVoucherBalance.toString() ?? '—';
    final coins = s?.coinBalance.toString() ?? '—';
    final tx = s?.totalTransactionsToday.toString() ?? '—';
    final coinsIssued = s?.coinsIssuedToday.toString() ?? '—';
    final coupons = s?.couponsIssuedToday.toString() ?? '—';

    return Stack(
      children: [
        Column(
          children: [
            SizedBox(height: 16.h),

            /// 🔹 GREY CONTAINER (only section background)
            Container(
              width: double.infinity,
              // margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100, // ✅ GREY BACKGROUND
                // borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  /// 🔹 TOP WHITE CARD (2 ITEMS)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white, // ✅ WHITE CARD
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _item(
                            title: 'Gift Voucher Balance',
                            value: gift,
                          ),
                        ),
                        SizedBox(width: 24.w),
                        Expanded(
                          child: _item(
                            title: 'Coin Balance Today',
                            value: coins,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  /// 🔹 BOTTOM WHITE CARD (3 ITEMS)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white, // ✅ WHITE CARD
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _item(
                            title: 'Total Transaction Today',
                            value: tx,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _item(
                            title: 'Total Coins Issued Today',
                            value: coinsIssued,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _item(
                            title: 'Total Coupons Issued Today',
                            value: coupons,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),

            /// 🔹 CTA BUTTON (same)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0040B8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () => context.push(AppRoutes.createFaydaBill),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create Fayda Bill',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.send_rounded,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        if (loading && s != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2.h),
          ),
      ],
    );
  }

  Widget _item({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
