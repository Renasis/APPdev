import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

// AUTHENTICATION
import 'features/authentication/providers/auth_provider.dart';
import 'features/authentication/services/auth_service.dart';
import 'features/authentication/services/user_service.dart';

// CUSTOMER PROVIDERS
import 'features/customer/products/providers/product_provider.dart';
import 'features/customer/products/repository/product_repository.dart';
import 'features/customer/orders/repository/order_repository.dart';
import 'features/admin/inventory/repository/inventory_repository.dart';
import 'features/customer/wishlist/providers/wishlist_provider.dart';
import 'features/customer/cart/providers/cart_provider.dart';
import 'features/customer/orders/providers/order_provider.dart';
import 'features/customer/checkout/providers/checkout_provider.dart';
import 'features/customer/address/providers/address_provider.dart';
import 'features/customer/profile/providers/profile_provider.dart';
import 'features/customer/notifications/providers/notification_provider.dart'
    as customer_notifications;
import 'features/shared/notifications/repository/notification_repository.dart';
import 'features/customer/reviews/providers/review_provider.dart';
import 'features/customer/products/providers/comparison_provider.dart';
import 'features/customer/products/providers/recently_viewed_provider.dart';
import 'features/customer/saved_builds/providers/saved_build_provider.dart';
import 'features/customer/pc_builder/providers/pc_builder_provider.dart';
import 'features/customer/support/providers/support_provider.dart';
import 'features/customer/support/repository/support_repository.dart';

// ADMIN PROVIDERS
import 'features/admin/products/providers/admin_product_provider.dart';
import 'features/admin/inventory/providers/inventory_provider.dart';
import 'features/admin/suppliers/providers/supplier_provider.dart';
import 'features/admin/suppliers/repository/supplier_repository.dart';
import 'features/admin/purchase_orders/providers/purchase_order_provider.dart';
import 'features/admin/staff/providers/staff_provider.dart';
import 'features/admin/staff/services/staff_account_service.dart';
import 'features/admin/sales/providers/sales_provider.dart';
import 'features/admin/sales/providers/walk_in_sale_provider.dart';
import 'features/admin/sales/repository/walk_in_sale_repository.dart';
import 'features/admin/customers/providers/customer_provider.dart';
import 'features/admin/reports/providers/reports_provider.dart';
import 'package:pc_parts_application/features/admin/notifications/providers/notification_provider.dart'
    as admin_notifications;
