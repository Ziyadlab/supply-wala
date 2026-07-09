import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';

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
            const Text(
              'Supplier Workflow',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  _SupplierStatusStep(
                    label: 'New',
                    subtitle: 'Order received from restaurant buyer',
                    selected: order.status == OrderStatus.pending,
                    onTap: () =>
                        state.updateOrderStatus(order, OrderStatus.pending),
                  ),
                  const Divider(),
                  _SupplierStatusStep(
                    label: 'Processing',
                    subtitle: 'Inventory is being prepared for delivery',
                    selected:
                        order.status == OrderStatus.accepted ||
                        order.status == OrderStatus.preparing ||
                        order.status == OrderStatus.dispatched,
                    onTap: () =>
                        state.updateOrderStatus(order, OrderStatus.preparing),
                  ),
                  const Divider(),
                  _SupplierStatusStep(
                    label: 'Delivered',
                    subtitle: 'Buyer received this order',
                    selected: order.status == OrderStatus.completed,
                    onTap: () =>
                        state.updateOrderStatus(order, OrderStatus.completed),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () =>
                  state.updateOrderStatus(order, OrderStatus.rejected),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Reject Order'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SupplierStatusStep extends StatelessWidget {
  const _SupplierStatusStep({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: selected
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: .10),
        child: Icon(
          selected ? Icons.check_rounded : Icons.circle_outlined,
          color: selected ? Colors.white : AppColors.primary,
        ),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle),
      trailing: selected
          ? const Text(
              'ACTIVE',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
