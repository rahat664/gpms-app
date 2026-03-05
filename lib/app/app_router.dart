import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/factory/presentation/factory_selector_screen.dart';
import '../features/operations/presentation/buyers_screen.dart';
import '../features/operations/presentation/cutting_screen.dart';
import '../features/operations/presentation/inventory_screen.dart';
import '../features/operations/presentation/materials_screen.dart';
import '../features/operations/presentation/plans_screen.dart';
import '../features/operations/presentation/po_workbench_screen.dart';
import '../features/operations/presentation/qc_screen.dart';
import '../features/operations/presentation/sewing_screen.dart';
import '../features/operations/presentation/styles_screen.dart';
import '../features/pos/presentation/po_details_screen.dart';
import '../ui/screens/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/factory-selector',
        builder: (context, state) => const FactorySelectorScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          final currentTab = int.tryParse(tabParam ?? '0') ?? 0;
          return HomeScreen(currentTab: currentTab);
        },
      ),
      GoRoute(
        path: '/po/:id',
        builder: (context, state) {
          final poId = state.pathParameters['id'] ?? '';
          return PoDetailsScreen(poId: poId);
        },
      ),
      GoRoute(
        path: '/workspace/po',
        builder: (context, state) => const PoWorkbenchScreen(),
      ),
      GoRoute(
        path: '/workspace/buyers',
        builder: (context, state) => const BuyersScreen(),
      ),
      GoRoute(
        path: '/workspace/styles',
        builder: (context, state) => const StylesScreen(),
      ),
      GoRoute(
        path: '/workspace/materials',
        builder: (context, state) => const MaterialsScreen(),
      ),
      GoRoute(
        path: '/workspace/inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/workspace/plans',
        builder: (context, state) => const PlansScreen(),
      ),
      GoRoute(
        path: '/workspace/cutting',
        builder: (context, state) => const CuttingScreen(),
      ),
      GoRoute(
        path: '/workspace/sewing',
        builder: (context, state) => const SewingScreen(),
      ),
      GoRoute(
        path: '/workspace/qc',
        builder: (context, state) => const QcScreen(),
      ),
    ],
  );
});
