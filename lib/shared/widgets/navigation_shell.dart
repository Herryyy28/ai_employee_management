import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_colors.dart';

class NavigationShell extends StatelessWidget {
  final Widget child;

  const NavigationShell({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/attendance')) return 1;
    if (location.startsWith('/tasks')) return 2;
    if (location.startsWith('/leaves')) return 3;
    if (location.startsWith('/chatbot')) return 4;
    if (location.startsWith('/enterprise')) return 5;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/attendance');
        break;
      case 2:
        context.go('/tasks');
        break;
      case 3:
        context.go('/leaves');
        break;
      case 4:
        context.go('/chatbot');
        break;
      case 5:
        context.go('/enterprise');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 768;

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            // Left sidebar for tablets/large displays (Linear/Slack aesthetic)
            Container(
              width: 250,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.obsidianBorder
                        : AppColors.notionBorder,
                  ),
                ),
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.obsidianSurface
                    : Colors.white,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Header branding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'AI-EMS Portal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Navigation Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      children: [
                        _buildSideNavItem(
                          context,
                          label: 'Overview Dashboard',
                          icon: Icons.dashboard_outlined,
                          selectedIcon: Icons.dashboard,
                          isSelected: selectedIndex == 0,
                          onTap: () => _onItemTapped(0, context),
                        ),
                        _buildSideNavItem(
                          context,
                          label: 'Attendance logs',
                          icon: Icons.check_circle_outline,
                          selectedIcon: Icons.check_circle,
                          isSelected: selectedIndex == 1,
                          onTap: () => _onItemTapped(1, context),
                        ),
                        _buildSideNavItem(
                          context,
                          label: 'Kanban Tasks',
                          icon: Icons.task_outlined,
                          selectedIcon: Icons.task,
                          isSelected: selectedIndex == 2,
                          onTap: () => _onItemTapped(2, context),
                        ),
                        _buildSideNavItem(
                          context,
                          label: 'Leave Requests',
                          icon: Icons.time_to_leave_outlined,
                          selectedIcon: Icons.time_to_leave,
                          isSelected: selectedIndex == 3,
                          onTap: () => _onItemTapped(3, context),
                        ),
                        _buildSideNavItem(
                          context,
                          label: 'AI HR Assistant',
                          icon: Icons.chat_bubble_outline,
                          selectedIcon: Icons.chat_bubble,
                          isSelected: selectedIndex == 4,
                          onTap: () => _onItemTapped(4, context),
                        ),
                        _buildSideNavItem(
                          context,
                          label: 'Enterprise Suite',
                          icon: Icons.business_outlined,
                          selectedIcon: Icons.business,
                          isSelected: selectedIndex == 5,
                          onTap: () => _onItemTapped(5, context),
                        ),
                      ],
                    ),
                  ),
                  // App profile / Status indicators
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.indigoAccent,
                          radius: 18,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Session',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Synchronized',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.wifi,
                          color: AppColors.success.withOpacity(0.8),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Central Content area
            Expanded(child: child),
          ],
        ),
      );
    }

    // Default bottom navigation bar layout for mobile devices
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: 'Check In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            activeIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.time_to_leave_outlined),
            activeIcon: Icon(Icons.time_to_leave),
            label: 'Leaves',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'AI chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: 'Suite',
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required IconData selectedIcon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? activeColor
                    : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? activeColor
                      : theme.textTheme.bodyMedium?.color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
