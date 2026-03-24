import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/errors/exceptions.dart';
import '../../../../core/network/token_service.dart';
import '../../../Cashier/domain/entities/store_full_entity.dart';
import '../../../Cashier/domain/usecases/get_store_detail_usecase.dart';
import '../../data/models/promotions_list_models.dart';
import '../../domain/usecases/fetch_promotions_list_usecase.dart';
import '../../domain/usecases/lookup_customer_by_phone_usecase.dart';
import 'create_faydabill_event.dart';
import 'create_faydabill_state.dart';

class CreateFaydaBillBloc extends Bloc<CreateFaydaBillEvent, CreateFaydaBillState> {
  CreateFaydaBillBloc({
    required GetStoreDetailUseCase getStoreDetailUseCase,
    required LookupCustomerByPhoneUseCase lookupCustomerByPhoneUseCase,
    required FetchPromotionsListUseCase fetchPromotionsListUseCase,
    required TokenService tokenService,
  })  : _getStoreDetailUseCase = getStoreDetailUseCase,
        _lookupCustomerByPhoneUseCase = lookupCustomerByPhoneUseCase,
        _fetchPromotionsListUseCase = fetchPromotionsListUseCase,
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
  }

  final GetStoreDetailUseCase _getStoreDetailUseCase;
  final LookupCustomerByPhoneUseCase _lookupCustomerByPhoneUseCase;
  final FetchPromotionsListUseCase _fetchPromotionsListUseCase;
  final TokenService _tokenService;

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

  void _onPromotionSelected(
    CreateFaydaBillPromotionSelected event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    final item = _promotionById(event.promotionId);
    if (item == null) return;
    if (item.soldOut) return;
    emit(_applyPromotionToProductDetails(state, item));
  }

  CreateFaydaBillState _applyPromotionToProductDetails(
    CreateFaydaBillState current,
    PromotionItemModel item,
  ) {
    const q = 1;
    final rateStr = '${item.offerPriceValue ?? 0}';
    return current.copyWith(
      selectedPromotionId: item.id,
      productName: item.name,
      productQuantity: q,
      productRate: rateStr,
      productAmount: _amountFromRateAndQty(rateStr, q),
      productMrp: '${item.mrpValue ?? 0}',
      productGv: '${item.giftVoutcher ?? 0}',
      productCashback: '${item.cashbackValue ?? 0}',
    );
  }

  static String _amountFromRateAndQty(String rateStr, int qty) {
    final r = int.tryParse(rateStr.trim()) ?? 0;
    final q = qty < 1 ? 1 : qty;
    return '${r * q}';
  }

  void _onProductNameChanged(
    CreateFaydaBillProductNameChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    if (state.hasDealSelection) return;
    emit(state.copyWith(productName: event.name));
  }

  void _onProductQuantityChanged(
    CreateFaydaBillProductQuantityChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    final id = state.selectedPromotionId;
    if (id == null) return;
    final item = _promotionById(id);
    final maxQ = item?.remainingQuantity;
    var q = event.quantity;
    if (q < 1) q = 1;
    if (maxQ != null && maxQ > 0 && q > maxQ) q = maxQ;
    emit(state.copyWith(
      productQuantity: q,
      productAmount: _amountFromRateAndQty(state.productRate, q),
    ));
  }

  void _onProductRateChanged(
    CreateFaydaBillProductRateChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    // Rate is set only from promotion data; never user-edited.
  }

  void _onProductAmountChanged(
    CreateFaydaBillProductAmountChanged event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    if (state.hasDealSelection) return;
    final digits = event.amount.replaceAll(RegExp(r'\D'), '');
    emit(state.copyWith(productAmount: digits));
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

  void _onAddToCartPressed(
    CreateFaydaBillAddToCartPressed event,
    Emitter<CreateFaydaBillState> emit,
  ) {
    if (!state.isProductDetailsFormComplete) return;
    // Cart wiring comes in a follow-up.
  }
}
