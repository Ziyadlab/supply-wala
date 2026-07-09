import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import '../restaurant/restaurant_home_screen.dart';
import '../restaurant/supplier_listing_screen.dart';
import '../supplier/inventory_screen.dart';
import '../supplier/supplier_dashboard_screen.dart';
import 'chat_list_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final isRestaurant = state.currentUser?.role == UserRole.restaurant;
    final screens = [
      isRestaurant
          ? const RestaurantHomeScreen()
          : const SupplierDashboardScreen(),
      const OrdersScreen(),
      const ChatListScreen(),
      isRestaurant
          ? const SupplierListingScreen(showAppBar: false)
          : const InventoryScreen(showAppBar: false),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[index],
      floatingActionButton: isRestaurant ? const VoiceAssistantButton() : null,
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                key: const ValueKey('nav-home'),
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Home',
                selected: index == 0,
                onTap: () => setState(() => index = 0),
              ),
              _NavItem(
                key: const ValueKey('nav-orders'),
                icon: Icons.inventory_2_outlined,
                selectedIcon: Icons.inventory_2_rounded,
                label: 'Orders',
                selected: index == 1,
                onTap: () => setState(() => index = 1),
              ),
              _NavItem(
                key: const ValueKey('nav-chat'),
                icon: Icons.chat_bubble_outline_rounded,
                selectedIcon: Icons.chat_bubble_rounded,
                label: 'Chat',
                selected: index == 2,
                showDot: state.chats.isNotEmpty,
                onTap: () => setState(() => index = 2),
              ),
              _NavItem(
                key: const ValueKey('nav-browse'),
                icon: isRestaurant
                    ? Icons.store_mall_directory_outlined
                    : Icons.groups_2_outlined,
                selectedIcon: isRestaurant
                    ? Icons.store_mall_directory_rounded
                    : Icons.groups_2_rounded,
                label: isRestaurant ? 'Browse' : 'Stock',
                selected: index == 3,
                onTap: () => setState(() => index = 3),
              ),
              _NavItem(
                key: const ValueKey('nav-profile'),
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
                  fontSize: 11,
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
