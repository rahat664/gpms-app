import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/session_controller.dart';
import '../../features/dashboard/data/dashboard_repository.dart';
import '../../features/dashboard/presentation/dashboard_tab.dart';
import '../../features/pos/data/po_repository.dart';
import '../../features/pos/presentation/orders_tab.dart';
import '../../features/settings/presentation/settings_tab.dart';
import '../widgets/app_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.currentTab});

  final int currentTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = currentTab.clamp(0, 2);
    final session = ref.watch(sessionControllerProvider);
    String? activeFactoryName;
    for (final factory in session.factories) {
      if (factory.id == session.activeFactoryId) {
        activeFactoryName = factory.name;
        break;
      }
    }

    final dashboardAsync = ref.watch(dashboardSummaryProvider);
    final ordersAsync = ref.watch(poListProvider);

    final isOnline = switch (index) {
      0 => !dashboardAsync.hasError,
      1 => !ordersAsync.hasError,
      _ => true,
    };

    final tabTitle = switch (index) {
      0 => 'Live Dashboard',
      1 => 'Purchase Orders',
      _ => 'Settings',
    };

    return AppScaffold(
      title: tabTitle,
      statusLabel: activeFactoryName,
      isOnline: isOnline,
      onRefresh: () {
        switch (index) {
          case 0:
            ref.invalidate(dashboardSummaryProvider);
          case 1:
            ref.invalidate(poListProvider);
          case 2:
            break;
        }
      },
      onFactorySwitch: () => context.go('/factory-selector'),
      body: IndexedStack(
        index: index,
        children: const <Widget>[DashboardTab(), OrdersTab(), SettingsTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (int value) {
          context.go('/home?tab=$value');
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
