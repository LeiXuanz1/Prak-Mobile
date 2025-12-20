import 'package:flutter/widgets.dart';
import 'package:my_app/core/services/connectvity_service.dart';
import 'package:my_app/data/sync/product_sync_service.dart';

class AppLifecycleService with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onResume();
    }
  }

  Future<void> _onResume() async {
    final online = await ConnectivityService.isOnline();
    if (online) {
      await ProductSyncService.sync();
    }
  }
}
