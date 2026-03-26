import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/store_asset_url.dart';
import '../../data/models/preview_summary_models.dart';
import '../../domain/entities/customer_by_phone_entity.dart';
import '../bloc/create_faydabill_bloc.dart';
import '../bloc/create_faydabill_event.dart';
import '../bloc/create_faydabill_state.dart';
import 'fayda_transaction_verify_dialog.dart';
const Color _kOrangePlaceholder = Color(0xFFFF6B35);
const Color _kHeaderGrey = Color(0xFF5A6B7E);
const Color _kMintPanel = Color(0xFFE9F5EB);
const Color _kTagBlueBg = Color(0xFFD6E4FF);
const Color _kTagBlueText = Color(0xFF1E3A5F);
const Color _kListBg = Color(0xFFF5F6F8);
const Color _kCashbackGreen = Color(0xFF43A047);

/// `totalCashback` + `extraFaydaMXCoins` (other benefit) + `rewardToReferrer`.
int? _previewTotalExtraFaydaMxCoins(PreviewSummaryTotalsModel? sum) {
  if (sum == null) return null;
  return sum.totalCashback + sum.extraFaydaMXCoins + sum.rewardToReferrer;
}

/// Expandable summaries + totals + submit — below product “Add to cart”.
class FaydaCheckoutSummarySection extends StatefulWidget {
  const FaydaCheckoutSummarySection({super.key, required this.state});

  final CreateFaydaBillState state;

  @override
  State<FaydaCheckoutSummarySection> createState() =>
      _FaydaCheckoutSummarySectionState();
}

class _FaydaCheckoutSummarySectionState
    extends State<FaydaCheckoutSummarySection> {
  final ValueNotifier<bool> _productExpanded = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _faydaBillExpanded = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _productExpanded.dispose();
    _faydaBillExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final preview = s.previewSummary;
    final productLineCount = preview?.items.length ?? 0;
    final hasOtherBenefit = s.otherBenefitInCart;
    final itemCount = productLineCount + (hasOtherBenefit ? 1 : 0);
    final hasCart = preview != null && itemCount > 0;
    final sum = preview?.summary;
    final canSubmit = _canSubmitTransaction(s);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: AnimatedBuilder(
        animation: Listenable.merge([_productExpanded, _faydaBillExpanded]),
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ExpandableHeader(
                title: 'PRODUCT & EXTRA BENEFITS SUMMARY',
                count: itemCount,
                expanded: _productExpanded.value,
                onTap: () =>
                    _productExpanded.value = !_productExpanded.value,
              ),
              if (_productExpanded.value) ...[
            const SizedBox(height: 8),
            Container(
              color: _kListBg,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: hasCart
                  ? Column(
                      children: [
                        for (var i = 0; i < preview!.items.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ProductLineCard(
                              item: preview.items[i],
                              onDelete: () => context
                                  .read<CreateFaydaBillBloc>()
                                  .add(CreateFaydaBillCartLineRemoved(i)),
                            ),
                          ),
                        if (hasOtherBenefit)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _OtherBenefitLineCard(
                              reason: s.otherBenefitReason,
                              coins: int.tryParse(s.otherBenefitCashback.trim()) ?? 0,
                              onDelete: () => context
                                  .read<CreateFaydaBillBloc>()
                                  .add(const CreateFaydaBillOtherBenefitRemoved()),
                            ),
                          ),
                      ],
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No items in cart yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF78909C),
                        ),
                      ),
                    ),
            ),
          ],
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              _ExpandableHeader(
                title: 'FAYDABILL SUMMARY',
                count: itemCount,
                expanded: _faydaBillExpanded.value,
                onTap: () =>
                    _faydaBillExpanded.value = !_faydaBillExpanded.value,
              ),
              if (_faydaBillExpanded.value) ...[
            const SizedBox(height: 4),
            _FaydaBillExpandedPanel(
              state: s,
              customerSession: s.customerSession,
              summary: sum,
            ),
          ],
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 12),
              _SummaryValueRow(
                label: 'Total GV',
                valueText: _fmtOrDash(sum?.totalGV, hasCart),
              ),
              const SizedBox(height: 10),
              _SummaryValueRow(
                label: 'Total Extra FaydaMX Coins',
                valueText: _fmtOrDash(
                  _previewTotalExtraFaydaMxCoins(sum),
                  hasCart,
                ),
              ),
              const SizedBox(height: 10),
              _SummaryValueRow(
                label: 'Referral Bonus to Referrer',
                valueText: _fmtOrDash(sum?.rewardToReferrer, hasCart),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    'Store Referral is requested',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: canSubmit
                      ? () => showFaydaTransactionVerifyDialog(context)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.faydaBillChipSelected,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _fmtOrDash(int? v, bool hasData) {
    if (!hasData) return '--';
    return '$v';
  }

  static bool _canSubmitTransaction(CreateFaydaBillState s) {
    final hasCart = s.previewSummary != null &&
        (s.previewSummary!.items.isNotEmpty || s.otherBenefitInCart);
    return hasCart &&
        s.phone.length == 10 &&
        !s.previewSummaryLoading &&
        !s.cashierTransactionSubmitting &&
        s.customerStatus == CreateFaydaBillCustomerStatus.success;
  }
}

