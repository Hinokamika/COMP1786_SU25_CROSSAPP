import 'package:flutter/material.dart';

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool showConfirmedBadge;
  final VoidCallback? onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    this.showConfirmedBadge = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildItemIcon(),
            const SizedBox(width: 16),
            _buildItemDetails(),
            if (showConfirmedBadge) _buildConfirmedBadge(),
            if (!showConfirmedBadge && onRemove != null) _buildRemoveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFF3333).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF3333).withOpacity(0.3)),
      ),
      child: const Icon(Icons.school, color: Color(0xFFFF3333), size: 30),
    );
  }

  Widget _buildItemDetails() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['name'] ?? 'Unknown Class',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Teacher: ${item['teacher'] ?? 'Unknown'}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Duration: ${item['duration'] ?? '1 hour'}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${(item['price'] ?? 0.0).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF3333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green),
      ),
      child: const Text(
        'Confirmed',
        style: TextStyle(
          color: Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return IconButton(
      onPressed: onRemove,
      icon: const Icon(Icons.remove_circle_outline),
      color: Colors.red,
      tooltip: 'Remove from cart',
    );
  }
}
