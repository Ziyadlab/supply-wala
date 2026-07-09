import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../state/app_state.dart';
import '../shared/chat_list_screen.dart';
import '../shared/orders_screen.dart';
import '../shared/profile_screen.dart';
import 'inventory_screen.dart';
import 'supplier_dashboard_screen.dart';

class SupplierShell extends StatefulWidget {
  const SupplierShell({super.key});

  @override
  State<SupplierShell> createState() => _SupplierShellState();
}

class _SupplierShellState extends State<SupplierShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final screens = [
      const SupplierDashboardScreen(),
      const OrdersScreen(showAppBar: false),
      const InventoryScreen(showAppBar: false),
      const ChatListScreen(showAppBar: false),
      const ProfileScreen(showAppBar: false),
    ];

    return Scaffold(
      body: screens[index],
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(top: BorderSide(color: AppColors.line)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .08),
                blurRadius: 18,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                key: const ValueKey('supplier-nav-dashboard'),
                icon: Icons.dashboard_outlined,
                selectedIcon: Icons.dashboard_rounded,
                label: 'Dashboard',
                selected: index == 0,
                onTap: () => setState(() => index = 0),
              ),
              _NavItem(
                key: const ValueKey('supplier-nav-orders'),
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long_rounded,
                label: 'Orders',
                selected: index == 1,
                showDot: state.pendingOrders > 0,
                onTap: () => setState(() => index = 1),
              ),
              _NavItem(
                key: const ValueKey('supplier-nav-inventory'),
                icon: Icons.inventory_2_outlined,
                selectedIcon: Icons.inventory_2_rounded,
                label: 'Inventory',
                selected: index == 2,
                onTap: () => setState(() => index = 2),
              ),
              _NavItem(
                key: const ValueKey('supplier-nav-chat'),
                icon: Icons.chat_bubble_outline_rounded,
                selectedIcon: Icons.chat_bubble_rounded,
                label: 'Chat',
                selected: index == 3,
                showDot: state.chats.isNotEmpty,
                onTap: () => setState(() => index = 3),
              ),
              _NavItem(
                key: const ValueKey('supplier-nav-profile'),
                icon: Icons.account_circle_outlined,
                selectedIcon: Icons.account_circle_rounded,
                label: 'Profile',
                selected: index == 4,
                onTap: () => setState(() => index = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.muted;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(selected ? selectedIcon : icon, color: color, size: 29),
                  if (showDot)
                    Positioned(
                      top: -3,
                      right: -4,
                      child: Container(
                        height: 9,
                        width: 9,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
