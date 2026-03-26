import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/toast_utils.dart';
import '../bloc/create_faydabill_bloc.dart';
import '../bloc/create_faydabill_event.dart';
import '../bloc/create_faydabill_state.dart';

/// "Add Other Benefits" tab — full-bleed pale blue card; [Add to Cart] outside card (like product tab).
class FaydaOtherBenefitsSection extends StatefulWidget {
  const FaydaOtherBenefitsSection({super.key, required this.state});

  final CreateFaydaBillState state;

  static const Color _cardBg = Color(0xFFF0F7FF);
  static const Color _cardBorder = Color(0xFF74B9FF);
  static const Color _labelColor = Color(0xFF64748B);
  static const Color _fieldBorder = Color(0xFFE2E8F0);
  static const Color _disabledCta = Color(0xFF9E9E9E);

  @override
  State<FaydaOtherBenefitsSection> createState() =>
      _FaydaOtherBenefitsSectionState();
}

class _FaydaOtherBenefitsSectionState extends State<FaydaOtherBenefitsSection> {
  late final TextEditingController _reasonCtrl;
  late final TextEditingController _cashbackCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.state;
    _reasonCtrl = TextEditingController(text: s.otherBenefitReason);
    _cashbackCtrl = TextEditingController(text: s.otherBenefitCashback);
  }

  @override
  void didUpdateWidget(covariant FaydaOtherBenefitsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final s = widget.state;
    if (oldWidget.state.otherBenefitReason != s.otherBenefitReason) {
      _reasonCtrl.text = s.otherBenefitReason;
    }
    if (oldWidget.state.otherBenefitCashback != s.otherBenefitCashback) {
      _cashbackCtrl.text = s.otherBenefitCashback;
    }
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _cashbackCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decoration({required String hint, required bool readOnly}) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      filled: true,
      fillColor: readOnly ? const Color(0xFFF3F4F6) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: FaydaOtherBenefitsSection._fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: FaydaOtherBenefitsSection._fieldBorder),
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
    final locked = s.otherBenefitInCart;
    final busy = s.previewSummaryLoading;
    final complete = s.isOtherBenefitFormValid &&
        (s.hasProductLinesInCart || s.allowCoinWithoutGV);
    final canAdd = !locked && complete;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FaydaOtherBenefitsSection._cardBg,
            border: Border.all(
              color: FaydaOtherBenefitsSection._cardBorder,
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
                      size: 22, color: FaydaOtherBenefitsSection._labelColor),
                  const SizedBox(width: 8),
                  Text(
                    'Other Benefits',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: FaydaOtherBenefitsSection._labelColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Reason',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: FaydaOtherBenefitsSection._labelColor,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _reasonCtrl,
                readOnly: locked,
                maxLines: 2,
                onChanged: locked
                    ? (_) {}
                    : (v) => context
                        .read<CreateFaydaBillBloc>()
                        .add(CreateFaydaBillOtherBenefitReasonChanged(v)),
                decoration: _decoration(
                  hint: 'Enter reason',
                  readOnly: locked,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.monetization_on_outlined,
                      size: 18, color: Colors.amber.shade800),
                  const SizedBox(width: 6),
                  Text(
                    'Cashback',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: FaydaOtherBenefitsSection._labelColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _cashbackCtrl,
                readOnly: locked,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: locked
                    ? (_) {}
                    : (v) => context
                        .read<CreateFaydaBillBloc>()
                        .add(CreateFaydaBillOtherBenefitCashbackChanged(v)),
                decoration: _decoration(
                  hint: '0-9999',
                  readOnly: locked,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (s.giftVoucherErrorMessage != null &&
                  s.giftVoucherErrorMessage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    s.giftVoucherErrorMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFC62828),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: canAdd && !busy
                      ? () {
                          if (!s.hasProductLinesInCart &&
                              !s.allowCoinWithoutGV) {
                            ToastUtils.showErrorToast(
                              message:
                                  'Add at least one product to cart before adding other benefits.',
                            );
                            return;
                          }
                          context.read<CreateFaydaBillBloc>().add(
                                const CreateFaydaBillOtherBenefitAddToCartPressed(),
                              );
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: canAdd && !busy
                        ? AppColors.faydaBillChipSelected
                        : FaydaOtherBenefitsSection._disabledCta,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: FaydaOtherBenefitsSection._disabledCta,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: busy
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Please wait…',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Add to Cart',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.send_rounded, size: 18),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
