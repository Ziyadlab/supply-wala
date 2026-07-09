import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import 'inventory_item_form_screen.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Inventory')) : null,
      body: state.myInventory.isEmpty
          ? const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No inventory',
              message: 'Add products to start receiving restaurant orders.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SectionTitle('My Inventory', count: state.myInventory.length),
                const SizedBox(height: 10),
                ...state.myInventory.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ProductCard(
                      product: product,
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              InventoryItemFormScreen(product: product),
                        ),
                      ),
                      onDelete: () => state.deleteProduct(product),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-inventory',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InventoryItemFormScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item'),
      ),
    );
  }
}
