import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final address = TextEditingController(text: 'MM Alam Road, Lahore');

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 132),
        children: [
          const SmartCartBanner(),
          const SizedBox(height: 22),
          const Text(
            'Delivery Address',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: address,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Where should your supplier deliver?',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 22),
          AppCard(
            padding: const EdgeInsets.all(22),
            radius: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 12),
                ...state.cart.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity} x ${item.product.name}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'PKR ${item.total.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 18),
                SummaryRow(
                  label: 'Grand Total',
                  value: 'PKR ${state.cartTotal.toStringAsFixed(0)}',
                  highlight: true,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: .12),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.trending_down_rounded,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AI Savings: optimized sourcing will be calculated from live pricing.',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: .96),
            border: const Border(top: BorderSide(color: AppColors.line)),
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              final order = state.checkout(address.text);
              if (order == null) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${order.id} placed successfully.')),
              );
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('PLACE ORDER'),
          ),
        ),
      ),
      floatingActionButton: const VoiceAssistantButton(),
    );
  }
}
