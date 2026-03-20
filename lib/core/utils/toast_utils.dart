import 'package:flutter/material.dart';

/// Shows SnackBar toasts. Requires [scaffoldMessengerKey] to be set from [MaterialApp.router].
class ToastUtils {
  ToastUtils._();

  static GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  static void showSuccessToast({required String message}) {
    scaffoldMessengerKey?.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showErrorToast({required String message}) {
    scaffoldMessengerKey?.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
