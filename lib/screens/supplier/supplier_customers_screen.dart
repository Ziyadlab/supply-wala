import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import '../shared/order_detail_screen.dart';

class SupplierCustomersScreen extends StatelessWidget {
  const SupplierCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final customers = state.supplierCustomers;
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: customers.isEmpty
          ? const EmptyState(
              icon: Icons.groups_2_outlined,
              title: 'No customers yet',
              message: 'Restaurants that order from you will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: customers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final customer = customers[index];
                final orders = state.ordersForCustomer(customer);
                final total = orders.fold<double>(
                  0,
                  (sum, order) => sum + order.total,
                );
                return AppCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _CustomerOrdersScreen(
                        customerName: customer,
                        orderCount: orders.length,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primarySoft,
                        child: Text(
                          customer.characters.first.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              '${orders.length} orders - PKR ${total.toStringAsFixed(0)}',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _CustomerOrdersScreen extends StatelessWidget {
  const _CustomerOrdersScreen({
    required this.customerName,
    required this.orderCount,
  });

  final String customerName;
  final int orderCount;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final orders = state.ordersForCustomer(customerName);
    return Scaffold(
      appBar: AppBar(title: Text(customerName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionTitle('Order History', count: orderCount),
          const SizedBox(height: 14),
          ...orders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OrderCard(
                order: order,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(order: order),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
