/// POST `/api/cashier-transactions` — create bill / checkout.
class CashierTransactionDataModel {
  const CashierTransactionDataModel({
    required this.id,
    this.invoiceNumber,
    this.billDisplayId,
    this.status,
  });

  final String id;
  final String? invoiceNumber;
  final String? billDisplayId;
  final String? status;

  factory CashierTransactionDataModel.fromJson(Map<String, dynamic> json) {
    return CashierTransactionDataModel(
      id: json['id']?.toString() ?? '',
      invoiceNumber: json['invoiceNumber']?.toString(),
      billDisplayId: json['billDisplayId']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class CashierTransactionApiResponseModel {
  const CashierTransactionApiResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  final bool success;
  final String? message;
  final CashierTransactionDataModel? data;

  factory CashierTransactionApiResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final d = json['data'];
    return CashierTransactionApiResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString(),
      data: d is Map<String, dynamic>
          ? CashierTransactionDataModel.fromJson(d)
          : null,
    );
  }
}
