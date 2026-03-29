import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/create_faydabill_bloc.dart';
import '../bloc/create_faydabill_event.dart';
import '../bloc/create_faydabill_state.dart';

const Color _kPinBorderIdle = Color(0xFFE0E0E0);
const Color _kPinBorderFocused = Color(0xFF1E3A5F);

/// PIN + “Save Bill Details” — four OTP-style boxes before POST `/api/cashier-transactions`.
Future<void> showFaydaTransactionVerifyDialog(BuildContext context) {
  final bloc = context.read<CreateFaydaBillBloc>();
  bloc.add(const CreateFaydaBillTransactionErrorCleared());
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return _VerifyDialogScaffold(
        animation: animation,
        child: BlocProvider.value(
          value: bloc,
          child: const _FaydaTransactionVerifyDialog(),
        ),
      );
    },
  );
}

class _VerifyDialogScaffold extends StatelessWidget {
  const _VerifyDialogScaffold({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.opaque,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              color: Colors.black.withValues(alpha: 0.38),
            ),
          ),
        ),
        FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _FaydaTransactionVerifyDialog extends StatefulWidget {
  const _FaydaTransactionVerifyDialog();

  @override
  State<_FaydaTransactionVerifyDialog> createState() =>
      _FaydaTransactionVerifyDialogState();
}

class _FaydaTransactionVerifyDialogState
    extends State<_FaydaTransactionVerifyDialog> {
  late final List<TextEditingController> _digits;
  late final List<FocusNode> _focusNodes;
  final ValueNotifier<bool> _saveBillDetails = ValueNotifier<bool>(true);
  final ValueNotifier<int> _pinTick = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _digits = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _saveBillDetails.dispose();
    _pinTick.dispose();
    for (final c in _digits) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _refreshPinUi() => _pinTick.value++;

  String get _pin => _digits.map((c) => c.text).join();

  bool get _pinComplete =>
      _pin.length == 4 && RegExp(r'^\d{4}$').hasMatch(_pin);

  void _onDigitChanged(int i, String raw) {
    final digitsOnly = raw.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 1) {
      _spreadPaste(digitsOnly);
      _refreshPinUi();
      return;
    }
    if (digitsOnly.isEmpty) {
      _digits[i].clear();
      _refreshPinUi();
      if (i > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _focusNodes[i - 1].requestFocus();
          }
        });
      }
      return;
    }
    _digits[i].text = digitsOnly;
    _digits[i].selection = const TextSelection.collapsed(offset: 1);
    if (i < 3) {
      _focusNodes[i + 1].requestFocus();
    } else {
      _focusNodes[i].unfocus();
    }
    _refreshPinUi();
  }

  void _spreadPaste(String digits) {
    final chars = digits.split('');
    for (var k = 0; k < 4; k++) {
      _digits[k].text = k < chars.length ? chars[k] : '';
      if (k < chars.length) {
        _digits[k].selection = const TextSelection.collapsed(offset: 1);
      }
    }
    if (digits.length >= 4) {
      _focusNodes[3].requestFocus();
    } else if (digits.isNotEmpty) {
      _focusNodes[digits.length.clamp(0, 3)].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateFaydaBillBloc, CreateFaydaBillState>(
      listenWhen: (p, c) {
        if (c.transactionSuccessMessage != null &&
            c.transactionSuccessMessage != p.transactionSuccessMessage) {
          return true;
        }
        final err = c.cashierTransactionError;
        if (err != null &&
            err.isNotEmpty &&
            err != p.cashierTransactionError) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state.transactionSuccessMessage != null) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          return;
        }
        final err = state.cashierTransactionError;
        if (err != null && err.isNotEmpty) {
          for (final c in _digits) {
            c.clear();
          }
          _refreshPinUi();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _focusNodes[3].requestFocus();
            }
          });
        }
      },
      child: Material(
        color: Colors.transparent,
        child: Dialog(
          backgroundColor: Colors.white,
          elevation: 8,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: BlocBuilder<CreateFaydaBillBloc, CreateFaydaBillState>(
              builder: (context, state) {
                final submitting = state.cashierTransactionSubmitting;
                final err = state.cashierTransactionError;

                return AnimatedBuilder(
                  animation: Listenable.merge([_pinTick, _saveBillDetails]),
                  builder: (context, _) {
                    return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF263238),
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: submitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const _DottedDivider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter your PIN to confirm the transaction',
                      style: TextStyle(fontSize: 14, color: Color(0xFF546E7A)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (i) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: i == 0 ? 0 : 6,
                              right: i == 3 ? 0 : 6,
                            ),
                            child: AnimatedBuilder(
                              animation: _focusNodes[i],
                              builder: (context, _) {
                                final focused = _focusNodes[i].hasFocus;
                                return TextField(
                                  controller: _digits[i],
                                  focusNode: _focusNodes[i],
                                  enabled: !submitting,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF263238),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    counterText: '',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: _kPinBorderIdle,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: focused
                                            ? _kPinBorderFocused
                                            : _kPinBorderIdle,
                                        width: focused ? 2 : 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: _kPinBorderFocused,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (v) => _onDigitChanged(i, v),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _saveBillDetails.value,
                            activeColor: const Color(0xFF43A047),
                            onChanged: submitting
                                ? null
                                : (v) {
                                    _saveBillDetails.value = v ?? true;
                                  },
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Save Bill Details',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF37474F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (err != null && err.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        err,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFC62828),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: (!_pinComplete || submitting)
                            ? null
                            : () {
                                context.read<CreateFaydaBillBloc>().add(
                                      CreateFaydaBillTransactionConfirmRequested(
                                        pin: _pin,
                                        isBillSave: _saveBillDetails.value,
                                      ),
                                    );
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.faydaBillChipSelected,
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.blueGrey.shade200,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Confirm',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: LayoutBuilder(
        builder: (context, c) {
          return CustomPaint(
            size: Size(c.maxWidth, 1),
            painter: _DottedLinePainter(),
          );
        },
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;
    const dash = 4.0;
    const gap = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