import 'features/admin/settings/providers/admin_settings_provider.dart';
import 'features/staff/notifications/providers/staff_notification_provider.dart';
import 'features/staff/notifications/providers/staff_notification_settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final productRepository = ProductRepository();
  final inventoryRepository = InventoryRepository();
  final orderRepository = OrderRepository();
  final supplierRepository = SupplierRepository();
  final purchaseOrderRepository = PurchaseOrderRepository();
  final userService = UserService();
  final notificationRepository = NotificationRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            FirebaseAuthService(),
            userService,
            StaffAccountService(),
          ),
        ),

        Provider<UserService>(
          create: (_) => userService,
        ),

        // ========================================
        // CUSTOMER
        // ========================================
        ChangeNotifierProvider(
          create: (_) => ProductProvider(repository: productRepository),
        ),

        ChangeNotifierProvider(create: (_) => WishlistProvider()),

        ChangeNotifierProvider(create: (_) => CheckoutProvider()),

        ChangeNotifierProvider(create: (_) => AddressProvider()),

        ChangeNotifierProxyProvider2<
          AuthProvider,
          UserService,
          ProfileProvider
        >(
          create: (context) {
            return ProfileProvider(
              userService: context.read<UserService>(),
              authProvider: context.read<AuthProvider>(),
            );
          },
          update: (context, authProvider, userService, profileProvider) {
            return profileProvider ?? ProfileProvider(
              userService: userService,
              authProvider: authProvider,
            );
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, SupportProvider>(
          create: (context) {
            return SupportProvider(
              repository: SupportRepository(),
              authProvider: context.read<AuthProvider>(),
            );
          },
          update: (context, authProvider, supportProvider) {
            final provider = supportProvider ?? SupportProvider(
              repository: SupportRepository(),
              authProvider: authProvider,
            );
            return provider;
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, customer_notifications.NotificationProvider>(
          create: (context) {
            return customer_notifications.NotificationProvider(
              repository: notificationRepository,
              recipientUid: context.read<AuthProvider>().currentUser?.id,
            );
          },
          update: (context, authProvider, notificationProvider) {
            final provider = notificationProvider ?? customer_notifications.NotificationProvider();
            final uid = authProvider.currentUser?.id;
            provider.setRecipientUid(uid);
            return provider;
          },
        ),

        ChangeNotifierProxyProvider<
          customer_notifications.NotificationProvider,
          OrderProvider
        >(
          create: (_) => OrderProvider(repository: orderRepository),
          update: (context, notificationProvider, orderProvider) {
            final provider =
                orderProvider ?? OrderProvider(repository: orderRepository);
            provider.setNotificationProvider(notificationProvider);
            return provider;
          },
        ),

        ChangeNotifierProvider(create: (_) => ReviewProvider()),

        ChangeNotifierProvider(create: (_) => ComparisonProvider()),

        ChangeNotifierProvider(create: (_) => RecentlyViewedProvider()),

        ChangeNotifierProvider(create: (_) => SavedBuildProvider()),

        ChangeNotifierProvider(create: (_) => PcBuilderProvider()),

        // ========================================
        // ADMIN
        // ========================================
        ChangeNotifierProxyProvider<AuthProvider, admin_notifications.NotificationProvider>(
          create: (context) {
            return admin_notifications.NotificationProvider(
              repository: notificationRepository,
              recipientUid: context.read<AuthProvider>().currentUser?.id,
            );
          },
          update: (context, authProvider, notificationProvider) {
            final provider = notificationProvider ?? admin_notifications.NotificationProvider();
            final uid = authProvider.currentUser?.id;
            provider.setRecipientUid(uid);
            return provider;
          },
        ),

        ChangeNotifierProvider(
          create: (_) => AdminProductProvider(repository: productRepository),
        ),

        ChangeNotifierProxyProvider3<
          admin_notifications.NotificationProvider,
          OrderProvider,
          AuthProvider,
          InventoryProvider
        >(
          create: (_) => InventoryProvider(repository: inventoryRepository),
          update:
              (
                context,
                notificationProvider,
                orderProvider,
                authProvider,
                inventoryProvider,
              ) {
                final provider =
                    inventoryProvider ??
                    InventoryProvider(repository: inventoryRepository);

                provider.setNotificationProvider(notificationProvider);

                provider.syncCompletedOrders(orderProvider.orders);

                if (authProvider.currentUser != null) {
                  final user = authProvider.currentUser!;
                  provider.setPerformedBy(
                    uid: user.id,
                    name: user.fullName,
                    role: user.role.name,
                  );
                }

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

        ChangeNotifierProxyProvider4<
          OrderProvider,
          InventoryProvider,
          StaffNotificationSettingsProvider,
          AuthProvider,
          StaffNotificationProvider
        >(
          create: (context) {
            return StaffNotificationProvider(
              repository: notificationRepository,
              recipientUid: context.read<AuthProvider>().currentUser?.id,
            );
          },
          update:
              (
                context,
                orderProvider,
                inventoryProvider,
                settingsProvider,
                authProvider,
                staffNotificationProvider,
              ) {
                final provider =
                    staffNotificationProvider ?? StaffNotificationProvider(
                  repository: notificationRepository,
                );
                final uid = authProvider.currentUser?.id;
                provider.setRecipientUid(uid);
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
          create: (_) => SupplierProvider(repository: supplierRepository),
        ),

        ChangeNotifierProvider(
          create: (_) => PurchaseOrderProvider(repository: purchaseOrderRepository),
        ),

        ChangeNotifierProxyProvider<AuthProvider, StaffProvider>(
          create: (_) => StaffProvider(StaffAccountService()),
          update: (context, authProvider, staffProvider) {
            final provider = staffProvider ?? StaffProvider(StaffAccountService());
            provider.setAuthProvider(authProvider);
            return provider;
          },
        ),

        ChangeNotifierProxyProvider<OrderProvider, SalesProvider>(
          create: (context) {
            final orderProvider = context.read<OrderProvider>();
            return SalesProvider(orderProvider: orderProvider);
          },
          update: (context, orderProvider, salesProvider) {
            return salesProvider ?? SalesProvider(orderProvider: orderProvider);
          },
        ),

        ChangeNotifierProxyProvider<InventoryProvider, WalkInSaleProvider>(
          create: (context) {
            return WalkInSaleProvider(
              repository: WalkInSaleRepository(),
            );
          },
          update: (context, inventoryProvider, walkInSaleProvider) {
            final provider =
                walkInSaleProvider ?? WalkInSaleProvider(
              repository: WalkInSaleRepository(),
            );
            provider.setInventoryProvider(inventoryProvider);
            return provider;
          },
        ),

        ChangeNotifierProxyProvider2<
          UserService,
          OrderProvider,
          CustomerProvider
        >(
          create: (context) {
            final userService = context.read<UserService>();
            final orderProvider = context.read<OrderProvider>();
            return CustomerProvider(
              userService: userService,
              orderProvider: orderProvider,
            );
          },
          update: (context, userService, orderProvider, customerProvider) {
            return customerProvider ?? CustomerProvider(
              userService: userService,
              orderProvider: orderProvider,
            );
          },
        ),

        ChangeNotifierProxyProvider5<
          SalesProvider,
          AdminProductProvider,
          PurchaseOrderProvider,
          OrderProvider,
          AuthProvider,
          ReportsProvider
        >(
          create: (context) {
            return ReportsProvider(
              salesProvider: context.read<SalesProvider>(),
              productProvider: context.read<AdminProductProvider>(),
              purchaseOrderProvider: context.read<PurchaseOrderProvider>(),
              orderProvider: context.read<OrderProvider>(),
              authProvider: context.read<AuthProvider>(),
            );
          },
          update: (
            context,
            salesProvider,
            productProvider,
            purchaseOrderProvider,
            orderProvider,
            authProvider,
            reportsProvider,
          ) {
            return reportsProvider ?? ReportsProvider(
              salesProvider: salesProvider,
              productProvider: productProvider,
              purchaseOrderProvider: purchaseOrderProvider,
              orderProvider: orderProvider,
              authProvider: authProvider,
            );
          },
        ),

        ChangeNotifierProxyProvider2<
          AuthProvider,
          UserService,
          AdminSettingsProvider
        >(
          create: (context) {
            return AdminSettingsProvider(
              userService: context.read<UserService>(),
              authProvider: context.read<AuthProvider>(),
            );
          },
          update: (context, authProvider, userService, adminSettingsProvider) {
            return adminSettingsProvider ?? AdminSettingsProvider(
              userService: userService,
              authProvider: authProvider,
            );
          },
        ),

        // ADMIN NOTIFICATIONS
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
