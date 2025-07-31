import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:moonflow/utilities/app_localizations.dart';

class OfflineNotifier {
  final BuildContext context;
  final Connectivity _connectivity = Connectivity();
  late final Stream<List<ConnectivityResult>> _stream;

  final ValueNotifier<bool> isOffline = ValueNotifier<bool>(false);

  OfflineNotifier({required this.context}) {
    _stream = _connectivity.onConnectivityChanged;
    _stream.listen(_handleConnectivityChange);
    _checkInitialConnection();
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final offlineNow = results.contains(ConnectivityResult.none);

    if (offlineNow && !isOffline.value) {
      isOffline.value = true;

      Timer(const Duration(seconds: 5), () {
      if (isOffline.value) {
        isOffline.value = false;
      }
    });
      //_showOfflineSnackbar();
    } else if (!offlineNow && isOffline.value) {
      isOffline.value = false;
      _showOnlineSnackbar();
    }
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    final offlineNow = result == ConnectivityResult.none;

    if (offlineNow && !isOffline.value) {
      isOffline.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //_showOfflineSnackbar();
      });
    }
  }

/*void _showOfflineSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.translate(context, 'offline_mode')),
        backgroundColor: Colors.grey,
        duration: const Duration(days: 1),
      ),
    );
  } */

  void _showOnlineSnackbar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.translate(context, 'online_mode')),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
