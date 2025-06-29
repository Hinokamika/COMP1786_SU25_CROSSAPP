import 'package:flutter/material.dart';

class ShoppingCartDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(String) onRemoveItem;
  final Function(String, int) onUpdateQuantity;
  final VoidCallback onViewCart;

  const ShoppingCartDropdown({
    super.key,
    required this.cartItems,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
    required this.onViewCart,
  });

  @override
  State<ShoppingCartDropdown> createState() => _ShoppingCartDropdownState();
}

class _ShoppingCartDropdownState extends State<ShoppingCartDropdown> {
  // Calculate total items in cart
  int get totalCartItems {
    return widget.cartItems.fold(
      0,
      (sum, item) => sum + (item['quantity'] as int),
    );
  }

  // Calculate total price
  double get totalPrice {
    return widget.cartItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Stack(
        children: [
          const Icon(Icons.shopping_cart),
          if (totalCartItems > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$totalCartItems',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      offset: const Offset(0, 50),
      itemBuilder: (BuildContext context) {
        if (widget.cartItems.isEmpty) {
          return [
            PopupMenuItem<String>(
              enabled: false,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'Your cart is empty',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ];
        }

        List<PopupMenuEntry<String>> menuItems = [];

        // Add cart items
        for (int i = 0; i < widget.cartItems.length; i++) {
          final item = widget.cartItems[i];
          menuItems.add(
            PopupMenuItem<String>(enabled: false, child: _buildCartItem(item)),
          );

          // Add divider between items (except for the last item)
          if (i < widget.cartItems.length - 1) {
            menuItems.add(const PopupMenuDivider());
          }
        }

        // Add total and checkout section
        if (widget.cartItems.isNotEmpty) {
          menuItems.add(const PopupMenuDivider());
          menuItems.add(
            PopupMenuItem<String>(enabled: false, child: _buildCartSummary()),
          );
        }

        return menuItems;
      },
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return SizedBox(
      width: 300,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '\$${item['price'].toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  widget.onUpdateQuantity(item['id'], item['quantity'] - 1);
                },
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${item['quantity']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.onUpdateQuantity(item['id'], item['quantity'] + 1);
                },
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                onPressed: () {
                  widget.onRemoveItem(item['id']);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary() {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onViewCart();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('View Cart'),
            ),
          ),
        ],
      ),
    );
  }
}
