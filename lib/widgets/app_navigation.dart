import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _TabSpec {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int? branchIndex;
  const _TabSpec({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.branchIndex,
  });
}

class AppNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const AppNavigation({required this.navigationShell, super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  // TODO: Replace with [Riverpod/Bloc] for production
  int _selectedVisualIndex = 0;

  final List<_TabSpec> _tabs = const [
    _TabSpec(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      branchIndex: 0,
    ),
    _TabSpec(
      label: 'Bookings',
      icon: Icons.local_taxi_outlined,
      selectedIcon: Icons.local_taxi_rounded,
      branchIndex: 1,
    ),
    _TabSpec(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      branchIndex: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NavigationBar(
      selectedIndex: _selectedVisualIndex,
      onDestinationSelected: (index) {
        final tab = _tabs[index];
        if (tab.branchIndex == null) return;
        setState(() => _selectedVisualIndex = index);
        widget.navigationShell.goBranch(
          tab.branchIndex!,
          initialLocation:
              tab.branchIndex == widget.navigationShell.currentIndex,
        );
      },
      backgroundColor: theme.colorScheme.surface,
      indicatorColor: theme.colorScheme.primaryContainer,
      destinations: _tabs.map((tab) {
        final isStub = tab.branchIndex == null;
        return NavigationDestination(
          icon: Opacity(opacity: isStub ? 0.4 : 1.0, child: Icon(tab.icon)),
          selectedIcon: Opacity(
            opacity: isStub ? 0.4 : 1.0,
            child: Icon(tab.selectedIcon),
          ),
          label: tab.label,
        );
      }).toList(),
    );
  }
}
