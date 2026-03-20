import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Placeholder layout matching the dashboard cards while data is loading.
class CashierDashboardShimmer extends StatelessWidget {
  const CashierDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _box(height: 88)),
              const SizedBox(width: 12),
              Expanded(child: _box(height: 88)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _box(height: 96)),
              const SizedBox(width: 12),
              Expanded(child: _box(height: 96)),
              const SizedBox(width: 12),
              Expanded(child: _box(height: 96)),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _box({required double height}) => Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      );
}
