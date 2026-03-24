import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/promotions_list_models.dart';
import '../bloc/create_faydabill_bloc.dart';
import '../bloc/create_faydabill_event.dart';
import '../bloc/create_faydabill_state.dart';

/// Pale blue card + form matching FaydaBill product-details design.
/// Colored container is full-bleed (screen width); inner fields keep horizontal inset.
class FaydaProductDetailsSection extends StatefulWidget {
  const FaydaProductDetailsSection({super.key, required this.state});

  final CreateFaydaBillState state;

  static const Color _cardBg = Color(0xFFF0F7FF);
  static const Color _cardBorder = Color(0xFF74B9FF);
  static const Color _labelColor = Color(0xFF64748B);
  static const Color _fieldBorder = Color(0xFFE2E8F0);
  static const Color _disabledCta = Color(0xFF9E9E9E);
  static const Color _disabledFill = Color(0xFFF3F4F6);

  @override
  State<FaydaProductDetailsSection> createState() =>
      _FaydaProductDetailsSectionState();
}

class _FaydaProductDetailsSectionState extends State<FaydaProductDetailsSection> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _mrpCtrl;
  late final TextEditingController _gvCtrl;
  late final TextEditingController _cashbackCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.state;
    _nameCtrl = TextEditingController(text: s.productName);
    _rateCtrl = TextEditingController(text: s.productRate);
    _amountCtrl = TextEditingController(text: s.productAmount);
    _mrpCtrl = TextEditingController(text: s.productMrp);
    _gvCtrl = TextEditingController(text: s.productGv);
    _cashbackCtrl = TextEditingController(text: s.productCashback);
  }

  @override
  void didUpdateWidget(covariant FaydaProductDetailsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final idChanged =
        oldWidget.state.selectedPromotionId != widget.state.selectedPromotionId;
    final subChanged = oldWidget.state.selectedSubcategoryMappingId !=
        widget.state.selectedSubcategoryMappingId;
    final catChanged =
        oldWidget.state.selectedCategoryId != widget.state.selectedCategoryId;
    if (idChanged || subChanged || catChanged) {
      final s = widget.state;
      _nameCtrl.text = s.productName;
      _rateCtrl.text = s.productRate;
      _amountCtrl.text = s.productAmount;
      _mrpCtrl.text = s.productMrp;
      _gvCtrl.text = s.productGv;
      _cashbackCtrl.text = s.productCashback;
    } else if (widget.state.hasDealSelection &&
        oldWidget.state.productAmount != widget.state.productAmount) {
      _amountCtrl.text = widget.state.productAmount;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rateCtrl.dispose();
    _amountCtrl.dispose();
    _mrpCtrl.dispose();
    _gvCtrl.dispose();
    _cashbackCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({String? hint, required bool enabled}) {
    final fill = enabled ? Colors.white : FaydaProductDetailsSection._disabledFill;
    return InputDecoration(
      isDense: true,
      hintText: hint,
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: FaydaProductDetailsSection._fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: FaydaProductDetailsSection._fieldBorder),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: FaydaProductDetailsSection._fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.faydaBillChipSelected.withOpacity(0.85),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final promotions = s.promotions;
    final selectablePromotions =
        promotions.where((p) => !p.soldOut).toList(growable: false);
    final complete = s.isProductDetailsFormComplete;
    final hasDeal = s.hasDealSelection;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FaydaProductDetailsSection._cardBg,
            border: Border.all(
              color: FaydaProductDetailsSection._cardBorder,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 22, color: FaydaProductDetailsSection._labelColor),
                  const SizedBox(width: 8),
                  Text(
                    'Product Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: FaydaProductDetailsSection._labelColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _label('Promotion ID'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _dropdownValue(selectablePromotions, s.selectedPromotionId),
                decoration: _fieldDecoration(hint: 'Select promotion', enabled: true),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: [
                  for (final p in selectablePromotions)
                    DropdownMenuItem<String>(
                      value: p.id,
                      child: Text(
                        p.uniqueId.isNotEmpty ? p.uniqueId : p.id,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: selectablePromotions.isEmpty
                    ? null
                    : (id) {
                        if (id == null) return;
                        context
                            .read<CreateFaydaBillBloc>()
                            .add(CreateFaydaBillPromotionSelected(id));
                      },
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('Product Name'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameCtrl,
                          enabled: !hasDeal,
                          onChanged: hasDeal
                              ? null
                              : (v) => context
                                  .read<CreateFaydaBillBloc>()
                                  .add(CreateFaydaBillProductNameChanged(v)),
                          decoration: _fieldDecoration(enabled: !hasDeal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('Quantity'),
                        const SizedBox(height: 6),
                        _QuantityStepper(
                          quantity: s.productQuantity,
                          maxQuantity: _maxQtyForSelection(s),
                          interactive: hasDeal,
                          onChanged: (q) => context
                              .read<CreateFaydaBillBloc>()
                              .add(CreateFaydaBillProductQuantityChanged(q)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('Rate'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _rateCtrl,
                          enabled: false,
                          keyboardType: TextInputType.number,
                          decoration: _fieldDecoration(enabled: false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('Amount'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _amountCtrl,
                          enabled: !hasDeal,
                          keyboardType: TextInputType.number,
                          inputFormatters: hasDeal
                              ? null
                              :  <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ] ,
                          onChanged: hasDeal
                              ? null
                              : (v) => context
                                  .read<CreateFaydaBillBloc>()
                                  .add(CreateFaydaBillProductAmountChanged(v)),
                          decoration: _fieldDecoration(enabled: !hasDeal),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('MRP'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _mrpCtrl,
                          enabled: false,
                          keyboardType: TextInputType.number,
                          decoration: _fieldDecoration(enabled: false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('GV'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _gvCtrl,
                          enabled: false,
                          keyboardType: TextInputType.number,
                          decoration: _fieldDecoration(enabled: false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _label('Cashback'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _cashbackCtrl,
                    enabled: false,
                    keyboardType: TextInputType.number,
                    decoration: _fieldDecoration(enabled: false),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: complete
                  ? () => context
                      .read<CreateFaydaBillBloc>()
                      .add(const CreateFaydaBillAddToCartPressed())
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: complete
                    ? AppColors.faydaBillChipSelected
                    : FaydaProductDetailsSection._disabledCta,
                foregroundColor: Colors.white,
                disabledBackgroundColor: FaydaProductDetailsSection._disabledCta,
                disabledForegroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              // icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text(
                'Add to Cart',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: FaydaProductDetailsSection._labelColor,
      ),
    );
  }

  static String? _dropdownValue(
      List<PromotionItemModel> promotions, String? selectedId) {
    if (selectedId == null || promotions.isEmpty) return null;
    for (final p in promotions) {
      if (p.id == selectedId) return selectedId;
    }
    return null;
  }

  static int? _maxQtyForSelection(CreateFaydaBillState s) {
    final id = s.selectedPromotionId;
    if (id == null) return null;
    for (final p in s.promotions) {
      if (p.id == id) return p.remainingQuantity;
    }
    return null;
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.maxQuantity,
    required this.interactive,
    required this.onChanged,
  });

  final int quantity;
  final int? maxQuantity;
  final bool interactive;
  final ValueChanged<int> onChanged;

  static const Color _border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final maxQ = maxQuantity;
    final canInc = interactive &&
        (maxQ == null || (maxQ > 0 && quantity < maxQ));
    final canDec = interactive && quantity > 1;

    return Container(
      decoration: BoxDecoration(
        color: interactive ? Colors.white : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          _StepperBtn(
            icon: Icons.remove,
            onTap: canDec ? () => onChanged(quantity - 1) : null,
          ),
          Expanded(
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          _StepperBtn(
            icon: Icons.add,
            onTap: canInc ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? const Color(0xFF475569) : const Color(0xFFB0BEC5),
          ),
        ),
      ),
    );
  }
}
