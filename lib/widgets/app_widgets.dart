import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: compact ? 42 : 58,
          width: compact ? 42 : 58,
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.storefront_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(
          'Supply Wala',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: AppColors.softOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 34, color: AppColors.orange),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NetworkThumb extends StatelessWidget {
  const NetworkThumb({
    super.key,
    required this.url,
    this.size = 64,
    this.radius = 16,
  });

  final String url;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        height: size,
        width: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: size,
          width: size,
          color: AppColors.softOrange,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.orange,
          ),
        ),
      ),
    );
  }
}

class SupplierCard extends StatelessWidget {
  const SupplierCard({
    super.key,
    required this.supplier,
    required this.products,
    required this.onTap,
  });

  final Supplier supplier;
  final List<Product> products;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  NetworkThumb(url: supplier.logoUrl, size: 76),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${supplier.category} - ${supplier.location}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                        Text(
                          supplier.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: supplier.highlights
                          .take(3)
                          .map(
                            (item) => Chip(
                              label: Text(item),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.line),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${products.length} items',
                    style: const TextStyle(
                      color: AppColors.deepOrange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.deepOrange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.deepOrange),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
              Text(
                label,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onAdd,
    this.onEdit,
    this.onDelete,
  });

  final Product product;
  final VoidCallback? onAdd;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            NetworkThumb(url: product.imageUrl, size: 64),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: product.isAvailable
                              ? const Color(0xFFEFFDF3)
                              : const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          product.isAvailable ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            color: product.isAvailable
                                ? AppColors.success
                                : AppColors.danger,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.category} - ${product.quantity} ${product.unit} in stock',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rs ${product.price.toStringAsFixed(0)} / ${product.unit}',
                    style: const TextStyle(
                      color: AppColors.deepOrange,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            if (onAdd != null)
              IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: AppColors.orange),
                onPressed: product.isAvailable ? onAdd : null,
                icon: const Icon(Icons.add_shopping_cart_rounded),
              ),
            if (onEdit != null)
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
              ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.onTap});

  final AppOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(
          order.id,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${order.supplierName} - Rs ${order.total.toStringAsFixed(0)}',
        ),
        trailing: Chip(
          label: Text(
            order.status.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: order.status.color,
        ),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  const ChatTile({super.key, required this.thread, required this.onTap});

  final ChatThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: NetworkThumb(url: thread.avatarUrl, size: 48, radius: 14),
        title: Text(
          thread.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          thread.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class VoiceAssistantButton extends StatelessWidget {
  const VoiceAssistantButton({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (!state.isRestaurant) return const SizedBox.shrink();
    return FloatingActionButton.extended(
      heroTag: 'voice-assistant',
      backgroundColor: Colors.white,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.orange),
      ),
      onPressed: () => _listenAndShowVoiceOrder(context),
      icon: const Icon(Icons.mic_rounded, color: AppColors.deepOrange),
      label: const Text(
        'Voice Cart',
        style: TextStyle(
          color: AppColors.deepOrange,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

Future<void> _listenAndShowVoiceOrder(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  String? transcript;
  final speech = SpeechToText();
  try {
    final available = await speech.initialize();
    if (available) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Listening... say your order now.')),
      );
      await speech.listen(
        onResult: (result) => transcript = result.recognizedWords,
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(seconds: 5),
          pauseFor: const Duration(seconds: 2),
        ),
      );
      await Future<void>.delayed(const Duration(seconds: 5));
      await speech.stop();
    }
  } catch (_) {
    transcript = null;
  }
  if (!context.mounted) return;
  await showVoiceOrderConfirmation(context, transcript: transcript);
}

Future<void> showVoiceOrderConfirmation(
  BuildContext context, {
  String? transcript,
}) async {
  final state = AppScope.of(context);
  final draft = transcript != null && transcript.trim().isNotEmpty
      ? state.parseVoiceOrder(transcript)
      : state.simulateVoiceOrder();
  final editable = draft.items
      .map((item) => CartItem(product: item.product, quantity: item.quantity))
      .toList();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              18,
              18,
              MediaQuery.of(context).viewInsets.bottom + 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Voice Order Confirmation'),
                const SizedBox(height: 8),
                Text(
                  '"${draft.transcript}"',
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                Text(
                  draft.notes,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                if (editable.isEmpty)
                  const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No matches',
                    message:
                        'Try naming products already available in supplier inventory.',
                  )
                else
                  ...editable.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item.product.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        'Rs ${item.product.price.toStringAsFixed(0)} / ${item.product.unit}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => setModalState(
                              () => item.quantity = (item.quantity - 1)
                                  .clamp(1, 999)
                                  .toInt(),
                            ),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            onPressed: () =>
                                setModalState(() => item.quantity++),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                          IconButton(
                            onPressed: () =>
                                setModalState(() => editable.remove(item)),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: editable.isEmpty
                      ? null
                      : () {
                          state.confirmVoiceDraft(
                            VoiceOrderDraft(
                              transcript: draft.transcript,
                              items: editable,
                              notes: draft.notes,
                            ),
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Voice items added to cart.'),
                            ),
                          );
                        },
                  icon: const Icon(Icons.shopping_cart_checkout_rounded),
                  label: const Text('Add to Cart'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
