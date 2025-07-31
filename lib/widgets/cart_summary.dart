import 'package:comp1876_su25_crossapp/services/cart_service.dart';
import 'package:comp1876_su25_crossapp/widgets/checkout_dialog.dart';
import 'package:comp1876_su25_crossapp/widgets/customDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.brightness == Brightness.dark
                ? Colors.grey[900]!
                : Colors.white,
            theme.brightness == Brightness.dark
                ? Colors.grey[850]!
                : const Color(0xFFFFF8E1),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.2),
            blurRadius: isSmallScreen ? 12 : 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTotalRow(isSmallScreen),
            SizedBox(height: isSmallScreen ? 8 : 12),
            _buildActionButtons(context, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.3),
            blurRadius: isSmallScreen ? 6 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                '${cartService.cartItems.length} ${cartService.cartItems.length == 1 ? 'class' : 'classes'}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
            ),
            child: Text(
              '\$${cartService.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isSmallScreen) {
    final buttonHeight = isSmallScreen ? 36.0 : 42.0;
    final spacing = isSmallScreen ? 8.0 : 12.0;

    return Row(
      children: [
        if (showClearCart)
          Expanded(
            child: Container(
              height: buttonHeight,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFFF5252),
                  width: isSmallScreen ? 1.5 : 2,
                ),
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              ),
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showClearCartDialog(context);
                },
                icon: Icon(
                  Icons.clear_all_rounded,
                  size: isSmallScreen ? 18 : 20,
                ),
                label: Text(
                  'Clear Cart',
                  style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF5252),
                  side: BorderSide.none,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 12 : 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (showClearCart && onBackPressed != null) SizedBox(width: spacing),
        if (onBackPressed != null)
          Expanded(
            child: Container(
              height: buttonHeight,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: isSmallScreen ? 1.5 : 2,
                ),
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              ),
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onBackPressed!();
                },
                icon: Icon(
                  Icons.arrow_back_rounded,
                  size: isSmallScreen ? 18 : 20,
                ),
                label: Text(
                  backButtonText,
                  style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide.none,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 12 : 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        SizedBox(width: spacing),
        Expanded(
          flex: 2,
          child: Container(
            height: buttonHeight,
            decoration: BoxDecoration(
              gradient: cartService.cartItems.isNotEmpty
                  ? const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                    )
                  : null,
              color: cartService.cartItems.isEmpty ? Colors.grey[300] : null,
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              boxShadow: cartService.cartItems.isNotEmpty
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF9800).withOpacity(0.4),
                        blurRadius: isSmallScreen ? 6 : 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton.icon(
              onPressed: cartService.cartItems.isNotEmpty
                  ? () {
                      HapticFeedback.mediumImpact();
                      _handleCheckout(context);
                    }
                  : null,
              icon: Icon(Icons.payment_rounded, size: isSmallScreen ? 18 : 20),
              label: Text(
                checkoutButtonText,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                ),
              ),
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