class _ExpandableHeader extends StatelessWidget {
  const _ExpandableHeader({
    required this.title,
    required this.count,
    required this.expanded,
    required this.onTap,
  });

  final String title;
  final int count;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$title ($count)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kHeaderGrey,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                color: _kHeaderGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductLineCard extends StatelessWidget {
  const _ProductLineCard({required this.item, required this.onDelete});

  final PreviewSummaryItemModel item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final name = item.productName.isEmpty ? 'Product' : item.productName;
    final tag1 = item.categoryName ?? 'Category';
    final tag2 = item.subCategoryName ?? 'Subcategory';
    final promoLabel = item.promotionId != null && item.promotionId!.isNotEmpty
        ? 'Promotion ID ${item.promotionId}'
        : 'No promotion';
    final lineTotal = item.mrp * item.qty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline,
                    size: 20, color: Colors.grey.shade600),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Tag(text: tag1),
              const SizedBox(width: 8),
              _Tag(text: tag2),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            promoLabel,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              children: [
                const TextSpan(text: 'Rate '),
                TextSpan(
                  text: '₹${item.mrp}',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: '  ·  Quantity ', style: TextStyle(color: Colors.grey.shade600)),
                TextSpan(
                  text: '${item.qty}',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Amt ₹$lineTotal',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _kCashbackGreen),
                ),
                child: Text(
                  'Cashback of ${item.cashback}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kCashbackGreen,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.card_giftcard,
                      size: 18, color: Colors.orange.shade700),
                  const SizedBox(width: 4),
                  Text(
                    '${item.gv}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OtherBenefitLineCard extends StatelessWidget {
  const _OtherBenefitLineCard({
    required this.reason,
    required this.coins,
    required this.onDelete,
  });

  final String reason;
  final int coins;
  final VoidCallback onDelete;

  static const Color _cardTint = Color(0xFFE8F0FE);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardTint,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Extra Fayda Coins',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline,
                    size: 20, color: Colors.grey.shade600),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reason.trim().isEmpty ? '—' : reason.trim(),
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kCashbackGreen),
              ),
              child: Text(
                '₹$coins Cashback',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kCashbackGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kTagBlueBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _kTagBlueText,
        ),
      ),
    );
  }
}

class _FaydaBillExpandedPanel extends StatelessWidget {
  const _FaydaBillExpandedPanel({
    required this.state,
    required this.customerSession,
    required this.summary,
  });

  final CreateFaydaBillState state;
  final CustomerByPhoneSessionEntity? customerSession;
  final PreviewSummaryTotalsModel? summary;

