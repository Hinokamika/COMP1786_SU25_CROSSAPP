# Cart Firebase Integration Documentation

## Overview

The cart system has been successfully refactored and enhanced with Firebase Realtime Database integration. When users press "Proceed to Checkout", their cart items are automatically saved to Firebase under the user's profile.

## Key Features Implemented

### 1. Modular Components

The cart system has been split into reusable components:

- **`CartHeader`** - Displays cart title and item count
- **`CartItemCard`** - Individual cart item display with optional remove button or confirmed badge
- **`CartSummary`** - Total price display and action buttons (clear cart, checkout)
- **`EmptyCartWidget`** - Empty state display
- **`OrderConfirmationPage`** - Dedicated page for order confirmation

### 2. Firebase Integration

- **Automatic Save**: Cart items are saved to Firebase when checkout is initiated
- **Database Structure**:
  ```
  users/
    {userId}/
      carts/
        {timestamp}/
          timestamp: "1703876543210"
          total_price: 99.99
          total_items: 3
          items/
            item_0/
              class_id: "class123"
              class_name: "Yoga Basics"
              price: 29.99
              teacher: "John Doe"
              duration: "1 hour"
              type: "Beginner"
              quantity: 1
            item_1/
              ...
  ```

### 3. Error Handling

- Loading indicators during Firebase operations
- Success/error messages via SnackBar
- Graceful fallback for network issues
- Proper mounted checks to prevent memory leaks

## Usage Examples

### Basic Cart Page

```dart
// The main cart page - now clean and simple
class Cart extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cartService.cartItems.isEmpty
          ? const EmptyCartWidget()
          : Column(
              children: [
                CartHeader(title: 'Shopping Cart', itemCount: _cartService.cartItems.length),
                Expanded(child: /* cart items list */),
                CartSummary(cartService: _cartService), // Automatic Firebase save
              ],
            ),
    );
  }
}
```

### Custom Order Confirmation

```dart
// Navigate to order confirmation page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => OrderConfirmationPage(
      cartService: cartService,
      title: 'Confirm Your Classes',
      onOrderConfirmed: () async {
        // Custom confirmation logic
        await customOrderProcessing();
        // Firebase save happens automatically
      },
    ),
  ),
);
```

### Custom Cart Summary

```dart
CartSummary(
  cartService: cartService,
  showClearCart: false, // Hide clear cart button
  backButtonText: 'Continue Shopping',
  checkoutButtonText: 'Complete Order',
  onCheckout: () async {
    // Custom checkout with Firebase save
    await processCustomCheckout();
  },
)
```

## Firebase Data Flow

1. **User adds items to cart** → Items stored in `CartService`
2. **User clicks "Proceed to Checkout"** → Loading dialog appears
3. **Firebase save initiated** → `CartService.saveCartToFirebase()` called
4. **Data saved to Firebase** → Under `users/{userId}/carts/{timestamp}`
5. **Success feedback** → SnackBar shown, cart cleared
6. **Error handling** → If save fails, user notified, cart preserved

## Retrieving Saved Carts

```dart
// Get user's saved carts
final List<Map<String, dynamic>> savedCarts = await cartService.getSavedCartsFromFirebase();

for (final cart in savedCarts) {
  print('Cart from ${DateTime.fromMillisecondsSinceEpoch(int.parse(cart['timestamp']))}');
  print('Total: \$${cart['total_price']}');
  print('Items: ${cart['total_items']}');

  final items = cart['items'] as Map<String, dynamic>;
  items.forEach((key, item) {
    print('- ${item['class_name']}: \$${item['price']}');
  });
}
```

## Benefits of This Implementation

1. **Maintainable**: Each component has a single responsibility
2. **Reusable**: Components can be used in different contexts
3. **Scalable**: Easy to add new features or modify existing ones
4. **Robust**: Proper error handling and user feedback
5. **Firebase Integration**: Automatic data persistence
6. **User Experience**: Loading states, success/error feedback

## Files Structure

```
lib/
  services/
    cart_service.dart           # Enhanced with Firebase save/retrieve
  widgets/
    cart_header.dart           # Reusable header component
    cart_item_card.dart        # Individual item display
    cart_summary.dart          # Total and actions with Firebase integration
    empty_cart_widget.dart     # Empty state component
  pages/
    site_pages/
      cart.dart                # Main cart page (simplified)
      order_confirmation_page.dart  # Dedicated confirmation page
```

The implementation is now production-ready with proper separation of concerns, error handling, and Firebase integration!
