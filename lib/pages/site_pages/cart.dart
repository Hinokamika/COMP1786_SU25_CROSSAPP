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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: SafeArea(
        child: _cartService.cartItems.isEmpty
            ? const EmptyCartWidget()
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      // Header with responsive height
                      SizedBox(
                        height: isSmallScreen ? 80 : 95,
                        child: CartHeader(
                          title: 'Shopping Cart',
                          itemCount: _cartService.cartItems.length,
                        ),
                      ),
                      // Main content area
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight:
                                constraints.maxHeight -
                                (isSmallScreen ? 150 : 165),
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 14,
                              vertical: 8,
                            ),
                            itemCount: _cartService.cartItems.length,
                            itemBuilder: (context, index) {
                              final item = _cartService.cartItems[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: isSmallScreen ? 6 : 10,
                                ),
                                child: CartItemCard(
                                  item: item,
                                  onRemove: () => _removeItemFromCart(item),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Cart summary with responsive height
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: isSmallScreen ? 70 : 85,
                        ),
                        child: CartSummary(cartService: _cartService),
                      ),
                    ],
                  );
                },
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
