import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/settings_model.dart';
import '../../features/onboarding/language_selection_screen.dart';
import '../../features/onboarding/shop_wizard_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/onboarding/pin_lock_screen.dart';
import '../../features/onboarding/auth_provider.dart';
import '../../features/dashboard/main_shell.dart';
import '../../features/products/products_screen.dart';
import '../../features/products/product_edit_screen.dart';
import '../../features/products/barcode_scanner_screen.dart';
import '../../features/pos/pos_screen.dart';
import '../../features/pos/checkout_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/credentials_screen.dart';
import '../../features/reports/sales_report_screen.dart';
import '../../features/customers/customers_screen.dart';
import '../../features/customers/customer_edit_screen.dart';
import '../../features/customers/customer_detail_screen.dart';
import '../../features/customers/debt_list_screen.dart';
import '../../data/models/product_model.dart';
import '../../data/models/customer_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthComplete = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final settingsBox = Hive.box<SettingsModel>('settings');
      final settings = settingsBox.get('app_settings') ?? SettingsModel();

      final isSetupComplete = settings.isSetupComplete;
      final isGoingToSetup =
          state.uri.path == '/' || state.uri.path == '/setup_wizard';
      final isGoingToPin = state.uri.path == '/pin';

      if (!isSetupComplete && !isGoingToSetup) {
        return '/';
      }

      if (isSetupComplete && !isAuthComplete && !isGoingToPin) {
        return '/pin';
      }

      if (isSetupComplete &&
          isAuthComplete &&
          (isGoingToSetup || isGoingToPin)) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/setup_wizard',
        builder: (context, state) => const ShopWizardScreen(),
      ),
      GoRoute(path: '/pin', builder: (context, state) => const PinLockScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'sales-report',
                    builder: (context, state) => const SalesReportScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pos',
                builder: (context, state) => const POSScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) => const ProductsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const ProductEditScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) =>
                        ProductEditScreen(product: state.extra as ProductModel),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/customers',
                builder: (context, state) => const CustomersScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const CustomerEditScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => CustomerEditScreen(
                      customer: state.extra as CustomerModel,
                    ),
                  ),
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) => CustomerDetailScreen(
                      customer: state.extra as CustomerModel,
                    ),
                  ),
                  GoRoute(
                    path: 'debts',
                    builder: (context, state) => const DebtListScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'credentials',
                    builder: (context, state) => const CredentialsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const BarcodeScannerScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
    ],
  );
});
