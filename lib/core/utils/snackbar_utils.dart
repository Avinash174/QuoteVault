import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class SnackbarUtils {
  static void showSuccess(BuildContext context, String title, String message) {
    _show(context, title, message, ContentType.success);
  }

  static void showError(BuildContext context, String title, String message) {
    _show(context, title, message, ContentType.failure);
  }

  static void showWarning(BuildContext context, String title, String message) {
    _show(context, title, message, ContentType.warning);
  }

  static void showHelp(BuildContext context, String title, String message) {
    _show(context, title, message, ContentType.help);
  }

  static void _show(
    BuildContext context,
    String title,
    String message,
    ContentType contentType,
  ) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
