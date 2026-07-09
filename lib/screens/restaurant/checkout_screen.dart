import 'package:flutter/material.dart';

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
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: address,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Delivery address',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ...state.cart.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity} x ${item.product.name}',
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
                        'Payable',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Rs ${state.cartTotal.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final order = state.checkout(address.text);
              if (order == null) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${order.id} placed successfully.')),
              );
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Place Order'),
          ),
        ],
      ),
      floatingActionButton: const VoiceAssistantButton(),
    );
  }
}
