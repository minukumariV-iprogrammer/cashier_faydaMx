import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/toast_utils.dart';

const _outerRadius = 8.0;
const _iconBoxRadius = 8.0;
const _border = Color(0xFFE0E0E0);
const _divider = Color(0xFFEEEEEE);
const _hint = Color(0xFF9E9E9E);
const _iconBoxFill = Color(0xFFF5F5F5);

/// Single outer box, two flat rows, one divider — Figma (no inner corner radius).
class FaydaBillInputCard extends StatelessWidget {
  const FaydaBillInputCard({
    super.key,
    required this.phoneController,
    required this.invoiceController,
    required this.onPhoneChanged,
    required this.onInvoiceChanged,
    this.invoiceEditable = true,
  });

  final TextEditingController phoneController;
  final TextEditingController invoiceController;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onInvoiceChanged;

  /// When false, invoice cannot be focused or edited (e.g. until mobile is 10 digits).
  /// Uses [Focus] + [IgnorePointer] so the field keeps the same visual style as enabled.
  final bool invoiceEditable;

  static InputDecoration _baseDecoration(String? hint) {
    return InputDecoration(
      isDense: true,
      filled: false,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: _hint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_outerRadius),
          border: Border.all(color: _border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: const InputDecorationTheme(
              filled: false,
              border: InputBorder.none,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _IconBox(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        textInputAction: TextInputAction.next,
                        style: textStyle,
                        cursorColor: Colors.black54,
                        decoration: _baseDecoration('Customer Mobile Number').copyWith(
                          counterText: '',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          MobileNumberFormatter(),
                        ],
                        onChanged: onPhoneChanged,
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, width: double.infinity, color: _divider),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _IconBox(icon: Icons.receipt_long_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Focus(
                        canRequestFocus: invoiceEditable,
                        child: IgnorePointer(
                          ignoring: !invoiceEditable,
                          child: TextField(
                            controller: invoiceController,
                            textInputAction: TextInputAction.done,
                            style: textStyle,
                            cursorColor: Colors.black54,
                            decoration:
                                _baseDecoration('Bill/ Invoice Number'),
                            onChanged: onInvoiceChanged,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({this.icon = Icons.person_outline_rounded});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _iconBoxFill,
        borderRadius: BorderRadius.circular(_iconBoxRadius),
      ),
      child: Icon(
        icon,
        size: 22,
        color: const Color(0xFF757575),
      ),
    );
  }
}

class MobileNumberFormatter extends TextInputFormatter {
  DateTime? _lastToastTime;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    final firstDigit = text[0];

    if (!['6', '7', '8', '9'].contains(firstDigit)) {
      final now = DateTime.now();

      if (_lastToastTime == null ||
          now.difference(_lastToastTime!) > const Duration(seconds: 1)) {
        _lastToastTime = now;

        ToastUtils.showErrorToast(
          message: "Mobile number must start with 6, 7, 8, or 9",
        );
      }

      return oldValue;
    }

    return newValue;
  }
}
