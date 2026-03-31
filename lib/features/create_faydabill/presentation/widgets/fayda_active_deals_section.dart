import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/store_asset_url.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../data/models/promotions_list_models.dart';
import '../bloc/create_faydabill_bloc.dart';
import '../bloc/create_faydabill_event.dart';
import '../bloc/create_faydabill_state.dart';

/// `rgb(235, 255, 0)` — Hot Deal strip.
const Color _kHotDealBarColor = Color(0xFFEBFF00);

const Color _kDiscountGreen = Color(0xFF43A047);

/// `((mrp - offer) / mrp) * 100`, e.g. `"12.5% off"`.
String _promotionDiscountPercentOff(PromotionItemModel p) {
  final double mrp = (p.mrpValue ?? 0).toDouble();
  final double offer = (p.offerPriceValue ?? 0).toDouble();
  if (mrp <= 0 || offer <= 0) return '';
  final double discount = ((mrp - offer) / mrp) * 100;
  if (discount <= 0) return '';
  final rounded = double.parse(discount.toStringAsFixed(2));
  return '$rounded% off';
}

/// Cashback line: `value` → fixed ₹; `percentage` → ₹ from offer or MRP, else `%` label.
String _promotionCashbackDisplayText(PromotionItemModel p) {
  final double cashbackValue = (p.cashbackValue ?? 0).toDouble();
  if (cashbackValue <= 0) return '';

  final t = p.cashbackType?.toLowerCase().trim();
  if (t == 'value') {
    return 'After cashback of ₹${cashbackValue.floor()}';
  }
  if (t == 'percentage') {
    final double offerPrice = (p.offerPriceValue ?? 0).toDouble();
    final double mrpValue = (p.mrpValue ?? 0).toDouble();
    if (offerPrice > 0) {
      final amount = (offerPrice / 100) * cashbackValue;
      return 'After cashback of ₹${amount.floor()}';
    }
    if (mrpValue > 0) {
      final amount = (mrpValue / 100) * cashbackValue;
      return 'After cashback of ₹${amount.floor()}';
    }
    final isInteger = cashbackValue % 1 == 0;
    final formatted = isInteger
        ? cashbackValue.toInt().toString()
        : cashbackValue.toStringAsFixed(2);
    return 'After cashback of $formatted%';
  }
  // Unknown / missing type: treat as fixed rupee (legacy API).
  return 'After cashback of ₹${cashbackValue.floor()}';
}

/// Pay / MRP / % off / cashback pill / best price — same rules as retail promotions card.
class _DealPricingRow extends StatelessWidget {
  const _DealPricingRow({required this.item});

  final PromotionItemModel item;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = (item.offerPriceValue ?? 0) > 0;
    final showMrp = (item.mrpValue ?? 0) > 0;
    final discountText = _promotionDiscountPercentOff(item);
    final cashbackText = _promotionCashbackDisplayText(item);

