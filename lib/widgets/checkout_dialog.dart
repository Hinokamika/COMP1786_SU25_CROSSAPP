import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CheckOutDialog extends StatefulWidget {
  final CartService cartService;
  final VoidCallback? onConfirm;

  const CheckOutDialog({super.key, required this.cartService, this.onConfirm});

  @override
  State<CheckOutDialog> createState() => _CheckOutDialogState();

  static Future<bool?> show(
    BuildContext context, {
    required CartService cartService,
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CheckOutDialog(cartService: cartService, onConfirm: onConfirm);
      },
    );
  }
}

class _CheckOutDialogState extends State<CheckOutDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Checkout'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary:'),
          const SizedBox(height: 8),

          // Check if cart has items
          if (widget.cartService.cartItems.isEmpty)
            const Text(
              'No items in cart',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...widget.cartService.cartItems.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['name'] ?? 'Unknown Item',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '\$${(item['price'] ?? 0.0).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${widget.cartService.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF3333),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: widget.cartService.cartItems.isNotEmpty
              ? () {
                  // Simplified: Just close dialog and execute callback immediately
                  Navigator.of(context).pop(true);
                  widget.onConfirm?.call();
                }
              : null, // Disable button if cart is empty
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF3333),
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm Order'),
        ),
      ],
    );
  }
}
