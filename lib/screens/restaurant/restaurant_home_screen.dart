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
    final user = state.currentUser;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 112),
          children: [
            Row(
              children: [
                NetworkThumb(
                  url:
                      user?.avatarUrl ??
                      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
                  size: 58,
                  radius: 29,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ordering for',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        user?.businessName ?? 'Restaurant',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                AppRoundButton(
                  icon: Icons.shopping_cart_outlined,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                  showDot: state.cartCount > 0,
                ),
              ],
            ),
            const SizedBox(height: 26),
            SmartCartBanner(
              onRegenerate: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fresh AI suggestions are being prepared.'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () => showVoiceOrderConfirmation(context),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.line),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .08),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Voice-to-Order',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Say items like 5 kg tomatoes and 2 milk cartons.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
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
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search products, suppliers, categories',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) => state.setFilters(query: value),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 9),
                itemBuilder: (_, i) {
                  final category = state.categories[i];
                  final selected = state.categoryFilter == category;
                  return ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.line),
                    onSelected: (_) => state.setFilters(category: category),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            SectionTitle(
              'Top Suppliers',
              count: state.filteredSuppliers.length,
              action: TextButton(
                onPressed: () {},
                child: const Text('Filtered'),
              ),
            ),
            const SizedBox(height: 14),
            if (state.filteredSuppliers.isEmpty)
              const EmptyState(
                icon: Icons.store_mall_directory_outlined,
                title: 'No suppliers found',
                message: 'Try another product, category, location, or rating.',
              )
            else
              ...state.filteredSuppliers.map(
                (supplier) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: SupplierCard(
                    supplier: supplier,
                    products: state.supplierProducts(supplier.id),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SupplierDetailScreen(supplier: supplier),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: const VoiceAssistantButton(),
    );
  }
}
