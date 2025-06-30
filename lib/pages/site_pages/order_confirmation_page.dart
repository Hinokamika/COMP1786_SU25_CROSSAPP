import 'package:comp1876_su25_crossapp/services/cart_service.dart';
import 'package:comp1876_su25_crossapp/widgets/cart_header.dart';
import 'package:comp1876_su25_crossapp/widgets/cart_item_card.dart';
import 'package:comp1876_su25_crossapp/widgets/cart_summary.dart';
import 'package:comp1876_su25_crossapp/widgets/empty_cart_widget.dart';
import 'package:flutter/material.dart';

class OrderConfirmationPage extends StatefulWidget {
  final CartService cartService;
  final String? title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onOrderConfirmed;

  const OrderConfirmationPage({
    super.key,
    required this.cartService,
    this.title,
    this.onBackPressed,
    this.onOrderConfirmed,
  });

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  @override
  void initState() {
    super.initState();
    widget.cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    widget.cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.cartService.cartItems.isEmpty
          ? EmptyCartWidget(
              title: 'No items to confirm',
              subtitle: 'Your cart is empty. Add some classes first!',
              onButtonPressed:
                  widget.onBackPressed ?? () => Navigator.pop(context),
            )
          : Column(
              children: [
                CartHeader(
                  title: widget.title ?? 'Confirm Your Order',
                  itemCount: widget.cartService.cartItems.length,
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cartService.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartService.cartItems[index];
                      return CartItemCard(
                        item: item,
                        showConfirmedBadge:
                            true, // Show confirmed badge instead of remove button
                      );
                    },
                  ),
                ),
                CartSummary(
                  cartService: widget.cartService,
                  onBackPressed:
                      widget.onBackPressed ?? () => Navigator.pop(context),
                  onCheckout: _handleOrderConfirmation,
                  showClearCart:
                      false, // Don't show clear cart on confirmation page
                  backButtonText: 'Go Back',
                  checkoutButtonText: 'Confirm Order',
                ),
              ],
            ),
    );
  }

  void _handleOrderConfirmation() async {
    if (widget.onOrderConfirmed != null) {
      widget.onOrderConfirmed!();
    } else {
      // Default behavior: save to Firebase and show success
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // Save cart to Firebase
        final bool saveSuccess = await widget.cartService.saveCartToFirebase();

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        if (saveSuccess) {
          // Clear cart and show success
          widget.cartService.clearCart();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order confirmed and saved successfully! 🎉'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.of(context).pop();
          }
        } else {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save order. Please try again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        // Close loading dialog if still open
        if (mounted) Navigator.of(context).pop();

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}
