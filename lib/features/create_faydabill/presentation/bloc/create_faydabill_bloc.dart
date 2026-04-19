import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/errors/exceptions.dart';
import '../../../../core/network/token_service.dart';
import '../../../Cashier/domain/entities/store_full_entity.dart';
import '../../../Cashier/domain/usecases/get_store_detail_usecase.dart';
import '../../data/models/cart_request_line.dart';
import '../../data/models/promotions_list_models.dart';
import '../../domain/usecases/calculate_gift_voucher_usecase.dart';
import '../../domain/usecases/fetch_promotions_list_usecase.dart';
import '../../domain/usecases/lookup_customer_by_phone_usecase.dart';
import '../../domain/usecases/preview_cart_summary_usecase.dart';
import '../../domain/usecases/submit_cashier_transaction_usecase.dart';
import '../../utils/promotion_cashback_utils.dart';
import 'create_faydabill_event.dart';
import 'create_faydabill_state.dart';

class CreateFaydaBillBloc extends Bloc<CreateFaydaBillEvent, CreateFaydaBillState> {
  CreateFaydaBillBloc({
    required GetStoreDetailUseCase getStoreDetailUseCase,
    required LookupCustomerByPhoneUseCase lookupCustomerByPhoneUseCase,
    required FetchPromotionsListUseCase fetchPromotionsListUseCase,
    required CalculateGiftVoucherUseCase calculateGiftVoucherUseCase,
    required PreviewCartSummaryUseCase previewCartSummaryUseCase,
    required SubmitCashierTransactionUseCase submitCashierTransactionUseCase,
    required TokenService tokenService,
  })  : _getStoreDetailUseCase = getStoreDetailUseCase,
        _lookupCustomerByPhoneUseCase = lookupCustomerByPhoneUseCase,
        _fetchPromotionsListUseCase = fetchPromotionsListUseCase,
        _calculateGiftVoucherUseCase = calculateGiftVoucherUseCase,
        _previewCartSummaryUseCase = previewCartSummaryUseCase,
        _submitCashierTransactionUseCase = submitCashierTransactionUseCase,
        _tokenService = tokenService,
        super(const CreateFaydaBillState()) {
    on<CreateFaydaBillStarted>(_onStarted);
    on<CreateFaydaBillPhoneChanged>(_onPhoneChanged);
    on<CreateFaydaBillInvoiceChanged>(_onInvoiceChanged);
    on<CreateFaydaBillMainTabChanged>(_onMainTabChanged);
    on<CreateFaydaBillCategorySelected>(_onCategorySelected);
    on<CreateFaydaBillSubcategorySelected>(_onSubcategorySelected);
    on<CreateFaydaBillPromotionSelected>(_onPromotionSelected);
    on<CreateFaydaBillProductNameChanged>(_onProductNameChanged);
    on<CreateFaydaBillProductQuantityChanged>(_onProductQuantityChanged);
    on<CreateFaydaBillProductRateChanged>(_onProductRateChanged);
    on<CreateFaydaBillProductAmountChanged>(_onProductAmountChanged);
    on<CreateFaydaBillProductMrpChanged>(_onProductMrpChanged);
    on<CreateFaydaBillProductGvChanged>(_onProductGvChanged);
    on<CreateFaydaBillProductCashbackChanged>(_onProductCashbackChanged);
    on<CreateFaydaBillAddToCartPressed>(_onAddToCartPressed);
    on<CreateFaydaBillGiftVoucherFetch>(_onGiftVoucherFetch);
    on<CreateFaydaBillCartLineRemoved>(_onCartLineRemoved);
    on<CreateFaydaBillTransactionConfirmRequested>(_onTransactionConfirmRequested);
    on<CreateFaydaBillTransactionSuccessConsumed>(_onTransactionSuccessConsumed);
    on<CreateFaydaBillTransactionErrorCleared>(_onTransactionErrorCleared);
    on<CreateFaydaBillOtherBenefitReasonChanged>(_onOtherBenefitReasonChanged);
    on<CreateFaydaBillOtherBenefitCashbackChanged>(
        _onOtherBenefitCashbackChanged);
    on<CreateFaydaBillOtherBenefitAddToCartPressed>(
        _onOtherBenefitAddToCartPressed);
    on<CreateFaydaBillOtherBenefitRemoved>(_onOtherBenefitRemoved);
    on<CreateFaydaBillUserToastConsumed>(_onUserToastConsumed);
  }

