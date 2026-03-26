/// POST `/api/store/calculate-gift-voucher` — `data` payload.
class CalculateGiftVoucherDataModel {
  const CalculateGiftVoucherDataModel({
    required this.giftVouchers,
    required this.giftCoins,
  });

  final int giftVouchers;
  final int giftCoins;

  factory CalculateGiftVoucherDataModel.fromJson(Map<String, dynamic> json) {
    final gvRaw = json['giftVouchers'] ?? json['giftVoucher'];
    final gcRaw = json['giftCoins'] ?? json['giftCoin'];
    return CalculateGiftVoucherDataModel(
      giftVouchers: _toInt(gvRaw),
      giftCoins: _toInt(gcRaw),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class CalculateGiftVoucherApiResponseModel {
  const CalculateGiftVoucherApiResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  final bool success;
  final String? message;
  final CalculateGiftVoucherDataModel? data;

  factory CalculateGiftVoucherApiResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final d = json['data'];
    return CalculateGiftVoucherApiResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString(),
      data: d is Map<String, dynamic>
          ? CalculateGiftVoucherDataModel.fromJson(d)
          : null,
    );
  }
}
