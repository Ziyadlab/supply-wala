import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import '../shared/chat_detail_screen.dart';
import 'cart_screen.dart';

class SupplierDetailScreen extends StatelessWidget {
  const SupplierDetailScreen({super.key, required this.supplier});

  final Supplier supplier;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final products = state.supplierProducts(supplier.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(supplier.name),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            icon: Badge(
              label: Text('${state.cartCount}'),
              isLabelVisible: state.cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
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
                    children: [
                      NetworkThumb(url: supplier.logoUrl, size: 82, radius: 20),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              supplier.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Text(
                              '${supplier.category} - ${supplier.location}',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                ),
                                Text('${supplier.rating}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(supplier.description),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatPill(
                        icon: Icons.inventory_2_outlined,
                        label: 'Products',
                        value: '${products.length}',
                      ),
                      StatPill(
                        icon: Icons.location_on_outlined,
                        label: 'Area',
                        value: supplier.location.split(',').first,
                      ),
                      StatPill(
                        icon: Icons.verified_outlined,
                        label: 'Rating',
                        value: supplier.rating.toStringAsFixed(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      final thread = state.openChat(
                        supplier.name,
                        supplier.logoUrl,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(thread: thread),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Chat with Supplier'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SectionTitle(
            'Available Inventory',
            action: Text(
              '${products.where((item) => item.isAvailable).length} in stock',
              style: const TextStyle(
                color: AppColors.deepOrange,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...products.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ProductCard(
                product: product,
                onAdd: () {
                  state.addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} added to cart')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: const VoiceAssistantButton(),
    );
  }
}
