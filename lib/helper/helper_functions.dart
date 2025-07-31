import 'package:flutter/material.dart';


void displayMessageToUser(String message, BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Fehler'),
      content: Text(message),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

String getFriendlyErrorMessage(String error) {
  if (error.contains('user-not-found')) {
    return 'Kein Benutzer mit dieser Email gefunden.';
  } else if (error.contains('wrong-password')) {
    return 'Falsches Passwort. Bitte erneut versuchen.';
  } else if (error.contains('network-request-failed')) {
    return 'Netzwerkfehler. Überprüfe deine Internetverbindung.';
  } else if (error.contains('invalid-email')) {
    return 'Ungültige Email-Adresse.';
  } else if (error.contains('email-already-in-use')) {
    return 'Diese Email wird bereits verwendet.';
  } else if (error.contains('too-many-requests')) {
    return 'Zu viele Anfragen. Bitte später erneut versuchen.';
  } else {
    return 'Ein unbekannter Fehler ist aufgetreten.';
  }
}
