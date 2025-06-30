import 'package:comp1876_su25_crossapp/services/cart_service.dart';
import 'package:comp1876_su25_crossapp/widgets/checkout_dialog.dart';
import 'package:comp1876_su25_crossapp/widgets/customDialog.dart';
import 'package:flutter/material.dart';

class CartSummary extends StatelessWidget {
  final CartService cartService;
  final VoidCallback? onBackPressed;
  final VoidCallback? onCheckout;
  final bool showClearCart;
  final String backButtonText;
  final String checkoutButtonText;

  // Add processing flag to prevent multiple simultaneous checkouts
  static bool _isProcessingCheckout = false;

  const CartSummary({
    super.key,
    required this.cartService,
    this.onBackPressed,
    this.onCheckout,
    this.showClearCart = true,
    this.backButtonText = 'Go Back',
    this.checkoutButtonText = 'Proceed to Checkout',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildTotalRow(),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total (${cartService.cartItems.length} ${cartService.cartItems.length == 1 ? 'class' : 'classes'}):',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '\$${cartService.totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF3333),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (showClearCart)
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showClearCartDialog(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Clear Cart',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (showClearCart && onBackPressed != null) const SizedBox(width: 16),
        if (onBackPressed != null)
          Expanded(
            child: OutlinedButton(
              onPressed: onBackPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                backButtonText,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: cartService.cartItems.isNotEmpty
                ? () => _handleCheckout(context)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3333),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              checkoutButtonText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context) {
    CustomDialog.show(
      context,
      title: 'Clear Cart',
      content: 'Are you sure you want to remove all items from your cart?',
      confirmText: 'Clear All',
      onConfirm: () {
        cartService.clearCart();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cart cleared successfully'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  void _handleCheckout(BuildContext context) async {
    if (onCheckout != null) {
      // Use custom checkout callback
      onCheckout!();
      return;
    }

    // Prevent multiple simultaneous checkout operations
    if (_isProcessingCheckout) return;
    _isProcessingCheckout = true;

    try {
      // Show checkout dialog with Firebase save
      await CheckOutDialog.show(
        context,
        cartService: cartService,
        onConfirm: () async {
          // Save to Firebase first
          final bool saveSuccess = await cartService.saveCartToFirebase();

          if (saveSuccess) {
            // Clear cart after successful save
            cartService.clearCart();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order confirmed and saved! 🎉'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else {
            // Show error if save failed
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to save order. Please try again.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
      );

      _isProcessingCheckout = false;
    } catch (e) {
      _isProcessingCheckout = false;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error processing order'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
