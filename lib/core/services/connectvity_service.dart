import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  // cek kondisi internet SEKARANG
  static Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  // listen perubahan koneksi
  static void listen({
    required void Function() onOnline,
    void Function()? onOffline,
  }) {
    _subscription?.cancel();

    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        final online = _hasConnection(results);

        log('[Connectivity] ${online ? "ONLINE" : "OFFLINE"}');

        if (online) {
          onOnline();
        } else {
          onOffline?.call();
        }
      },
    );
  }

  static bool _hasConnection(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
