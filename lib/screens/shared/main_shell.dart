import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import '../restaurant/restaurant_home_screen.dart';
import '../restaurant/supplier_listing_screen.dart';
import '../supplier/supplier_dashboard_screen.dart';
import '../supplier/inventory_screen.dart';
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
      const ChatListScreen(),
      const OrdersScreen(),
      isRestaurant
          ? const SupplierListingScreen(showAppBar: false)
          : const InventoryScreen(showAppBar: false),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[index],
      floatingActionButton: isRestaurant ? const VoiceAssistantButton() : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