    const labelSmall = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );
    const valueStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );
    const strikeStyle = TextStyle(
      fontSize: 10,
      color: Color(0xFF757575),
      decoration: TextDecoration.lineThrough,
      decorationThickness: 1,
      fontWeight: FontWeight.w500,
    );
    const mrpNoDiscountStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );
    const discountGreen = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: _kDiscountGreen,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 5,
          runSpacing: 4,
          children: [
            if (hasDiscount)
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(text: 'Pay ', style: labelSmall),
                    TextSpan(
                      text: '₹${item.offerPriceValue}',
                      style: valueStyle,
                    ),
                  ],
                ),
              ),
            if (showMrp)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!hasDiscount) ...[
                    const Text('Pay', style: labelSmall),
                    const SizedBox(width: 2),
                  ],
                  Text(
                    '₹${item.mrpValue}',
                    style: hasDiscount ? strikeStyle : mrpNoDiscountStyle,
                  ),
                ],
              ),
            if (discountText.isNotEmpty)
              Text(discountText, style: discountGreen),
          ],
        ),
        if (cashbackText.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _kDiscountGreen.withOpacity(0.12),
              border: Border.all(color: _kDiscountGreen),
            ),
            child: Text(
              cashbackText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
        if ((item.finalPrice ?? 0) > 0) ...[
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Best Price ',
                  style: TextStyle(
                    color: AppColors.faydaBillChipSelected,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: '₹',
                  style: TextStyle(
                    color: AppColors.faydaBillChipSelected,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: '${item.finalPrice}',
                  style: TextStyle(
                    color: AppColors.faydaBillChipSelected,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Header + horizontal deals. Count = `data.total`. Arrows sit after the title (not screen-right).
class FaydaActiveDealsSection extends StatefulWidget {
  const FaydaActiveDealsSection({super.key, required this.state});

  final CreateFaydaBillState state;

  @override
  State<FaydaActiveDealsSection> createState() => _FaydaActiveDealsSectionState();
}

class _FaydaActiveDealsSectionState extends State<FaydaActiveDealsSection> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _scrollTick = ValueNotifier<int>(0);

  void _notifyScrollChanged() => _scrollTick.value++;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(FaydaActiveDealsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final subChanged = oldWidget.state.selectedSubcategoryMappingId !=
        widget.state.selectedSubcategoryMappingId;
    final lenChanged =
        oldWidget.state.promotions.length != widget.state.promotions.length;
    if (subChanged || lenChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        _notifyScrollChanged();
      });
    }

    final selChanged = oldWidget.state.selectedPromotionId !=
        widget.state.selectedPromotionId;
    final id = widget.state.selectedPromotionId;
    if (selChanged && id != null && id.isNotEmpty) {
      final idx = widget.state.promotions.indexWhere((e) => e.id == id);
      if (idx >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToDealIndex(idx);
        });
      }
    }
  }

  static const double _dealCardWidth = 172;
  static const double _dealCardGap = 12;

  void _scrollToDealIndex(int index) {
    if (!_scrollController.hasClients) return;
    final target = index * (_dealCardWidth + _dealCardGap);
    final max = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      target.clamp(0.0, max),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _onScroll() {
    _notifyScrollChanged();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollTick.dispose();
    super.dispose();
  }

  int get _displayCount {
    final s = widget.state;
    if (s.selectedSubcategoryMappingId == null) return 0;
    return s.promotionsTotal;
  }

  String _emptyMessage(CreateFaydaBillState s) {
    if (s.selectedSubcategoryMappingId == null) {
      return 'Select a subcategory to see deals';
    }
    if (s.promotionsStatus == CreateFaydaBillPromotionsStatus.failure &&
        s.promotionsErrorMessage != null &&
        s.promotionsErrorMessage!.isNotEmpty) {
      return s.promotionsErrorMessage!;
    }
    return 'No active deals';
  }

  void _scrollBy(double delta) {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final next = (_scrollController.offset + delta).clamp(0.0, max);
    _scrollController.animateTo(
      next,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  bool get _canScrollBack {
    final deals = widget.state.promotions;
    if (deals.isEmpty) return false;
    if (!_scrollController.hasClients) return false;
    return _scrollController.offset > 1.5;
  }

  /// Forward enabled only when **more than 2** items and not at end.
  bool get _canScrollForward {
    final deals = widget.state.promotions;
    if (deals.length <= 2) return false;
    if (!_scrollController.hasClients) return deals.length > 2;
    final max = _scrollController.position.maxScrollExtent;
    return _scrollController.offset < max - 1.5;
  }

  /// Hide the large “No active deals” placeholder when count is already 0 in the title.
  bool _hideEmptyDealsPlaceholder(CreateFaydaBillState s) {
    if (s.selectedSubcategoryMappingId == null) return false;
    if (s.promotionsStatus != CreateFaydaBillPromotionsStatus.success) {
      return false;
    }
    return s.promotions.isEmpty && s.promotionsTotal == 0;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final deals = s.promotions;
    final loading = s.promotionsStatus == CreateFaydaBillPromotionsStatus.loading;
    final slate = const Color(0xFF64748B);

    return AnimatedBuilder(
      animation: _scrollTick,
      builder: (context, _) {
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.sell_outlined, size: 22, color: slate),
            const SizedBox(width: 8),
            Text(
              'Active Deals ($_displayCount)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: slate,
              ),
            ),
            const SizedBox(width: 24),
            _RoundNavButton(
              icon: Icons.chevron_left,
              enabled: _canScrollBack,
              onPressed: () => _scrollBy(-180),
            ),
            const SizedBox(width: 6),
            _RoundNavButton(
              icon: Icons.chevron_right,
              enabled: _canScrollForward,
              onPressed: () => _scrollBy(180),
            ),
          ],
        ),
        if(_displayCount >0)...[
        const SizedBox(height: 4),
        Container(
          height: 1,
          color: const Color(0xFFE2E8F0),
        ),
        const SizedBox(height: 12),
        ],
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (deals.isEmpty)
          _hideEmptyDealsPlaceholder(s)
              ? const SizedBox.shrink()
              :const SizedBox.shrink()
        else
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < deals.length; i++) ...[
                  if (i > 0) const SizedBox(width: _dealCardGap),
                  SizedBox(
                    width: _dealCardWidth,
                    child: _DealCard(
                      item: deals[i],
                      selected: s.selectedPromotionId == deals[i].id,
                      onTap: () {
                        if (deals[i].isUnavailableForPurchase) {
                          ToastUtils.showErrorToast(
                            message: 'this product is out of stock',
                          );
                          return;
                        }
                        context.read<CreateFaydaBillBloc>().add(
                              CreateFaydaBillPromotionSelected(deals[i].id),
                            );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
      },
    );
  }
}

class _RoundNavButton extends StatelessWidget {
  const _RoundNavButton({
    required this.icon,
    required this.onPressed,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: const Color(0xFFF1F5F9),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 20, color: const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final PromotionItemModel item;
  final bool selected;
  final VoidCallback onTap;

  static const _fallback = 'assets/cashierrelated/fashion_image.webp';

  @override
  Widget build(BuildContext context) {
    final imgPath = item.productImages != null && item.productImages!.isNotEmpty
        ? item.productImages!.first
        : null;
    final imgUrl = storeAssetUrl(imgPath);

    return Material(
      elevation: selected ? 4 : 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.faydaBillChipSelected : Colors.transparent,
              width: selected ? 2 : 0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              color: const Color(0xFFF5F5F5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.uniqueId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(Icons.confirmation_number_outlined,
                      size: 16, color: Colors.amber.shade800),
                  const SizedBox(width: 4),
                  Text(
                    '${item.giftVoutcher ?? 0}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 72,
              child: imgUrl.isEmpty
                  ? Image.asset(_fallback, fit: BoxFit.cover)
                  : Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Image.asset(_fallback, fit: BoxFit.cover),
                      loadingBuilder: (context, child, p) {
                        if (p == null) return child;
                        return Image.asset(_fallback, fit: BoxFit.cover);
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              color: _kHotDealBarColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dealTypeLabel(item.type),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: Colors.black87),
                      const SizedBox(width: 4),
                      Text(
                        _formatShortDate(item.endDate),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _DealPricingRow(item: item),
                  if (item.isUnavailableForPurchase) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'SOLD OUT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.red,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    'Quantity: ${item.remainingQuantity ?? 0}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }

  static String _dealTypeLabel(String? type) {
    if (type == null || type.isEmpty) return 'Deal';
    return type
        .split('-')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static String _formatShortDate(String? iso) {
    if (iso == null) return '';
    final d = DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '';
    const m = <String>[
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
      'Dec'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]}';
  }
}
