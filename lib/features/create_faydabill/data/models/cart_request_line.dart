/// One line in `POST /api/cashier-transactions/preview-summary` `cart` array.
/// Stored across category switches until customer is cleared.
class CartRequestLine {
  const CartRequestLine({
    this.promotionId,
    required this.productName,
    required this.mrp,
    required this.categoryId,
    required this.subCategoryId,
    required this.storeSubcategoryMappingId,
    required this.qty,
    this.cashback,
  });

  final String? promotionId;
  final String productName;
  final int mrp;
  final int categoryId;
  final int subCategoryId;
  final int storeSubcategoryMappingId;
  final int qty;
  final int? cashback;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'promotionId': promotionId,
        'productName': productName,
        'mrp': mrp,
        'categoryId': categoryId,
        'subCategoryId': subCategoryId,
        'storeSubcategoryMappingId': storeSubcategoryMappingId,
        'qty': qty,
        'cashback': cashback,
      };
}
