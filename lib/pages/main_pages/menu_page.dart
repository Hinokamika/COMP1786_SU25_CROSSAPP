import 'package:comp1876_su25_crossapp/pages/site_pages/home_page.dart';
import 'package:comp1876_su25_crossapp/pages/site_pages/noti_page.dart';
import 'package:comp1876_su25_crossapp/pages/site_pages/profile_page.dart';
import 'package:comp1876_su25_crossapp/pages/site_pages/search_page.dart';
import 'package:comp1876_su25_crossapp/pages/site_pages/cart.dart';
import 'package:comp1876_su25_crossapp/widgets/shopping_cart_dropdown.dart';
import 'package:comp1876_su25_crossapp/services/cart_service.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _currentIndex = 0;
  final CartService _cartService = CartService();

  // Define your different page widgets here
  final List<Widget> _pages = [
    const HomePage(),
    const Cart(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Listen to cart changes to update the UI
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    // Trigger rebuild when cart changes
    setState(() {});
  }

  // Remove item from cart using CartService
  void removeFromCart(String itemId) {
    _cartService.removeFromCart(itemId);
  }

  // Update item quantity using CartService
  void updateQuantity(String itemId, int newQuantity) {
    _cartService.updateQuantity(itemId, newQuantity);
  }

  // Navigate to cart page
  void viewCart() {
    Navigator.pushNamed(context, '/ShowCart');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoga App'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 4,
        automaticallyImplyLeading: false,
        actions: [
          // Shopping Cart Dropdown
          ShoppingCartDropdown(
            cartItems: _cartService.cartItems,
            onRemoveItem: removeFromCart,
            onUpdateQuantity: updateQuantity,
            onViewCart: viewCart,
          ),
          PopupMenuButton<String>(
            onSelected: (String route) {
              Navigator.pushNamed(context, route);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: '/Profile',
                child: Text('Profile Settings'),
              ),
              const PopupMenuItem<String>(
                value: '/About',
                child: Text('About'),
              ),
            ],
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 60, right: 60, bottom: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentIndex,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.grey,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedIconTheme: const IconThemeData(size: 36),
                unselectedIconTheme: const IconThemeData(size: 33),
                selectedLabelStyle: const TextStyle(fontSize: 0),
                unselectedLabelStyle: const TextStyle(fontSize: 0),
                onTap: (int newIndex) {
                  setState(() {
                    _currentIndex = newIndex;
                  });
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_bag),
                    label: '',
                  ),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
