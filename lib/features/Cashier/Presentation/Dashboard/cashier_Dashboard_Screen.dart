import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routers.dart';
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

class cashierDashBoardScreen extends StatefulWidget {
  const cashierDashBoardScreen({super.key});

  @override
  State<cashierDashBoardScreen> createState() => _cashierDashBoardScreenState();
}

class _cashierDashBoardScreenState extends State<cashierDashBoardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
            titleSpacing: 16,
            title: _buildStoreHeaderTitle(state),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CashierProfileAppBarButton(onTap: _onUserIconTap),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
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
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
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
                const SizedBox(width: 12),
                _topCard(
                  title: 'Coin Balance Today',
                  value: coins,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _statCard(
                  title: 'Total Transactions Today',
                  value: tx,
                ),
                const SizedBox(width: 12),
                _statCard(
                  title: 'Total Coins Issued Today',
                  value: coinsIssued,
                ),
                const SizedBox(width: 12),
                _statCard(
                  title: 'Total Coupons Issued Today',
                  value: coupons,
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B1BE3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => context.push(AppRoutes.createFaydaBill),
                child: const Text(
                  'Create Fayda Bill  >',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (loading && s != null)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  Widget _topCard({required String title, required String value}) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
}
