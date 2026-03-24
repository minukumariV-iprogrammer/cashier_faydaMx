import 'package:equatable/equatable.dart';

import '../../data/models/promotions_list_models.dart';
import '../../domain/entities/customer_by_phone_entity.dart';
import '../../../Cashier/domain/entities/store_full_entity.dart';

enum CreateFaydaBillStoreStatus {
  initial,
  loading,
  success,
  failure,
}

enum CreateFaydaBillCustomerStatus {
  idle,
  loading,
  success,
  failure,
}

enum CreateFaydaBillPromotionsStatus {
  idle,
  loading,
  success,
  failure,
}

class CreateFaydaBillState extends Equatable {
  const CreateFaydaBillState({
    this.storeStatus = CreateFaydaBillStoreStatus.initial,
    this.storeFull,
    this.storeErrorMessage,
    this.phone = '',
    this.invoiceNumber = '',
    this.customerStatus = CreateFaydaBillCustomerStatus.idle,
    this.customerSession,
    this.customerErrorMessage,
    this.mainTabIndex = 0,
    this.selectedCategoryId,
    this.selectedSubcategoryMappingId,
    this.promotionsStatus = CreateFaydaBillPromotionsStatus.idle,
    this.promotions = const [],
    this.promotionsTotal = 0,
    this.promotionsErrorMessage,
    this.selectedPromotionId,
    this.productName = '',
    this.productQuantity = 1,
    this.productRate = '',
    this.productAmount = '',
    this.productMrp = '',
    this.productGv = '',
    this.productCashback = '',
  });

  final CreateFaydaBillStoreStatus storeStatus;
  final StoreFullEntity? storeFull;
  final String? storeErrorMessage;

  final String phone;
  final String invoiceNumber;

  final CreateFaydaBillCustomerStatus customerStatus;
  final CustomerByPhoneSessionEntity? customerSession;
  final String? customerErrorMessage;

  final int mainTabIndex;
  final int? selectedCategoryId;
  /// `storeSubcategoryMapping.id` — **null** until user taps a subcategory.
  final String? selectedSubcategoryMappingId;

  final CreateFaydaBillPromotionsStatus promotionsStatus;
  final List<PromotionItemModel> promotions;
  /// From `data.total` in promotions list response.
  final int promotionsTotal;
  final String? promotionsErrorMessage;

  /// `PromotionItemModel.id` — selected in dropdown / active deals.
  final String? selectedPromotionId;
  final String productName;
  final int productQuantity;
  final String productRate;
  /// Unit total: manual entry without deal; with deal = rate × quantity.
  final String productAmount;
  final String productMrp;
  final String productGv;
  final String productCashback;

  bool get hasDealSelection =>
      selectedPromotionId != null && selectedPromotionId!.isNotEmpty;

  /// Deal path: promotion selected and auto-filled fields present; quantity valid.
  /// Manual path (no promotion): product name + amount; rate stays disabled/empty.
  bool get isProductDetailsFormComplete {
    if (hasDealSelection) {
      if (productQuantity < 1) return false;
      if (productName.trim().isEmpty) return false;
      if (productRate.trim().isEmpty) return false;
      if (productAmount.trim().isEmpty) return false;
      if (productMrp.trim().isEmpty) return false;
      if (productGv.trim().isEmpty) return false;
      if (productCashback.trim().isEmpty) return false;
      return true;
    }
    return productName.trim().isNotEmpty && productAmount.trim().isNotEmpty;
  }

  bool get showPostPhoneSection =>
      storeStatus == CreateFaydaBillStoreStatus.success &&
      customerStatus == CreateFaydaBillCustomerStatus.success;

  @override
  List<Object?> get props => [
        storeStatus,
        storeFull,
        storeErrorMessage,
        phone,
        invoiceNumber,
        customerStatus,
        customerSession,
        customerErrorMessage,
        mainTabIndex,
        selectedCategoryId,
        selectedSubcategoryMappingId,
        promotionsStatus,
        promotions,
        promotionsTotal,
        promotionsErrorMessage,
        selectedPromotionId,
        productName,
        productQuantity,
        productRate,
        productAmount,
        productMrp,
        productGv,
        productCashback,
      ];

  CreateFaydaBillState copyWith({
    CreateFaydaBillStoreStatus? storeStatus,
    StoreFullEntity? storeFull,
    String? storeErrorMessage,
    String? phone,
    String? invoiceNumber,
    CreateFaydaBillCustomerStatus? customerStatus,
    CustomerByPhoneSessionEntity? customerSession,
    String? customerErrorMessage,
    int? mainTabIndex,
    int? selectedCategoryId,
    String? selectedSubcategoryMappingId,
    bool clearSelectedSubcategory = false,
    CreateFaydaBillPromotionsStatus? promotionsStatus,
    List<PromotionItemModel>? promotions,
    int? promotionsTotal,
    String? promotionsErrorMessage,
    bool clearPromotions = false,
    bool clearProductDetails = false,
    bool clearCustomer = false,
    bool clearStore = false,
    bool clearCustomerError = false,
    bool clearPromotionsError = false,
    String? selectedPromotionId,
    String? productName,
    int? productQuantity,
    String? productRate,
    String? productAmount,
    String? productMrp,
    String? productGv,
    String? productCashback,
  }) {
    return CreateFaydaBillState(
      storeStatus: storeStatus ?? this.storeStatus,
      storeFull: clearStore ? null : storeFull ?? this.storeFull,
      storeErrorMessage: storeErrorMessage ?? this.storeErrorMessage,
      phone: phone ?? this.phone,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerStatus: clearCustomer
          ? CreateFaydaBillCustomerStatus.idle
          : customerStatus ?? this.customerStatus,
      customerSession:
          clearCustomer ? null : customerSession ?? this.customerSession,
      customerErrorMessage: clearCustomerError
          ? null
          : customerErrorMessage ?? this.customerErrorMessage,
      mainTabIndex: mainTabIndex ?? this.mainTabIndex,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedSubcategoryMappingId: clearSelectedSubcategory
          ? null
          : (selectedSubcategoryMappingId ?? this.selectedSubcategoryMappingId),
      promotionsStatus: promotionsStatus ?? this.promotionsStatus,
      promotions: clearPromotions ? const [] : promotions ?? this.promotions,
      promotionsTotal: promotionsTotal ?? this.promotionsTotal,
      promotionsErrorMessage: clearPromotionsError
          ? null
          : promotionsErrorMessage ?? this.promotionsErrorMessage,
      selectedPromotionId: clearProductDetails
          ? null
          : (selectedPromotionId ?? this.selectedPromotionId),
      productName: clearProductDetails ? '' : (productName ?? this.productName),
      productQuantity:
          clearProductDetails ? 1 : (productQuantity ?? this.productQuantity),
      productRate: clearProductDetails ? '' : (productRate ?? this.productRate),
      productAmount:
          clearProductDetails ? '' : (productAmount ?? this.productAmount),
      productMrp: clearProductDetails ? '' : (productMrp ?? this.productMrp),
      productGv: clearProductDetails ? '' : (productGv ?? this.productGv),
      productCashback: clearProductDetails
          ? ''
          : (productCashback ?? this.productCashback),
    );
  }
}
