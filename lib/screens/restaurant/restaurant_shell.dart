import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import '../shared/chat_list_screen.dart';
import '../shared/orders_screen.dart';
import '../shared/profile_screen.dart';
import 'restaurant_home_screen.dart';
import 'supplier_listing_screen.dart';

class RestaurantShell extends StatefulWidget {
  const RestaurantShell({super.key});

  @override
  State<RestaurantShell> createState() => _RestaurantShellState();
}

class _RestaurantShellState extends State<RestaurantShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final screens = [
      const RestaurantHomeScreen(),
      const OrdersScreen(showAppBar: false),
      const ChatListScreen(showAppBar: false),
      const SupplierListingScreen(showAppBar: false),
      const ProfileScreen(showAppBar: false),
    ];

    return Scaffold(
      body: screens[index],
      floatingActionButton: const VoiceAssistantButton(),
      bottomNavigationBar: _RoleBottomNav(
        items: [
          _NavSpec(
            key: 'nav-home',
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: 'Home',
          ),
          _NavSpec(
            key: 'nav-orders',
            icon: Icons.inventory_2_outlined,
            selectedIcon: Icons.inventory_2_rounded,
            label: 'Orders',
          ),
          _NavSpec(
            key: 'nav-chat',
            icon: Icons.chat_bubble_outline_rounded,
            selectedIcon: Icons.chat_bubble_rounded,
            label: 'Chat',
            showDot: state.chats.isNotEmpty,
          ),
          _NavSpec(
            key: 'nav-browse',
            icon: Icons.store_mall_directory_outlined,
            selectedIcon: Icons.store_mall_directory_rounded,
            label: 'Browse',
          ),
          _NavSpec(
            key: 'nav-profile',
            icon: Icons.account_circle_outlined,
            selectedIcon: Icons.account_circle_rounded,
            label: 'Profile',
          ),
        ],
        selectedIndex: index,
        onSelected: (value) => setState(() => index = value),
      ),
    );
  }
}

class _RoleBottomNav extends StatelessWidget {
  const _RoleBottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_NavSpec> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            for (var i = 0; i < items.length; i++)
              _NavItem(
                key: ValueKey(items[i].key),
                spec: items[i],
                selected: selectedIndex == i,
                onTap: () => onSelected(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec({
    required this.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.showDot = false,
  });

  final String key;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool showDot;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _NavSpec spec;
  final bool selected;
  final VoidCallback onTap;

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
                  Icon(
                    selected ? spec.selectedIcon : spec.icon,
                    color: color,
                    size: 29,
                  ),
                  if (spec.showDot)
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
                spec.label,
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