  final GetStoreDetailUseCase _getStoreDetailUseCase;
  final LookupCustomerByPhoneUseCase _lookupCustomerByPhoneUseCase;
  final FetchPromotionsListUseCase _fetchPromotionsListUseCase;
  final CalculateGiftVoucherUseCase _calculateGiftVoucherUseCase;
  final PreviewCartSummaryUseCase _previewCartSummaryUseCase;
  final SubmitCashierTransactionUseCase _submitCashierTransactionUseCase;
  final TokenService _tokenService;

  Timer? _amountDebounce;

  @override
  Future<void> close() {
    _amountDebounce?.cancel();
    return super.close();
  }

  Future<void> _onStarted(
    CreateFaydaBillStarted event,
    Emitter<CreateFaydaBillState> emit,
  ) async {
    emit(state.copyWith(
      storeStatus: CreateFaydaBillStoreStatus.loading,
      storeErrorMessage: null,
    ));
    final storeId = await _tokenService.getStoreId();
    if (storeId == null || storeId.isEmpty) {
      emit(state.copyWith(
        storeStatus: CreateFaydaBillStoreStatus.failure,
        storeErrorMessage: 'No store assigned. Please log in again.',
      ));
      return;
    }
    try {
      final full = await _getStoreDetailUseCase(storeId: storeId);
      final firstCat = full.productCategories.isNotEmpty
          ? full.productCategories.first.id
          : null;
      emit(state.copyWith(
        storeStatus: CreateFaydaBillStoreStatus.success,
        storeFull: full,
        selectedCategoryId: firstCat,
        clearSelectedSubcategory: true,
        clearPromotions: true,
        promotionsStatus: CreateFaydaBillPromotionsStatus.idle,
        promotionsTotal: 0,
        clearPromotionsError: true,
      ));
      if (firstCat != null) {
        final subs = full.subcategoriesForCategory(firstCat);
        if (subs.length == 1) {
          add(CreateFaydaBillSubcategorySelected(subs.first.id));
        }
      }
    } on InputValidationException catch (e) {
      emit(state.copyWith(
        storeStatus: CreateFaydaBillStoreStatus.failure,
        storeErrorMessage: e.message,
      ));
    } on UnauthorizedException catch (e) {
      emit(state.copyWith(
        storeStatus: CreateFaydaBillStoreStatus.failure,
        storeErrorMessage: e.message ?? 'Unauthorized',
      ));
    } on NetworkException catch (e) {
      emit(state.copyWith(
        storeStatus: CreateFaydaBillStoreStatus.failure,
        storeErrorMessage: e.message ?? 'No internet connection',
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        storeStatus: CreateFaydaBillStoreStatus.failure,
        storeErrorMessage: e.message ?? 'Failed to load store',
      ));
    } catch (_) {
      emit(state.copyWith(
        storeStatus: CreateFaydaBillStoreStatus.failure,
        storeErrorMessage: 'Failed to load store',
      ));
    }
  }

  Future<void> _onPhoneChanged(
    CreateFaydaBillPhoneChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) async {
    final digits = event.phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      emit(state.copyWith(
        phone: digits,
        invoiceNumber: '',
        clearCustomer: true,
        customerStatus: CreateFaydaBillCustomerStatus.idle,
        clearCustomerError: true,
      ));
      return;
    }

    final phone10 = digits.length > 10 ? digits.substring(0, 10) : digits;
    emit(state.copyWith(phone: phone10));

    if (phone10.length != 10) return;

    final storeId = await _tokenService.getStoreId();
    if (storeId == null || storeId.isEmpty) {
      emit(state.copyWith(
        customerStatus: CreateFaydaBillCustomerStatus.failure,
        customerErrorMessage: 'No store assigned',
      ));
      return;
    }

    emit(state.copyWith(
      customerStatus: CreateFaydaBillCustomerStatus.loading,
      clearCustomer: true,
      clearCustomerError: true,
    ));

