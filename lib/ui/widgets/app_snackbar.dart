import 'package:flutter/material.dart';

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarAction? action,
    bool isError = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: action,
          backgroundColor: isError
              ? colorScheme.errorContainer
              : Theme.of(context).snackBarTheme.backgroundColor,
        ),
      );
  }
}
