import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import '../shared/chat_detail_screen.dart';
import '../shared/order_detail_screen.dart';
import '../shared/orders_screen.dart';
import 'inventory_screen.dart';

class SupplierDashboardScreen extends StatelessWidget {
  const SupplierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.currentUser;
    final chats = state.chats.take(2).toList();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
          children: [
            Row(
              children: [
                NetworkThumb(
                  url: user?.avatarUrl ?? state.suppliers.first.logoUrl,
                  size: 62,
                  radius: 31,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assalam-o-Alaikum,',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        user?.name ?? 'Supplier',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                AppRoundButton(
                  icon: Icons.search_rounded,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InventoryScreen()),
                  ),
                ),
                const SizedBox(width: 10),
                AppRoundButton(
                  icon: Icons.notifications_none_rounded,
                  showDot: state.pendingOrders > 0,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'TODAY',
                    value: '${state.visibleOrders.length}',
                    footnote: '+15%',
                    footnoteColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'PENDING',
                    value: 'PKR ${_compactMoney(_pendingValue(state))}',
                    footnote: '${state.pendingOrders} Orders',
                    footnoteColor: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'UNREAD',
                    value: '${state.chats.length}',
                    footnote: 'Urgent',
                    footnoteColor: AppColors.danger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            SectionTitle(
              'Active Orders',
              count: state.visibleOrders.length,
              action: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                ),
                child: const Text('View All'),
              ),
            ),
            const SizedBox(height: 14),
            ...state.visibleOrders
                .take(2)
                .map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
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
            const SizedBox(height: 20),
            const SectionTitle('Recent Conversations'),
            const SizedBox(height: 14),
            if (chats.isEmpty)
              const EmptyState(
                icon: Icons.chat_bubble_outline,
                title: 'No conversations yet',
                message: 'Buyer messages will appear here.',
              )
            else
              AppCard(
                padding: EdgeInsets.zero,
                radius: 32,
                child: Column(
                  children: [
                    for (var i = 0; i < chats.length; i++) ...[
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(thread: chats[i]),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              NetworkThumb(
                                url: chats[i].avatarUrl,
                                size: 56,
                                radius: 28,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chats[i].name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      chats[i].subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (i == 0)
                                const CircleAvatar(
                                  radius: 15,
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    '2',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (i != chats.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 30),
            const SectionTitle('My Customers'),
            const SizedBox(height: 14),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.orders.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 18),
                itemBuilder: (_, index) {
                  if (index == 0) {
                    return const _CustomerBubble.invite();
                  }
                  final order = state.orders[index - 1];
                  return _CustomerBubble(label: order.restaurantName);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InventoryScreen()),
        ),
        child: const Icon(Icons.add_rounded, size: 34),
      ),
    );
  }

  static double _pendingValue(AppState state) => state.visibleOrders
      .where((order) => order.status == OrderStatus.pending)
      .fold(0, (sum, order) => sum + order.total);

  static String _compactMoney(double value) {
    if (value >= 1000) return '${(value / 1000).round()}k';
    return value.toStringAsFixed(0);
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.footnote,
    required this.footnoteColor,
  });

  final String label;
  final String value;
  final String footnote;
  final Color footnoteColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 28,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 27),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            footnote,
            style: TextStyle(
              color: footnoteColor,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerBubble extends StatelessWidget {
  const _CustomerBubble({required this.label}) : invite = false;
  const _CustomerBubble.invite() : label = 'Invite', invite = true;

  final String label;
  final bool invite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      child: Column(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: invite ? AppColors.primary.withValues(alpha: .06) : null,
              shape: BoxShape.circle,
              border: Border.all(
                color: invite ? AppColors.primary : AppColors.line,
                width: 2,
                style: invite ? BorderStyle.solid : BorderStyle.solid,
              ),
            ),
            child: invite
                ? const Icon(Icons.add_rounded, color: AppColors.primary)
                : CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: Text(
                      label.characters.first.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: invite ? AppColors.primary : AppColors.ink,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
