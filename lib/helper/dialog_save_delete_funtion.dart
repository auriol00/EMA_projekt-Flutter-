// lib/utils/dialog_helper.dart

import 'package:flutter/material.dart';

Future<void> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
  String cancelText = "Cancel",
  String confirmText = "Confirm",
  required barrierDismissible,
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelText),
        ),

        // Confirm Button
        TextButton(
          onPressed: () {
            Navigator.pop(context); // close dialog first
            onConfirm(); // then run the confirm logic
          },
          child: Text(confirmText),
        ),
      ],
    ),
  );
}
