import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../services/notification_service.dart';

class NotificationController extends GetxController {
  final RxnString pendingProductId = RxnString();

  @override
  void onReady() {
    super.onReady();

    final productId = NotificationService.pendingProductId;

    if (productId != null) {
      NotificationService.pendingProductId = null;

      Get.toNamed(
        AppRoutes.hiveProducts,
        arguments: productId,
      );
    }
  }
}
