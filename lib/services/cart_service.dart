import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  // Calculate total items in cart (always equals cartItems.length since quantity is always 1)
  int get totalCartItems {
    return _cartItems.length;
  }

  // Calculate total price (sum of all item prices since quantity is always 1)
  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item['price']);
  }

  // Add item to cart
  void addToCart(Map<String, dynamic> classData) {
    // Check if item already exists in cart
    final existingIndex = _cartItems.indexWhere(
      (item) => item['id'] == classData['id'],
    );

    if (existingIndex != -1) {
      // Item already exists, don't add again (quantity stays at 1)
      return;
    } else {
      // Item doesn't exist, add new item with quantity 1
      final double price = _parsePrice(classData['price_per_class']);

      _cartItems.add({
        'id': classData['id'],
        'name': classData['class_name'] ?? 'Unknown Class',
        'price': price,
        'quantity': 1,
        'teacher': classData['teacher'] ?? 'Unknown Teacher',
        'duration': classData['duration'] ?? '1 hour',
        'type': classData['type_of_class'] ?? 'Unknown',
      });
    }

    notifyListeners();
  }

  // Remove item from cart
  void removeFromCart(String itemId) {
    _cartItems.removeWhere((item) => item['id'] == itemId);
    notifyListeners();
  }

  // Update item quantity (only supports removal - quantity 0)
  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(itemId);
    }
    // Quantity can only be 1 or 0, so we don't update for values > 0
  }

  // Clear entire cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Helper method to parse price string
  double _parsePrice(String? priceString) {
    if (priceString == null || priceString.toLowerCase() == 'free') {
      return 0.0;
    }

    // Remove $ sign and any other non-numeric characters except decimal point
    String cleanPrice = priceString.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  // Check if item is in cart
  bool isInCart(String itemId) {
    return _cartItems.any((item) => item['id'] == itemId);
  }

  // Get quantity of specific item in cart
  int getItemQuantity(String itemId) {
    final item = _cartItems.firstWhere(
      (item) => item['id'] == itemId,
      orElse: () => {'quantity': 0},
    );
    return item['quantity'] ?? 0;
  }

  // Save cart items to Firebase Realtime Database
  Future<bool> saveCartToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in');
        return false;
      }

      if (_cartItems.isEmpty) {
        print('Cart is empty');
        return false;
      }

      final DatabaseReference userCartsRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('carts');

      // Create a timestamp for this cart save
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Prepare cart data
      final Map<String, dynamic> cartData = {
        'timestamp': timestamp,
        'total_price': totalPrice,
        'total_items': totalCartItems,
        'items': {},
      };

      // Add each cart item
      for (int i = 0; i < _cartItems.length; i++) {
        final item = _cartItems[i];
        cartData['items']['item_$i'] = {
          'class_id': item['id'],
          'class_name': item['name'],
          'price': item['price'],
          'teacher': item['teacher'],
          'duration': item['duration'],
          'type': item['type'],
          'quantity': item['quantity'],
        };
      }

      // Save to Firebase
      await userCartsRef.child(timestamp).set(cartData);
      print('Cart saved to Firebase successfully');
      return true;
    } catch (e) {
      print('Error saving cart to Firebase: $e');
      return false;
    }
  }

  // Get saved carts from Firebase Realtime Database
  Future<List<Map<String, dynamic>>> getSavedCartsFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in');
        return [];
      }

      final DatabaseReference userCartsRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('carts');

      final DataSnapshot snapshot = await userCartsRef.get();

      if (!snapshot.exists) {
        print('No saved carts found');
        return [];
      }

      final List<Map<String, dynamic>> savedCarts = [];
      final Map<dynamic, dynamic> cartsData =
          snapshot.value as Map<dynamic, dynamic>;

      cartsData.forEach((key, value) {
        if (value is Map) {
          final Map<String, dynamic> cartData = Map<String, dynamic>.from(
            value,
          );
          cartData['cart_id'] = key.toString();
          savedCarts.add(cartData);
        }
      });

      // Sort by timestamp (newest first)
      savedCarts.sort((a, b) {
        final timestampA = int.tryParse(a['timestamp']?.toString() ?? '0') ?? 0;
        final timestampB = int.tryParse(b['timestamp']?.toString() ?? '0') ?? 0;
        return timestampB.compareTo(timestampA);
      });

      print('Retrieved ${savedCarts.length} saved carts');
      return savedCarts;
    } catch (e) {
      print('Error getting saved carts from Firebase: $e');
      return [];
    }
  }
}
