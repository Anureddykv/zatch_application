import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:zatch/services/api_service.dart';

class SnackBarUtils {
  static void showTopSnackBar(BuildContext context, String message, {bool isError = false}) {
    // Use the root navigator context to ensure the snackbar stays visible during transitions
    final targetContext = ApiService.navigatorKey.currentContext ?? context;

    // Use Future.microtask or Duration.zero to ensure we are outside the build phase
    // This is safer than addPostFrameCallback for triggering overlays during transitions
    Future.delayed(Duration.zero, () {
      if (targetContext.mounted) {
        Flushbar(
          message: message,
          icon: Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 28.0,
            color: isError ? Colors.redAccent : const Color(0xFFCCF656),
          ),
          duration: const Duration(seconds: 3),
          leftBarIndicatorColor: isError ? Colors.redAccent : const Color(0xFFCCF656),
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(12),
          backgroundColor: Colors.black, // Set to pure black
          messageColor: Colors.white,
          boxShadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0.0, 2.0),
              blurRadius: 3.0,
            )
          ],
        ).show(targetContext);
      }
    });
  }
}
