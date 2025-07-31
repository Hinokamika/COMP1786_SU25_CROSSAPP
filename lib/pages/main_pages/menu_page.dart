import 'package:comp1876_su25_crossapp/pages/site_pages/home_page.dart';
import 'package:comp1876_su25_crossapp/pages/site_pages/profile_page.dart';
import 'package:comp1876_su25_crossapp/pages/site_pages/cart.dart';
import 'package:comp1876_su25_crossapp/widgets/shopping_cart_dropdown.dart';
import 'package:comp1876_su25_crossapp/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final CartService _cartService = CartService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Define page titles and colors for each tab
  final List<String> _pageTitles = ['Home', 'Cart', 'Profile'];

  final List<Color> _pageColors = [
    const Color(0xFF4CAF50), // Green for Home
    const Color(0xFFFF9800), // Orange for Cart
    const Color(0xFF9C27B0), // Purple for Profile
  ];

  final List<IconData> _pageIcons = [
    Icons.home_rounded,
    Icons.shopping_bag_rounded,
    Icons.person_rounded,
  ];

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

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    _animationController.dispose();
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

  Widget _buildFloatingActionButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          // Add quick action functionality here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Quick Action Available!'),
                ],
              ),
              backgroundColor: _pageColors[_currentIndex],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        backgroundColor: _pageColors[_currentIndex],
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Quick Action',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: _currentIndex == index ? 24 : 8,
            decoration: BoxDecoration(
              color: _currentIndex == index
                  ? _pageColors[_currentIndex]
                  : _pageColors[_currentIndex].withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _pageColors[_currentIndex],
                    _pageColors[_currentIndex].withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _pageIcons[_currentIndex],
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${_pageTitles[_currentIndex]} - Yoga App',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: _pageColors[_currentIndex],
              ),
            ),
          ],
        ),
        backgroundColor: theme.cardColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: _buildPageIndicator(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.cardColor, theme.cardColor.withOpacity(0.9)],
            ),
            boxShadow: [
              BoxShadow(
                color: _pageColors[_currentIndex].withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        actions: [
          // Enhanced Shopping Cart Dropdown
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // Add haptic feedback
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ShoppingCartDropdown(
                    cartItems: _cartService.cartItems,
                    onRemoveItem: removeFromCart,
                    onUpdateQuantity: updateQuantity,
                    onViewCart: viewCart,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.cardColor, theme.cardColor.withOpacity(0.95)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: _pageColors[_currentIndex].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(3, (index) {
                final isSelected = _currentIndex == index;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _currentIndex = index;
                    });
                    _animationController.reset();
                    _animationController.forward();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 20 : 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                _pageColors[index],
                                _pageColors[index].withOpacity(0.8),
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _pageColors[index].withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Icon(
                            _pageIcons[index],
                            color: isSelected
                                ? Colors.white
                                : theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.6),
                            size: isSelected ? 28 : 24,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          AnimatedOpacity(
                            opacity: isSelected ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _pageTitles[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
