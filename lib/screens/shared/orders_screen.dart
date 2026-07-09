import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: state.visibleOrders.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message: 'Orders placed by restaurants will appear here.',
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
