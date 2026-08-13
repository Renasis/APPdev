import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

// CUSTOMER PROVIDERS
import 'features/customer/products/providers/product_provider.dart';
import 'features/customer/wishlist/providers/wishlist_provider.dart';
import 'features/customer/cart/providers/cart_provider.dart';
import 'features/customer/orders/providers/order_provider.dart';
import 'features/customer/checkout/providers/checkout_provider.dart';
import 'features/customer/address/providers/address_provider.dart';
import 'features/customer/profile/providers/profile_provider.dart';
import 'features/customer/notifications/providers/notification_provider.dart'
    as customer_notifications;
import 'features/customer/reviews/providers/review_provider.dart';
import 'features/customer/products/providers/comparison_provider.dart';
import 'features/customer/products/providers/recently_viewed_provider.dart';
import 'features/customer/saved_builds/providers/saved_build_provider.dart';
import 'features/customer/pc_builder/providers/pc_builder_provider.dart';
import 'features/customer/support/providers/support_provider.dart';

// ADMIN PROVIDERS
import 'features/admin/products/providers/admin_product_provider.dart';
import 'features/admin/inventory/providers/inventory_provider.dart';
import 'features/admin/suppliers/providers/supplier_provider.dart';
import 'features/admin/purchase_orders/providers/purchase_order_provider.dart';
import 'features/admin/staff/providers/staff_provider.dart';
import 'features/admin/sales/providers/sales_provider.dart';
import 'features/admin/customers/providers/customer_provider.dart';
import 'features/admin/reports/providers/reports_provider.dart';
import 'package:pc_parts_application/features/admin/notifications/providers/notification_provider.dart'
    as admin_notifications;
import 'features/admin/settings/providers/admin_settings_provider.dart';
import 'features/staff/notifications/providers/staff_notification_provider.dart';
import 'features/staff/notifications/providers/staff_notification_settings_provider.dart';




void main() {
  runApp(
    MultiProvider(
      providers: [
        // ========================================
        // CUSTOMER
        // ========================================

        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => WishlistProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => CheckoutProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => AddressProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => SupportProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              customer_notifications.NotificationProvider(),
        ),

        ChangeNotifierProxyProvider<
            customer_notifications.NotificationProvider,
            OrderProvider>(
          create: (_) => OrderProvider(),
          update: (
            context,
            notificationProvider,
            orderProvider,
          ) {
            final provider = orderProvider ?? OrderProvider();
            provider.setNotificationProvider(notificationProvider);
            return provider;
          },
        ),

        ChangeNotifierProvider(
          create: (_) => ReviewProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ComparisonProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => RecentlyViewedProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => SavedBuildProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => PcBuilderProvider(),
        ),

        // ========================================
        // ADMIN
        // ========================================

        ChangeNotifierProvider(
          create: (_) =>
              admin_notifications.NotificationProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => AdminProductProvider(),
        ),

        ChangeNotifierProxyProvider2<
            admin_notifications.NotificationProvider,
            OrderProvider,
            InventoryProvider>(
          create: (_) => InventoryProvider(),
          update: (
            context,
            notificationProvider,
            orderProvider,
            inventoryProvider,
          ) {
            final provider = inventoryProvider ?? InventoryProvider();

            provider.setNotificationProvider(
              notificationProvider,
            );

            provider.syncCompletedOrders(
              orderProvider.orders,
            );

            return provider;
          },
        ),

        ChangeNotifierProxyProvider<InventoryProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (context, inventoryProvider, cartProvider) {
            final provider = cartProvider ?? CartProvider();
            provider.setInventoryProvider(inventoryProvider);
            return provider;
          },
        ),

        ChangeNotifierProvider(
          create: (_) => StaffNotificationSettingsProvider(),
        ),

        ChangeNotifierProxyProvider3<
            OrderProvider,
            InventoryProvider,
            StaffNotificationSettingsProvider,
            StaffNotificationProvider>(
          create: (_) => StaffNotificationProvider(),
          update: (
            context,
            orderProvider,
            inventoryProvider,
            settingsProvider,
            staffNotificationProvider,
          ) {
            final provider =
                staffNotificationProvider ?? StaffNotificationProvider();
            provider.sync(
              orders: orderProvider.orders,
              inventoryItems: inventoryProvider.items,
              newOrderAlertsEnabled: settingsProvider.newOrderAlertsEnabled,
              lowStockAlertsEnabled: settingsProvider.lowStockAlertsEnabled,
              criticalStockAlertsEnabled:
                  settingsProvider.criticalStockAlertsEnabled,
            );
            return provider;
          },
        ),

        ChangeNotifierProvider(
          create: (_) => SupplierProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => PurchaseOrderProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => StaffProvider(),
        ),

        ChangeNotifierProxyProvider<
            OrderProvider,
            SalesProvider>(
          create: (_) => SalesProvider(),
          update: (
            context,
            orderProvider,
            salesProvider,
          ) {
            salesProvider!.updateFromOrders(
              orderProvider.orders,
            );

            return salesProvider;
          },
        ),

        ChangeNotifierProvider(
          create: (_) => CustomerProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ReportsProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => AdminSettingsProvider(),
        ),

        // ADMIN NOTIFICATIONS
        
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'End PC Parts',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
