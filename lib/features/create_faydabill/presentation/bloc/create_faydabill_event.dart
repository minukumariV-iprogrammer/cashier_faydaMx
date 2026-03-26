import 'package:equatable/equatable.dart';

abstract class CreateFaydaBillEvent extends Equatable {
  const CreateFaydaBillEvent();
  @override
  List<Object?> get props => [];
}

class CreateFaydaBillStarted extends CreateFaydaBillEvent {
  const CreateFaydaBillStarted();
}

class CreateFaydaBillPhoneChanged extends CreateFaydaBillEvent {
  const CreateFaydaBillPhoneChanged(this.phone);
  final String phone;
  @override
  List<Object?> get props => [phone];
}

class CreateFaydaBillInvoiceChanged extends CreateFaydaBillEvent {
  const CreateFaydaBillInvoiceChanged(this.invoice);
  final String invoice;
  @override
  List<Object?> get props => [invoice];
}

class CreateFaydaBillMainTabChanged extends CreateFaydaBillEvent {
  const CreateFaydaBillMainTabChanged(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

class CreateFaydaBillCategorySelected extends CreateFaydaBillEvent {
  const CreateFaydaBillCategorySelected(this.categoryId);
  final int categoryId;
  @override
  List<Object?> get props => [categoryId];
}

class CreateFaydaBillSubcategorySelected extends CreateFaydaBillEvent {
  const CreateFaydaBillSubcategorySelected(this.mappingId);
  final String mappingId;
  @override
  List<Object?> get props => [mappingId];
}

/// Selects a promotion from the dropdown or from an active-deal card.
class CreateFaydaBillPromotionSelected extends CreateFaydaBillEvent {
  const CreateFaydaBillPromotionSelected(this.promotionId);
  final String promotionId;
  @override
  List<Object?> get props => [promotionId];
}

class CreateFaydaBillProductNameChanged extends CreateFaydaBillEvent {
  const CreateFaydaBillProductNameChanged(this.name);
  final String name;
  @override
  List<Object?> get props => [name];
}

class CreateFaydaBillProductQuantityChanged extends CreateFaydaBillEvent {
  const CreateFaydaBillProductQuantityChanged(this.quantity);
  final int quantity;
  @override
  List<Object?> get props => [quantity];
}

class CreateFaydaBillProductRateChanged extends CreateFaydaBillEvent {
  const CreateFaydaBillProductRateChanged(this.rate);
  final String rate;
  @override
  List<Object?> get props => [rate];
}

class CreateFaydaBillProductAmountChanged extends CreateFaydaBillEvent {
  const CreateFaydaBillProductAmountChanged(this.amount);
  final String amount;
  @override
  List<Object?> get props => [amount];
}

class CreateFaydaBillProductMrpChanged extends CreateFaydaBillEvent {
  const CreateFaydaBillProductMrpChanged(this.mrp);
  final String mrp;
  @override
  List<Object?> get props => [mrp];
}

class CreateFaydaBillProductGvChanged extends CreateFaydaBillEvent {
  const CreateFaydaBillProductGvChanged(this.gv);
  final String gv;
  @override
  List<Object?> get props => [gv];
}

class CreateFaydaBillProductCashbackChanged extends CreateFaydaBillEvent {
  const CreateFaydaBillProductCashbackChanged(this.cashback);
  final String cashback;
  @override
  List<Object?> get props => [cashback];
}

class CreateFaydaBillAddToCartPressed extends CreateFaydaBillEvent {
  const CreateFaydaBillAddToCartPressed();
}

/// Recalculates GV via `/api/store/calculate-gift-voucher` (quantity / debounced amount).
class CreateFaydaBillGiftVoucherFetch extends CreateFaydaBillEvent {
  const CreateFaydaBillGiftVoucherFetch();
}

/// Removes one cart line (by index) and refreshes preview-summary.
class CreateFaydaBillCartLineRemoved extends CreateFaydaBillEvent {
  const CreateFaydaBillCartLineRemoved(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

/// POST `/api/cashier-transactions` with PIN + cart.
class CreateFaydaBillTransactionConfirmRequested extends CreateFaydaBillEvent {
  const CreateFaydaBillTransactionConfirmRequested({
    required this.pin,
    required this.isBillSave,
  });
  final String pin;
  final bool isBillSave;
  @override
  List<Object?> get props => [pin, isBillSave];
}

/// Clears [CreateFaydaBillState.transactionSuccessMessage] after UI handled it.
class CreateFaydaBillTransactionSuccessConsumed extends CreateFaydaBillEvent {
  const CreateFaydaBillTransactionSuccessConsumed();
}

/// Clears PIN / submit error before opening verify dialog or retrying.
class CreateFaydaBillTransactionErrorCleared extends CreateFaydaBillEvent {
  const CreateFaydaBillTransactionErrorCleared();
}

class CreateFaydaBillOtherBenefitReasonChanged extends CreateFaydaBillEvent {
  const CreateFaydaBillOtherBenefitReasonChanged(this.text);
  final String text;
  @override
  List<Object?> get props => [text];
}

class CreateFaydaBillOtherBenefitCashbackChanged extends CreateFaydaBillEvent {
  const CreateFaydaBillOtherBenefitCashbackChanged(this.text);
  final String text;
  @override
  List<Object?> get props => [text];
}

/// Preview-summary with [extraFaydaMXCoins] + reason; switches to product tab after success.
class CreateFaydaBillOtherBenefitAddToCartPressed extends CreateFaydaBillEvent {
  const CreateFaydaBillOtherBenefitAddToCartPressed();
}

/// Clears other-benefit extra coins from preview (user deleted the card in summary).
class CreateFaydaBillOtherBenefitRemoved extends CreateFaydaBillEvent {
  const CreateFaydaBillOtherBenefitRemoved();
}
