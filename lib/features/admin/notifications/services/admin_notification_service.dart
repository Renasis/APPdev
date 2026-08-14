import '../providers/notification_provider.dart';
import '../../products/providers/admin_product_provider.dart';

class AdminNotificationService {
  static bool notificationsEnabled = true;
  static void checkProductStock({
    required AdminProduct product,
    required NotificationProvider notificationProvider,
  }) {

    if (!notificationsEnabled) {
      return;
    }

    if (product.stock <= 2) {
      notificationProvider.addCriticalStockNotification(
        productId: product.id,
        productName: product.name,
        stock: product.stock,
      );

      return;
    }

    if (product.stock <= 5) {
      notificationProvider.addLowStockNotification(
        productId: product.id,
        productName: product.name,
        stock: product.stock,
      );
    }
  }

  static void checkAllProducts({
    required List<AdminProduct> products,
    required NotificationProvider notificationProvider,
  }) {

    if (!notificationsEnabled) {
      return;
    }

    for (final product in products) {
      checkProductStock(
        product: product,
        notificationProvider: notificationProvider,
      );
    }
  }
}