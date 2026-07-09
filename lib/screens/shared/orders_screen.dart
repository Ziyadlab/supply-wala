import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final title = state.isSupplier ? 'Supplier Orders' : 'Orders';
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title)) : null,
      body: state.visibleOrders.isEmpty
          ? EmptyState(
              icon: Icons.receipt_long_outlined,
              title: state.isSupplier
                  ? 'No supplier orders yet'
                  : 'No orders yet',
              message: state.isSupplier
                  ? 'Restaurant buyer orders for your inventory will appear here.'
                  : 'Orders placed by restaurants will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.visibleOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final order = state.visibleOrders[index];
                return OrderCard(
                  order: order,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(order: order),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
