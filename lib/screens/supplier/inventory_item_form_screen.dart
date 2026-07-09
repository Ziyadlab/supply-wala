import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';

class InventoryItemFormScreen extends StatefulWidget {
  const InventoryItemFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<InventoryItemFormScreen> createState() =>
      _InventoryItemFormScreenState();
}

class _InventoryItemFormScreenState extends State<InventoryItemFormScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController category;
  late final TextEditingController price;
  late final TextEditingController quantity;
  late final TextEditingController unit;
  bool available = true;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    name = TextEditingController(text: product?.name ?? '');
    category = TextEditingController(text: product?.category ?? 'Vegetables');
    price = TextEditingController(
      text: product?.price.toStringAsFixed(0) ?? '',
    );
    quantity = TextEditingController(text: product?.quantity.toString() ?? '');
    unit = TextEditingController(text: product?.unit ?? 'kg');
    available = product?.isAvailable ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Add Inventory Item' : 'Edit Inventory Item',
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(name, 'Product name'),
            _field(category, 'Category'),
            _field(price, 'Price', number: true),
            _field(quantity, 'Quantity', number: true),
            _field(unit, 'Unit'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Available'),
              value: available,
              onChanged: (value) => setState(() => available = value),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final supplierId = state.activeSupplierId;
                final product = Product(
                  id:
                      widget.product?.id ??
                      'p${DateTime.now().millisecondsSinceEpoch}',
                  supplierId: widget.product?.supplierId ?? supplierId,
                  name: name.text,
                  imageUrl:
                      widget.product?.imageUrl ??
                      'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500',
                  category: category.text,
                  price: double.tryParse(price.text) ?? 0,
                  quantity: int.tryParse(quantity.text) ?? 0,
                  unit: unit.text,
                  isAvailable: available,
                );
                state.addOrUpdateProduct(product);
                Navigator.pop(context);
              },
              child: const Text('Save Item'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
      ),
    );
  }
}
