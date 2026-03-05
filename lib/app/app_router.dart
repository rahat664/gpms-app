import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/factory/presentation/factory_selector_screen.dart';
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
    ],
  );
});
