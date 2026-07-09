import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import '../shared/order_detail_screen.dart';
import '../shared/orders_screen.dart';
import 'inventory_screen.dart';

class SupplierDashboardScreen extends StatelessWidget {
  const SupplierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final stats = [
      (
        'Total Orders',
        '${state.visibleOrders.length}',
        Icons.receipt_long_rounded,
      ),
      ('Pending', '${state.pendingOrders}', Icons.pending_actions_rounded),
      ('Completed', '${state.completedOrders}', Icons.check_circle_rounded),
      ('Inventory', '${state.inventoryCount}', Icons.inventory_2_rounded),
    ];
    return Scaffold(
      appBar: AppBar(title: const AppLogo(compact: true)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Supplier Dashboard',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (_, index) {
              final stat = stats[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(stat.$3, color: AppColors.orange),
                      Text(
                        stat.$2,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        stat.$1,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InventoryScreen()),
                  ),
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Manage Inventory'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  ),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Orders'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SectionTitle('Recent Orders'),
          const SizedBox(height: 10),
          ...state.visibleOrders
              .take(3)
              .map(
                (order) => OrderCard(
                  order: order,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(order: order),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
