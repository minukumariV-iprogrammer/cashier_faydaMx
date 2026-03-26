import '../data/models/promotions_list_models.dart';

/// Per-unit cashback in rupees (aligned with deal card “After cashback” logic).
double promotionCashbackUnitRupees(
  PromotionItemModel p, {
  int? effectiveMrpPerUnit,
}) {
  final cv = (p.cashbackValue ?? 0).toDouble();
  if (cv <= 0) return 0;

  final t = p.cashbackType?.toLowerCase().trim();
  final mrp = (effectiveMrpPerUnit ?? p.mrpValue ?? 0).toDouble();
  final offer = (p.offerPriceValue ?? 0).toDouble();

  if (t == 'value') {
    return cv.floorToDouble();
  }
  if (t == 'percentage') {
    if (offer > 0) return (offer / 100) * cv;
    if (mrp > 0) return (mrp / 100) * cv;
    return 0;
  }
  return cv.floorToDouble();
}

/// Total cashback for [qty] units (floor).
int promotionCashbackTotalRupees(
  PromotionItemModel p,
  int qty, {
  int? effectiveMrpPerUnit,
}) {
  final q = qty < 1 ? 1 : qty;
  return (promotionCashbackUnitRupees(
            p,
            effectiveMrpPerUnit: effectiveMrpPerUnit,
          ) *
          q)
      .floor();
}
