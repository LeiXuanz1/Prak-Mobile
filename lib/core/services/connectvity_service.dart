import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  // cek kondisi internet SEKARANG
  static Future<bool> isOnline() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.isNotEmpty && _hasConnection(result.first);
    } catch (e) {
      log('Connectivity check failed: $e');
      return false;
    }
  }

  // listen perubahan koneksi
  static void listen({
    required void Function() onOnline,
    void Function()? onOffline,
  }) {
    _subscription?.cancel();

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final online = results.isNotEmpty && _hasConnection(results.first);

      log('[Connectivity] ${online ? "ONLINE" : "OFFLINE"}');

      if (online) {
        onOnline();
      } else {
        onOffline?.call();
      }
    });
  }

  static bool _hasConnection(ConnectivityResult result) {
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
