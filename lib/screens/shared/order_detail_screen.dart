import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/app_models.dart';
import '../../state/app_state.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});

  final AppOrder order;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(order.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.supplierName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Chip(
                        label: Text(
                          order.status.label,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: order.status.color,
                      ),
                    ],
                  ),
                  Text(
                    'Restaurant: ${order.restaurantName}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  Text(
                    'Delivery: ${order.deliveryAddress}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Items',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity} ${item.unit} ${item.productName}',
                            ),
                          ),
                          Text('Rs ${item.total.toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Rs ${order.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (state.isSupplier) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        state.updateOrderStatus(order, OrderStatus.accepted),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        state.updateOrderStatus(order, OrderStatus.rejected),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Reject'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Update Status',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: OrderStatus.values.map((status) {
                return ChoiceChip(
                  label: Text(status.label),
                  selected: order.status == status,
                  onSelected: (_) => state.updateOrderStatus(order, status),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
