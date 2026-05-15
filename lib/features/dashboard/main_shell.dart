import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../localization/app_localizations.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard),
            label: 'dashboard'.tr(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.point_of_sale),
            label: 'pos'.tr(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory),
            label: 'products'.tr(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: 'settings'.tr(context),
          ),
        ],
      ),
    );
  }
}
