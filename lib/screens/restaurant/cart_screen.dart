import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.purple.shade700,
              child: Text(
                ((state.currentUser?.name.isNotEmpty ?? false)
                        ? state.currentUser!.name[0]
                        : 'S')
                    .toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ordering for',
                    style: TextStyle(color: AppColors.muted, fontSize: 14),
                  ),
                  Text(
                    state.currentUser?.businessName ?? 'SupplyWala',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: AppRoundButton(
              icon: Icons.notifications_none_rounded,
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: state.cart.isEmpty
          ? const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message:
                  'Add items from supplier inventory or use the voice assistant.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 132),
              children: [
                SmartCartBanner(
                  onRegenerate: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'AI suggestions will use your live order history soon.',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SectionTitle(
                  'YOUR ITEMS',
                  count: state.cart.length,
                  action: TextButton(
                    onPressed: state.cart.isEmpty
                        ? null
                        : () {
                            for (final item in List.of(state.cart)) {
                              state.removeCartItem(item);
                            }
                          },
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(height: 14),
                ...state.cart.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: CartLineCard(
                      item: item,
                      onDecrement: () =>
                          state.updateCartQuantity(item, item.quantity - 1),
                      onIncrement: () =>
                          state.updateCartQuantity(item, item.quantity + 1),
                      onRemove: () => state.removeCartItem(item),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.line,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.muted,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'ADD ANOTHER ITEM',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                AppCard(
                  padding: const EdgeInsets.all(22),
                  radius: 32,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Divider(height: 1),
                      const SizedBox(height: 18),
                      SummaryRow(
                        label: 'Subtotal',
                        value: 'PKR ${state.cartTotal.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 14),
                      const SummaryRow(
                        label: 'Sales Tax (GST)',
                        value: 'PKR 0',
                      ),
                      const SizedBox(height: 14),
                      const SummaryRow(label: 'Delivery Fee', value: 'FREE'),
                      const SizedBox(height: 18),
                      const Divider(height: 1),
                      const SizedBox(height: 18),
                      SummaryRow(
                        label: 'Grand Total',
                        value: 'PKR ${state.cartTotal.toStringAsFixed(0)}',
                        highlight: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: state.cart.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: .96),
                  border: const Border(top: BorderSide(color: AppColors.line)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL AMOUNT',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'PKR ${state.cartTotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CheckoutScreen(),
                          ),
                        ),
                        label: const Text('CONFIRM ORDER'),
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: const VoiceAssistantButton(),
    );
  }
}
