import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import 'cart_screen.dart';
import 'supplier_detail_screen.dart';

class RestaurantHomeScreen extends StatelessWidget {
  const RestaurantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(compact: true),
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
          Text(
            'Find suppliers near you',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.line),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: AppColors.softOrange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: AppColors.deepOrange,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice-to-cart is ready',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Say items like “5 kg tomatoes and 2 milk cartons”.',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search products, suppliers, categories',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (value) => state.setFilters(query: value),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final category = state.categories[i];
                return ChoiceChip(
                  label: Text(category),
                  selected: state.categoryFilter == category,
                  onSelected: (_) => state.setFilters(category: category),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          SectionTitle(
            'Top Suppliers',
            action: TextButton(onPressed: () {}, child: const Text('Filtered')),
          ),
          const SizedBox(height: 10),
          if (state.filteredSuppliers.isEmpty)
            const EmptyState(
              icon: Icons.store_mall_directory_outlined,
              title: 'No suppliers found',
              message: 'Try another product, category, location, or rating.',
            )
          else
            ...state.filteredSuppliers.map(
              (supplier) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SupplierCard(
                  supplier: supplier,
                  products: state.supplierProducts(supplier.id),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SupplierDetailScreen(supplier: supplier),
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