  @override
  Widget build(BuildContext context) {
    final billNo = state.invoiceNumber.trim().isEmpty
        ? '--'
        : state.invoiceNumber.trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _kMintPanel,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BillRow(label: 'Bill No.', value: billNo),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFBFDCC4)),
          ),
          _CustomerProfileBlock(customer: customerSession?.customer),
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 8),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFBFDCC4),
            ),
          ),
          _DottedDividerPlaceholder(),
          const SizedBox(height: 10),
          _StatsGrid(session: customerSession),
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 10),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFBFDCC4)),
          ),
          _SectionTitleRow(
            title: 'Gift Voucher Summary',
            value: summary != null ? '${summary!.totalGV}' : '--',
          ),
          const SizedBox(height: 8),
          _MutedRow(
            label: 'FaydaMX Coupons',
            value: summary != null ? '${summary!.totalGV}' : '--',
          ),
          const SizedBox(height: 6),
          _MutedRow(
            label: 'FaydaMX Coins',
            value: summary != null ? '${summary!.faydaCoins}' : '--',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFBFDCC4)),
          ),
          _SectionTitleRow(
            title: 'Total Extra FaydaMX Coins',
            value: summary != null
                ? '${_previewTotalExtraFaydaMxCoins(summary)}'
                : '--',
          ),
          const SizedBox(height: 8),
          _MutedRow(
            label: 'Deal Cashback',
            value: summary != null ? '${summary!.totalCashback}' : '--',
          ),
          const SizedBox(height: 6),
          _MutedRow(
            label: 'Extra FaydaMX Coins',
            value: summary != null ? '${summary!.extraFaydaMXCoins}' : '--',
          ),
          const SizedBox(height: 6),
          _MutedRow(
            label: 'Coins from Referral',
            value: summary != null ? '${summary!.rewardToReferrer}' : '--',
          ),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF37474F),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: value == '--'
                ? _kOrangePlaceholder
                : const Color(0xFF37474F),
          ),
        ),
      ],
    );
  }
}

class _CustomerProfileBlock extends StatelessWidget {
  const _CustomerProfileBlock({required this.customer});

  final CustomerEntity? customer;

  @override
  Widget build(BuildContext context) {
    final c = customer;
    final name = c != null && c.name.trim().isNotEmpty ? c.name : '—';
    final phone = c != null && c.phone.trim().isNotEmpty ? c.phone : '—';
    final imgUrl = (c != null && c.profilePicture != null)
        ? storeAssetUrl(c.profilePicture)
        : null;
    final showKycPending =
        c != null && (c.kycStatus == null || c.kycStatus == 0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: imgUrl != null && imgUrl.isNotEmpty
              ? Image.network(
                  imgUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade300,
                    child: Icon(Icons.person,
                        size: 32, color: Colors.grey.shade700),
                  ),
                )
              : Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey.shade300,
                  child: Icon(Icons.person,
                      size: 32, color: Colors.grey.shade700),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF37474F),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              if (showKycPending) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD56B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'KYC Pending',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DottedDividerPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return CustomPaint(
          size: Size(c.maxWidth, 1),
          painter: _DottedLinePainter(),
        );
      },
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 1;
    const dash = 4.0;
    const gap = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.session});

  final CustomerByPhoneSessionEntity? session;

  @override
  Widget build(BuildContext context) {
    final s = session;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCell(
                label: 'FaydaMX Coupons',
                value: s != null ? '${s.totalLuckyCoupons}' : '--',
              ),
            ),
            Expanded(
              child: _StatCell(
                label: 'FaydaMX Coins',
                value: s != null ? '${s.totalCoins}' : '--',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _StatCell(
                label: 'All Store Visits',
                value: s != null ? '${s.allStoreVisit}' : '--',
              ),
            ),
            Expanded(
              child: _StatCell(
                label: 'Current Store Visit',
                value: s != null ? '${s.currentStoreVisitCount}' : '--',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDash = value == '--';
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDash ? _kOrangePlaceholder : const Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  const _SectionTitleRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDash = value == '--';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF37474F),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDash ? _kOrangePlaceholder : const Color(0xFF37474F),
          ),
        ),
      ],
    );
  }
}

class _MutedRow extends StatelessWidget {
  const _MutedRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDash = value == '--';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDash ? _kOrangePlaceholder : const Color(0xFF37474F),
          ),
        ),
      ],
    );
  }
}

class _SummaryValueRow extends StatelessWidget {
  const _SummaryValueRow({required this.label, required this.valueText});

  final String label;
  final String valueText;

  @override
  Widget build(BuildContext context) {
    final isDash = valueText == '--';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF37474F),
          ),
        ),
        Text(
          valueText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDash ? _kOrangePlaceholder : const Color(0xFF37474F),
          ),
        ),
      ],
    );
  }
}
