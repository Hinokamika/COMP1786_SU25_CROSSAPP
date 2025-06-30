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
      // Add a delay to prevent jarring transitions and scrolling issues
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _cartService.cartItems.isEmpty
            ? const EmptyCartWidget(key: ValueKey('empty_cart'))
            : Column(
                key: const ValueKey('cart_content'),
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
        Future.microtask(() {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item['name']} removed from cart'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      },
    );
  }
}
