import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import 'supplier_detail_screen.dart';

class SupplierListingScreen extends StatelessWidget {
  const SupplierListingScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Suppliers')) : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle('Supplier Directory'),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Location filter',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            onChanged: (value) => state.setFilters(location: value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Minimum rating'),
              Expanded(
                child: Slider(
                  value: state.ratingFilter,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  label: state.ratingFilter.toStringAsFixed(0),
                  activeColor: AppColors.orange,
                  onChanged: (value) => state.setFilters(rating: value),
                ),
              ),
            ],
          ),
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
      floatingActionButton: showAppBar ? const VoiceAssistantButton() : null,
    );
  }
}
