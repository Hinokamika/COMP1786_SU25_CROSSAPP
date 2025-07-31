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
    try {
      // Debug: Print incoming data structure
      if (kDebugMode) {
        print('CartService: Adding item to cart');
        print('CartService: Original data keys: ${classData.keys.toList()}');
        print(
          'CartService: Sample values - name: ${classData['class_name'] ?? classData['name']}, price: ${classData['price_per_class'] ?? classData['price']}',
        );
      }

      // Check if item already exists in cart
      final String itemId = _extractItemId(classData);
      final existingIndex = _cartItems.indexWhere(
        (item) => item['id'] == itemId,
      );

      if (existingIndex != -1) {
        // Item already exists, don't add again (quantity stays at 1)
        if (kDebugMode) {
          print('CartService: Item with ID $itemId already exists in cart');
        }
        return;
      } else {
        // Item doesn't exist, add new item with quantity 1
        final Map<String, dynamic> cartItem = _normalizeClassData(classData);

        if (kDebugMode) {
          print('CartService: Normalized cart item: ${cartItem.keys.toList()}');
          print(
            'CartService: Final item - name: ${cartItem['name']}, price: ${cartItem['price']}, teacher: ${cartItem['teacher']}',
          );
        }

        _cartItems.add(cartItem);
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('CartService: Error adding item to cart: $e');
        print('CartService: Problematic data: $classData');
      }
      // Still try to add a basic item to prevent app crashes
      _cartItems.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': 'Unknown Class',
        'price': 0.0,
        'quantity': 1,
        'teacher': 'Unknown Teacher',
        'duration': '1 hour',
        'type': 'General',
        'description': '',
        'location': '',
        'originalData': classData,
      });
      notifyListeners();
    }
  }

  // Helper method to extract item ID from various possible field names
  String _extractItemId(Map<String, dynamic> classData) {
    return classData['id']?.toString() ??
        classData['classId']?.toString() ??
        classData['class_id']?.toString() ??
        classData['key']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString(); // fallback unique ID
  }

  // Helper method to normalize class data into standardized cart item format
  Map<String, dynamic> _normalizeClassData(Map<String, dynamic> classData) {
    // Extract price from multiple possible fields
    final double price = _extractPrice(classData);

    // Extract teacher name from multiple possible fields
    final String teacherName = _extractTeacherName(classData);

    // Extract class name from multiple possible fields
    final String className = _extractClassName(classData);

    // Extract duration from multiple possible fields
    final String duration = _extractDuration(classData);

    // Extract class type from multiple possible fields
    final String classType = _extractClassType(classData);

    // Extract additional information that might be useful
    final String description =
        classData['description']?.toString() ??
        classData['class_description']?.toString() ??
        '';

    final String location =
        classData['location']?.toString() ??
        classData['class_location']?.toString() ??
        '';

    return {
      'id': _extractItemId(classData),
      'name': className,
      'price': price,
      'quantity': 1,
      'teacher': teacherName,
      'duration': duration,
      'type': classType,
      'description': description,
      'location': location,
      // Keep original data for reference if needed
      'originalData': Map<String, dynamic>.from(classData),
    };
  }

  // Helper method to extract price from various field formats
  double _extractPrice(Map<String, dynamic> classData) {
    // Try multiple price field names
    final dynamic priceValue =
        classData['price'] ??
        classData['price_per_class'] ??
        classData['pricePerClass'] ??
        classData['cost'] ??
        classData['amount'] ??
        0;

    if (priceValue is double) return priceValue;
    if (priceValue is int) return priceValue.toDouble();
    if (priceValue is String) return _parsePrice(priceValue);

    return 0.0;
  }

  // Helper method to extract teacher name from various field formats
  String _extractTeacherName(Map<String, dynamic> classData) {
    return classData['teacherName']?.toString() ??
        classData['teacher']?.toString() ??
        classData['teacher_name']?.toString() ??
        classData['instructor']?.toString() ??
        classData['instructorName']?.toString() ??
        'Unknown Teacher';
  }

  // Helper method to extract class name from various field formats
  String _extractClassName(Map<String, dynamic> classData) {
    return classData['class_name']?.toString() ??
        classData['className']?.toString() ??
        classData['name']?.toString() ??
        classData['title']?.toString() ??
        classData['class_title']?.toString() ??
        'Unknown Class';
  }

  // Helper method to extract duration from various field formats
  String _extractDuration(Map<String, dynamic> classData) {
    final dynamic durationValue =
        classData['duration'] ??
        classData['class_duration'] ??
        classData['time'] ??
        classData['length'];

    if (durationValue == null) return '1 hour';

    String durationStr = durationValue.toString();

    // If duration is just a number, assume it's minutes
    if (RegExp(r'^\d+$').hasMatch(durationStr)) {
      int minutes = int.tryParse(durationStr) ?? 60;
      if (minutes >= 60) {
        int hours = minutes ~/ 60;
        int remainingMinutes = minutes % 60;
        if (remainingMinutes == 0) {
          return '$hours hour${hours > 1 ? 's' : ''}';
        } else {
          return '${hours}h ${remainingMinutes}m';
        }
      } else {
        return '$minutes minutes';
      }
    }

    // If already formatted, return as is
    return durationStr;
  }

  // Helper method to extract class type from various field formats
  String _extractClassType(Map<String, dynamic> classData) {
    return classData['type_of_class']?.toString() ??
        classData['typeOfClass']?.toString() ??
        classData['class_type']?.toString() ??
        classData['type']?.toString() ??
        classData['category']?.toString() ??
        'General';
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

  // Helper method to parse price string - enhanced for better handling
  double _parsePrice(String? priceString) {
    if (priceString == null || priceString.isEmpty) {
      return 0.0;
    }

    // Convert to lowercase for easier matching
    String lowerPrice = priceString.toLowerCase().trim();

    // Handle free cases
    if (lowerPrice == 'free' || lowerPrice == 'no cost' || lowerPrice == '0') {
      return 0.0;
    }

    // Remove common currency symbols and characters
    String cleanPrice = priceString
        .replaceAll(
          RegExp(r'[^\d.,]'),
          '',
        ) // Keep only digits, dots, and commas
        .replaceAll(',', ''); // Remove commas used as thousands separators

    // Handle empty string after cleaning
    if (cleanPrice.isEmpty) {
      return 0.0;
    }

    // Parse the cleaned price
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  // Check if item is in cart - enhanced to handle various ID formats
  bool isInCart(dynamic itemIdentifier) {
    String searchId;

    if (itemIdentifier is Map<String, dynamic>) {
      // If a full class data object is passed, extract the ID
      searchId = _extractItemId(itemIdentifier);
    } else {
      // If just an ID string is passed
      searchId = itemIdentifier.toString();
    }

    return _cartItems.any((item) => item['id'] == searchId);
  }

  // Get quantity of specific item in cart - enhanced to handle various ID formats
  int getItemQuantity(dynamic itemIdentifier) {
    String searchId;

    if (itemIdentifier is Map<String, dynamic>) {
      // If a full class data object is passed, extract the ID
      searchId = _extractItemId(itemIdentifier);
    } else {
      // If just an ID string is passed
      searchId = itemIdentifier.toString();
    }

    final item = _cartItems.firstWhere(
      (item) => item['id'] == searchId,
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

  // Debug utility - print expected vs actual data structure
  void debugDataStructure(Map<String, dynamic> classData) {
    if (kDebugMode) {
      print('\n=== CartService Data Structure Analysis ===');
      print('Expected fields and their current values:');
      print(
        'ID: ${_extractItemId(classData)} (from: id, classId, class_id, key)',
      );
      print(
        'Name: ${_extractClassName(classData)} (from: class_name, className, name, title)',
      );
      print(
        'Price: ${_extractPrice(classData)} (from: price, price_per_class, pricePerClass, cost)',
      );
      print(
        'Teacher: ${_extractTeacherName(classData)} (from: teacherName, teacher, teacher_name, instructor)',
      );
      print(
        'Duration: ${_extractDuration(classData)} (from: duration, class_duration, time, length)',
      );
      print(
        'Type: ${_extractClassType(classData)} (from: type_of_class, typeOfClass, class_type, type)',
      );
      print('All available keys in data: ${classData.keys.toList()}');
      print('==========================================\n');
    }
  }

  // Utility to get missing required fields
  List<String> getMissingFields(Map<String, dynamic> classData) {
    List<String> missing = [];

    if (_extractItemId(classData) ==
        DateTime.now().millisecondsSinceEpoch.toString()) {
      missing.add('id (no valid ID field found)');
    }
    if (_extractClassName(classData) == 'Unknown Class') {
      missing.add('class_name (no valid name field found)');
    }
    if (_extractPrice(classData) == 0.0 &&
        !classData.containsKey('price') &&
        !classData.containsKey('price_per_class')) {
      missing.add('price (no valid price field found)');
    }
    if (_extractTeacherName(classData) == 'Unknown Teacher') {
      missing.add('teacher (no valid teacher field found)');
    }

    return missing;
  }
}
