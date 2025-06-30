import 'package:comp1876_su25_crossapp/widgets/cart_header.dart';
import 'package:comp1876_su25_crossapp/widgets/cart_item_card.dart';
import 'package:comp1876_su25_crossapp/widgets/cart_summary.dart';
import 'package:comp1876_su25_crossapp/widgets/empty_cart_widget.dart';
import 'package:comp1876_su25_crossapp/widgets/customDialog.dart';
import 'package:flutter/material.dart';
import '../../services/cart_service.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cartService.cartItems.isEmpty
          ? const EmptyCartWidget()
          : Column(
              children: [
                CartHeader(
                  title: 'Shopping Cart',
                  itemCount: _cartService.cartItems.length,
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartService.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartService.cartItems[index];
                      return CartItemCard(
                        item: item,
                        onRemove: () => _removeItemFromCart(item),
                      );
                    },
                  ),
                ),
                CartSummary(cartService: _cartService),
              ],
            ),
    );
  }

  void _removeItemFromCart(Map<String, dynamic> item) {
    CustomDialog.show(
      context,
      title: 'Remove Item',
      content: 'Remove "${item['name']}" from your cart?',
      confirmText: 'Remove',
      onConfirm: () {
        _cartService.removeFromCart(item['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item['name']} removed from cart'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
}
