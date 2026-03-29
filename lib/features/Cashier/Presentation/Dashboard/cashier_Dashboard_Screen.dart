import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routers.dart';
import '../../../../core/navigation/dashboard_refresh_notifier.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../../../di/injection.dart';
import '../../../../core/network/season_holder.dart';
import '../../../../core/network/tenant_holder.dart';
import '../../../../core/network/token_service.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import 'Bloc/cashier_dashboard_bloc.dart';
import 'Bloc/cashier_dashboard_event.dart';
import 'Bloc/cashier_dashboard_state.dart';
import 'Bloc/cashier_dashboard_status.dart';
import 'widgets/cashier_dashboard_shimmer.dart';
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

    await sl<TokenService>().clearTokens();
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
                    color: Colors.grey.shade600,
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
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: CashierProfileAppBarButton(onTap: _onUserIconTap),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: showInitialLoader
                ? const CashierDashboardShimmer()
                : _buildBody(context, state, loading),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    CashierDashboardState state,
    bool loading,
  ) {
    if (state.status == CashierDashboardStatus.failure &&
        state.summary == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            state.errorMessage ?? 'Failed to load dashboard',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () => context
                .read<CashierDashboardBloc>()
                .add(const CashierDashboardLoadRequested()),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    final s = state.summary;
    final gift = s?.giftVoucherBalance.toString() ?? '—';
    final coins = s?.coinBalance.toString() ?? '—';
    final tx = s?.totalTransactionsToday.toString() ?? '—';
    final coinsIssued = s?.coinsIssuedToday.toString() ?? '—';
    final coupons = s?.couponsIssuedToday.toString() ?? '—';

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _topCard(
                  title: 'QR Voucher Balance',
                  value: gift,
                ),
                SizedBox(width: 12.w),
                _topCard(
                  title: 'Coin Balance Today',
                  value: coins,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _statCard(
                  title: 'Total Transactions Today',
                  value: tx,
                ),
                SizedBox(width: 12.w),
                _statCard(
                  title: 'Total Coins Issued Today',
                  value: coinsIssued,
                ),
                SizedBox(width: 12.w),
                _statCard(
                  title: 'Total Coupons Issued Today',
                  value: coupons,
                ),
              ],
            ),
            SizedBox(height: 30.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B1BE3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: () => context.push(AppRoutes.createFaydaBill),
                child: Text(
                  'Create Fayda Bill  >',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

  Widget _topCard({required String title, required String value}) => Expanded(
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
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
          ),
        ),
      );

  Widget _statCard({required String title, required String value}) =>
      Expanded(
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
}
