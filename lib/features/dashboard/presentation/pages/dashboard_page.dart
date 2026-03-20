import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../create_faydabill/presentation/pages/create_faydabill_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const String route = '/dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogo(),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ],
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: AppColors.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary cards
              _SummaryCard(
                children: [
                  _MetricItem(value: '200', label: 'Gift Voucher Balance'),
                  _MetricItem(value: '126', label: 'Coin Balance Today'),
                ],
              ),
              const SizedBox(height: 16),
              _SummaryCard(
                children: [
                  _MetricItem(value: '07', label: 'Total Transaction Today'),
                  _MetricItem(value: '126', label: 'Total Coins Issued Today'),
                  _MetricItem(value: '05', label: 'Total Coupons Issued Today'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.push(CreateFaydaBillPage.route),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Create FaydaBill'),
                      const SizedBox(width: 8),
                      const Icon(Icons.double_arrow, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              'F',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Positioned(
              right: 4,
              bottom: 6,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.accentGold,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: children,
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
