import 'package:flutter/material.dart';
/*

void showLoadingCircle(BuildContext context) {
  showDialog(
    context: context,
    //barrierDismissible: false, // empeche de fermer en cliquant a l'exterieur
    builder: (context) {
      return Center(child: CircularProgressIndicator());
    },
  );
}

void hideLoadingCircle(BuildContext context) {
  Navigator.pop(context);
} */

void showLoadingCircle(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
}

void hideLoadingCircle(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
}