    try {
      final session = await _lookupCustomerByPhoneUseCase(
        phone: phone10,
        storeId: storeId,
      );
      emit(state.copyWith(
        customerStatus: CreateFaydaBillCustomerStatus.success,
        customerSession: session,
      ));
    } on InputValidationException catch (e) {
      emit(state.copyWith(
        customerStatus: CreateFaydaBillCustomerStatus.failure,
        customerErrorMessage: e.message ?? e.toString(),
      ));
    } on UnauthorizedException catch (e) {
      emit(state.copyWith(
        customerStatus: CreateFaydaBillCustomerStatus.failure,
        customerErrorMessage: e.message ?? 'Unauthorized',
      ));
    } on NetworkException catch (e) {
      emit(state.copyWith(
        customerStatus: CreateFaydaBillCustomerStatus.failure,
        customerErrorMessage: e.message ?? 'No internet connection',
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        customerStatus: CreateFaydaBillCustomerStatus.failure,
        customerErrorMessage: e.message ?? 'Customer lookup failed',
      ));
    } catch (_) {
      emit(state.copyWith(
        customerStatus: CreateFaydaBillCustomerStatus.failure,
        customerErrorMessage: 'Customer lookup failed',
      ));
    }
  }

  void _onInvoiceChanged(
    CreateFaydaBillInvoiceChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    emit(state.copyWith(invoiceNumber: event.invoice));
  }

  void _onMainTabChanged(
    CreateFaydaBillMainTabChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    emit(state.copyWith(mainTabIndex: event.index));
  }

  void _onCategorySelected(
    CreateFaydaBillCategorySelected event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    emit(state.copyWith(
      selectedCategoryId: event.categoryId,
      clearSelectedSubcategory: true,
      clearPromotions: true,
      clearProductDetails: true,
      promotionsStatus: CreateFaydaBillPromotionsStatus.idle,
      promotionsTotal: 0,
      clearPromotionsError: true,
    ));
    final full = state.storeFull;
    if (full == null) return;
    final subs = full.subcategoriesForCategory(event.categoryId);
    if (subs.length == 1) {
      add(CreateFaydaBillSubcategorySelected(subs.first.id));
    }
  }

  void _onUserToastConsumed(
    CreateFaydaBillUserToastConsumed event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    emit(state.copyWith(clearUserToast: true));
  }

  Future<void> _onSubcategorySelected(
    CreateFaydaBillSubcategorySelected event,
    Emitter<CreateFaydaBillState> emit,
  ) async {
    emit(state.copyWith(
      selectedSubcategoryMappingId: event.mappingId,
      promotionsStatus: CreateFaydaBillPromotionsStatus.loading,
      clearPromotions: true,
      clearProductDetails: true,
      promotionsTotal: 0,
      clearPromotionsError: true,
    ));

    final storeId = await _tokenService.getStoreId();
    final full = state.storeFull;
    if (storeId == null || storeId.isEmpty || full == null) {
      emit(state.copyWith(
        promotionsStatus: CreateFaydaBillPromotionsStatus.failure,
        promotionsErrorMessage: 'Missing store data',
        promotionsTotal: 0,
      ));
      return;
    }

    StoreSubcategoryMappingEntity? mapping;
    for (final m in full.subcategoryMappings) {
      if (m.id == event.mappingId) {
        mapping = m;
        break;
      }
    }
    if (mapping == null) {
      emit(state.copyWith(
        promotionsStatus: CreateFaydaBillPromotionsStatus.failure,
        promotionsErrorMessage: 'Subcategory not found',
        promotionsTotal: 0,
      ));
      return;
    }

    final subCatId =
        int.tryParse(mapping.subcategoryCapping.subCategoryMasterId) ?? 0;
    if (subCatId == 0) {
      emit(state.copyWith(
        promotionsStatus: CreateFaydaBillPromotionsStatus.failure,
        promotionsErrorMessage: 'Invalid subcategory',
        promotionsTotal: 0,
      ));
      return;
    }

    try {
      final data = await _fetchPromotionsListUseCase(
        storeId: storeId,
        subCategoryId: subCatId,
      );
      emit(state.copyWith(
        promotionsStatus: CreateFaydaBillPromotionsStatus.success,
        promotions: data.result,
        promotionsTotal: data.total ?? 0,
        clearPromotionsError: true,
      ));
    } on UnauthorizedException catch (e) {
      emit(state.copyWith(
        promotionsStatus: CreateFaydaBillPromotionsStatus.failure,
        promotionsErrorMessage: e.message ?? 'Unauthorized',
        promotionsTotal: 0,
      ));
    } on NetworkException catch (e) {
      emit(state.copyWith(
        promotionsStatus: CreateFaydaBillPromotionsStatus.failure,
        promotionsErrorMessage: e.message ?? 'No internet connection',
        promotionsTotal: 0,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        promotionsStatus: CreateFaydaBillPromotionsStatus.failure,
        promotionsErrorMessage: e.message ?? 'Failed to load deals',
        promotionsTotal: 0,
      ));
    } catch (_) {
      emit(state.copyWith(
        promotionsStatus: CreateFaydaBillPromotionsStatus.failure,
        promotionsErrorMessage: 'Failed to load deals',
        promotionsTotal: 0,
      ));
    }
  }

  PromotionItemModel? _promotionById(String id) {
    for (final p in state.promotions) {
      if (p.id == id) return p;
    }
    return null;
  }

  StoreSubcategoryMappingEntity? _selectedMapping() {
    final mapId = state.selectedSubcategoryMappingId;
    final full = state.storeFull;
    if (mapId == null || full == null) return null;
    for (final m in full.subcategoryMappings) {
      if (m.id == mapId) return m;
    }
    return null;
  }

  int? _resolvedSubCategoryId() {
    final m = _selectedMapping();
    if (m == null) return null;
    final v = int.tryParse(m.subcategoryCapping.subCategoryMasterId) ?? 0;
    return v == 0 ? null : v;
  }

  int? _storeSubcategoryMappingIdInt() {
    final id = state.selectedSubcategoryMappingId;
    return int.tryParse(id ?? '');
  }

  /// In-stock deal: per-unit MRP from promotion.
  int _mrpPerUnitForPromotion(PromotionItemModel p) {
    return p.mrpValue ?? 0;
  }

  /// Manual entry (no promotion): line total ÷ qty → per-unit MRP.
  int? _manualMrpPerUnit() {
    final qty = state.productQuantity < 1 ? 1 : state.productQuantity;
    final raw = state.productAmount.replaceAll(RegExp(r'\D'), '');
    final amt = int.tryParse(raw) ?? 0;
    if (amt <= 0) return null;
    final unit = (amt / qty).round();
    return unit <= 0 ? null : unit;
  }

  Future<void> _fetchGiftVoucher(Emitter<CreateFaydaBillState> emit) async {
    final sub = _resolvedSubCategoryId();
    if (sub == null) return;
    final storeId = await _tokenService.getStoreId();
    if (storeId == null || storeId.isEmpty) return;

    final qty = state.productQuantity < 1 ? 1 : state.productQuantity;
    final int mrp;
    final String? promotionId;

    if (state.hasDealSelection) {
      final promotion = _promotionById(state.selectedPromotionId!);
      if (promotion == null) return;
      mrp = _mrpPerUnitForPromotion(promotion);
      promotionId = promotion.id;
    } else {
      final unit = _manualMrpPerUnit();
      if (unit == null) return;
      mrp = unit;
      promotionId = null;
    }

    if (mrp <= 0) return;

    emit(state.copyWith(
      giftVoucherLoading: true,
      clearGiftVoucherError: true,
    ));
    try {
      final data = await _calculateGiftVoucherUseCase(
        subCategoryId: sub,
        mrp: mrp,
        storeId: storeId,
        qty: qty,
        promotionId: promotionId,
      );
      emit(state.copyWith(
        giftVoucherLoading: false,
        productGv: '${data.giftVouchers}',
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        giftVoucherLoading: false,
        giftVoucherErrorMessage: e.message,
      ));
    } on NetworkException catch (e) {
      emit(state.copyWith(
        giftVoucherLoading: false,
        giftVoucherErrorMessage: e.message ?? 'No internet connection',
      ));
    } catch (e) {
      emit(state.copyWith(
        giftVoucherLoading: false,
        giftVoucherErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGiftVoucherFetch(
    CreateFaydaBillGiftVoucherFetch event,
    Emitter<CreateFaydaBillState> emit,
  ) async {
    await _fetchGiftVoucher(emit);
  }

  void _scheduleGiftVoucherDebounce() {
    _amountDebounce?.cancel();
    _amountDebounce = Timer(const Duration(milliseconds: 300), () {
      add(const CreateFaydaBillGiftVoucherFetch());
    });
  }

  void _onPromotionSelected(
    CreateFaydaBillPromotionSelected event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    final item = _promotionById(event.promotionId);
    if (item == null) return;
    if (item.isUnavailableForPurchase) {
      emit(state.copyWith(
        userToastMessage: 'this product is out of stock',
      ));
      return;
    }
    emit(_applyPromotionToProductDetails(state, item));
    add(const CreateFaydaBillGiftVoucherFetch());
  }

  CreateFaydaBillState _applyPromotionToProductDetails(
    CreateFaydaBillState current,
    PromotionItemModel item,
  ) {
    const q = 1;
    final mrp = item.mrpValue ?? 0;
    final cashbackStr = '${promotionCashbackTotalRupees(item, q)}';
    return current.copyWith(
      selectedPromotionId: item.id,
      productName: item.name,
      productQuantity: q,
      productRate: '$mrp',
      productAmount: '${mrp * q}',
      productMrp: '$mrp',
      productGv: '',
      productCashback: cashbackStr,
      clearGiftVoucherError: true,
    );
  }

  void _onProductNameChanged(
    CreateFaydaBillProductNameChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    if (state.hasDealSelection) return;
    emit(state.copyWith(productName: event.name));
  }

  Future<void> _onProductQuantityChanged(
    CreateFaydaBillProductQuantityChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) async {
    final id = state.selectedPromotionId;
    if (id == null) {
      // No promotion: quantity is always 1 (no increment).
      emit(state.copyWith(
        productQuantity: 1,
        clearGiftVoucherError: true,
      ));
      _scheduleGiftVoucherDebounce();
      return;
    }
    final item = _promotionById(id);
    if (item == null) return;

    final maxQ = item.remainingQuantity;
    var q = event.quantity;
    if (q < 1) q = 1;
    if (maxQ != null && maxQ > 0 && q > maxQ) q = maxQ;

    final mrp = item.mrpValue ?? 0;
    final newAmount = '${mrp * q}';
    final newCashback = '${promotionCashbackTotalRupees(item, q)}';

    emit(state.copyWith(
      productQuantity: q,
      productAmount: newAmount,
      productCashback: newCashback,
      clearGiftVoucherError: true,
    ));
    await _fetchGiftVoucher(emit);
  }

  void _onProductRateChanged(
    CreateFaydaBillProductRateChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) {}

  void _onProductAmountChanged(
    CreateFaydaBillProductAmountChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    if (!state.hasDealSelection) {
      final digits = event.amount.replaceAll(RegExp(r'\D'), '');
      emit(state.copyWith(
        productAmount: digits,
        clearGiftVoucherError: true,
      ));
      _scheduleGiftVoucherDebounce();
      return;
    }
  }

  void _onProductMrpChanged(
    CreateFaydaBillProductMrpChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    emit(state.copyWith(productMrp: event.mrp));
  }

  void _onProductGvChanged(
    CreateFaydaBillProductGvChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    emit(state.copyWith(productGv: event.gv));
  }

  void _onProductCashbackChanged(
    CreateFaydaBillProductCashbackChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    emit(state.copyWith(productCashback: event.cashback));
  }

  CartRequestLine? _buildCartRequestLine() {
    final subCat = _resolvedSubCategoryId();
    final mappingInt = _storeSubcategoryMappingIdInt() ?? 0;
    final catId = state.selectedCategoryId ?? 0;
    if (subCat == null) return null;
    final qty = state.productQuantity < 1 ? 1 : state.productQuantity;

    if (state.hasDealSelection) {
      final item = _promotionById(state.selectedPromotionId!);
      if (item == null) return null;
      return CartRequestLine(
        promotionId: item.id,
        productName: item.name,
        mrp: _mrpPerUnitForPromotion(item),
        categoryId: catId,
        subCategoryId: subCat,
        storeSubcategoryMappingId: mappingInt,
        qty: qty,
        cashback: item.cashbackValue ?? 0,
      );
    }
    final mrpUnit = _manualMrpPerUnit();
    if (mrpUnit == null) return null;
    final name =
        state.productName.trim().isEmpty ? 'N/A' : state.productName.trim();
    return CartRequestLine(
      promotionId: null,
      productName: name,
      mrp: mrpUnit,
      categoryId: catId,
      subCategoryId: subCat,
      storeSubcategoryMappingId: mappingInt,
      qty: qty,
      cashback: null,
    );
  }

  Future<void> _onAddToCartPressed(
    CreateFaydaBillAddToCartPressed event,
    Emitter<CreateFaydaBillState> emit,
  ) async {
    if (state.selectedSubcategoryMappingId == null) {
      emit(state.copyWith(
        userToastMessage: 'Please select sub-category first',
      ));
      return;
    }
    if (!state.hasDealSelection) {
      final unit = _manualMrpPerUnit();
      if (unit == null || unit <= 0) {
        emit(state.copyWith(
          userToastMessage: 'Please fill Amount before adding to cart',
        ));
        return;
      }
    }
    // if (!state.isProductDetailsFormComplete) {
    //   emit(state.copyWith(
    //     userToastMessage: 'Please ffffill MRP before adding to cart',
    //   ));
    //   return;
    // }

    final subCat = _resolvedSubCategoryId();
    if (subCat == null) return;

    final newLine = _buildCartRequestLine();
    if (newLine == null) {
      emit(state.copyWith(previewSummaryLoading: false));
      return;
    }

    final cart = [...state.cartRequestLines, newLine];
    await _previewCart(cart, emit, clearProductForm: true);
  }

  Future<void> _onCartLineRemoved(
    CreateFaydaBillCartLineRemoved event,
    Emitter<CreateFaydaBillState> emit,
  ) async {
    final i = event.index;
    if (i < 0 || i >= state.cartRequestLines.length) return;
    final cart = List<CartRequestLine>.from(state.cartRequestLines)..removeAt(i);
    await _previewCart(cart, emit, clearProductForm: false);
  }

  Map<String, dynamic> _buildPreviewBody(
    String storeId,
    List<CartRequestLine> cart,
    String customerPhone,
    String invoiceNumber,
  ) {
    int? extraCoins;
    String extraReason = '';
    if (state.otherBenefitInCart) {
      extraCoins = int.tryParse(state.otherBenefitCashback.trim());
      extraReason = state.otherBenefitReason.trim();
    }
    return <String, dynamic>{
      'storeId': storeId,
      'customerPhone': customerPhone,
      'extraFaydaMXCoins': extraCoins,
      'extraFaydaMXCoinsReason': extraReason,
      'rewardToReferee': null,
      'rewardToReferrer': null,
      'referralCode': '',
      'generateStoreReferral': false,
      'cart': cart.map((e) => e.toJson()).toList(),
      'invoiceNumber': invoiceNumber,
    };
  }

  /// Returns `true` if preview succeeded or cart was cleared; `false` on error.
  Future<bool> _previewCart(
    List<CartRequestLine> cart,
    Emitter<CreateFaydaBillState> emit, {
    required bool clearProductForm,
  }) async {
    final storeId = await _tokenService.getStoreId();
    if (storeId == null || storeId.isEmpty) {
      emit(state.copyWith(previewSummaryLoading: false));
      return false;
    }

    final phone = state.phone;
    final invoice = state.invoiceNumber;

    if (cart.isEmpty) {
      final allowOtherOnly =
          state.otherBenefitInCart && state.allowCoinWithoutGV;
      if (!allowOtherOnly) {
        emit(state.copyWith(
          previewSummaryLoading: false,
          clearPreviewSummary: true,
          cartRequestLines: const [],
          clearProductDetails: clearProductForm,
          clearOtherBenefit: true,
        ));
        return true;
      }
    }

    emit(state.copyWith(
      previewSummaryLoading: true,
      clearGiftVoucherError: true,
    ));

    try {
      final body = _buildPreviewBody(storeId, cart, phone, invoice);
      final data = await _previewCartSummaryUseCase(body);
      emit(state.copyWith(
        previewSummaryLoading: false,
        previewSummary: data,
        cartRequestLines: cart,
        clearProductDetails: clearProductForm,
        clearGiftVoucherError: true,
      ));
      return true;
    } on ServerException catch (e) {
      emit(state.copyWith(
        previewSummaryLoading: false,
        clearGiftVoucherError: true,
        userToastMessage: e.message ?? 'Something went wrong',
      ));
      return false;
    } on NetworkException catch (e) {
      emit(state.copyWith(
        previewSummaryLoading: false,
        clearGiftVoucherError: true,
        userToastMessage: e.message ?? 'No internet connection',
      ));
      return false;
    } catch (e) {
      emit(state.copyWith(
        previewSummaryLoading: false,
        clearGiftVoucherError: true,
        userToastMessage: e.toString(),
      ));
      return false;
    }
  }

  Future<void> _onTransactionConfirmRequested(
    CreateFaydaBillTransactionConfirmRequested event,
    Emitter<CreateFaydaBillState> emit,
  ) async {
    if (state.previewSummary == null) return;
    if (state.cartRequestLines.isEmpty && !state.otherBenefitInCart) return;
    if (state.phone.length != 10) return;

    final pinDigits = event.pin.replaceAll(RegExp(r'\D'), '');
    if (pinDigits.length != 4) {
      emit(state.copyWith(
        cashierTransactionError: 'Enter a valid 4-digit PIN',
      ));
      return;
    }
    final pinInt = int.tryParse(pinDigits);
    if (pinInt == null) {
      emit(state.copyWith(cashierTransactionError: 'Enter a valid 4-digit PIN'));
      return;
    }

    final storeId = await _tokenService.getStoreId();
    if (storeId == null || storeId.isEmpty) {
      emit(state.copyWith(
        cashierTransactionSubmitting: false,
        cashierTransactionError: 'No store assigned',
      ));
      return;
    }

    final sum = state.previewSummary!.summary;
    final referral = state.customerSession?.customer.referralCode ?? '';

    emit(state.copyWith(
      cashierTransactionSubmitting: true,
      clearCashierTransactionError: true,
    ));

    try {
      final body = <String, dynamic>{
        'storeId': storeId,
        'customerPhone': state.phone,
        'extraFaydaMXCoins': sum.extraFaydaMXCoins,
        'rewardToReferee': sum.rewardToReferee,
        'rewardToReferrer': sum.rewardToReferrer,
        'referralCode':"",// referral,
        'generateStoreReferral': false,
        'cart': state.cartRequestLines.map((e) => e.toJson()).toList(),
        'pin': pinInt,
        'isBillSave': event.isBillSave,
        'invoiceNumber': state.invoiceNumber,
        'extraFaydaMXCoinsReason': state.otherBenefitInCart
            ? state.otherBenefitReason.trim()
            : '',
      };
      final data = await _submitCashierTransactionUseCase(body);
      final label = (data.billDisplayId != null && data.billDisplayId!.isNotEmpty)
          ? data.billDisplayId!
          : data.id;
      emit(state.copyWith(
        cashierTransactionSubmitting: false,
        clearCashierTransactionError: true,
        clearPreviewSummary: true,
        cartRequestLines: const [],
        clearProductDetails: true,
        clearOtherBenefit: true,
        transactionSuccessMessage: label,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        cashierTransactionSubmitting: false,
        cashierTransactionError: e.message ?? 'Transaction failed',
      ));
    } catch (e) {
      emit(state.copyWith(
        cashierTransactionSubmitting: false,
        cashierTransactionError: e.toString(),
      ));
    }
  }

  void _onTransactionSuccessConsumed(
    CreateFaydaBillTransactionSuccessConsumed event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    emit(state.copyWith(clearTransactionSuccessMessage: true));
  }

  void _onTransactionErrorCleared(
    CreateFaydaBillTransactionErrorCleared event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    emit(state.copyWith(clearCashierTransactionError: true));
  }

  void _onOtherBenefitReasonChanged(
    CreateFaydaBillOtherBenefitReasonChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    emit(state.copyWith(otherBenefitReason: event.text));
  }

  void _onOtherBenefitCashbackChanged(
    CreateFaydaBillOtherBenefitCashbackChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    emit(state.copyWith(otherBenefitCashback: event.text));
  }

  Future<void> _onOtherBenefitAddToCartPressed(
    CreateFaydaBillOtherBenefitAddToCartPressed event,
    Emitter<CreateFaydaBillState> emit,
  ) async {
    if (state.otherBenefitInCart) return;
    if (state.cartRequestLines.isEmpty && !state.allowCoinWithoutGV) return;
    final r = state.otherBenefitReason.trim();
    final c = int.tryParse(state.otherBenefitCashback.trim());
    if (r.isEmpty || c == null || c < 0 || c > 9999) return;

    emit(state.copyWith(otherBenefitInCart: true));
    final ok = await _previewCart(
      state.cartRequestLines,
      emit,
      clearProductForm: false,
    );
    if (!ok) {
      emit(state.copyWith(otherBenefitInCart: false));
      return;
    }
    emit(state.copyWith(mainTabIndex: 0));
  }

  Future<void> _onOtherBenefitRemoved(
    CreateFaydaBillOtherBenefitRemoved event,
    Emitter<CreateFaydaBillState> emit,
  ) async {
    if (!state.otherBenefitInCart) return;
    emit(state.copyWith(clearOtherBenefit: true));
    await _previewCart(state.cartRequestLines, emit, clearProductForm: false);
  }
}
