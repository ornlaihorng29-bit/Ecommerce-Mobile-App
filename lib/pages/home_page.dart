// lib/pages/home_page.dart

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:ecommerce_mobile_app/pages/cart_page.dart';
import 'package:ecommerce_mobile_app/pages/product_page.dart' show ProductsPage;
import 'package:ecommerce_mobile_app/pages/profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_mobile_app/widgets/CategoriesWidget.dart';
import 'package:ecommerce_mobile_app/widgets/ItemsWidget.dart';
import 'package:ecommerce_mobile_app/services/storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex  = 0;
  int _profileReload = 0; // increment to trigger ProfilePage reload
  String _userName     = '';
  String _userInitials = '';

  static const _bg      = Color(0xFF0A0A14);
  static const _surface = Color(0xFF13131F);
  static const _border  = Color(0xFF1E1E2E);
  static const _accent  = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await StorageService.getName() ?? '';
    final initials = name.trim().split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    if (mounted) setState(() { _userName = name; _userInitials = initials; });
  }

  /// Called when the profile tab detects an edit was saved
  void _onProfileUpdated() {
    _loadUser();                          // refresh header initials
    setState(() => _profileReload++);    // force ProfilePage to re-fetch
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          const CartPage(),
          // _buildCartTab(),
          const ProductsPage(),
          // Pass reloadKey so ProfilePage knows when to re-fetch
          ProfilePage(
            key: ValueKey(_profileReload),
            reloadKey: _profileReload,
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: _bg,
        color: _surface,
        buttonBackgroundColor: _accent,
        height: 65,
        index: _currentIndex,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Refresh user name when switching to profile tab
          if (index == 3) _loadUser();
        },
        items: const [
          Icon(Icons.home_rounded,          size: 28, color: Colors.white),
          Icon(CupertinoIcons.cart_fill,     size: 26, color: Colors.white),
          Icon(Icons.shopping_bag_outlined,  size: 26, color: Colors.white),
          Icon(Icons.person_outline_rounded, size: 26, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Stack(
      children: [
        Positioned(top: -80, right: -80, child: _blob(260, _accent, 0.18)),
        Positioned(bottom: -100, left: -80, child: _blob(300, _accent2, 0.10)),
        SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName.isNotEmpty
                              ? 'Hello, $_userName 👋'
                              : 'Hello there 👋',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const Text('What\'s New 🛍',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = 3),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [_accent, _accent2]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: _accent.withOpacity(0.35),
                                blurRadius: 12, offset: const Offset(0, 4))
                          ],
                        ),
                        child: _userInitials.isNotEmpty
                            ? Center(
                                child: Text(_userInitials,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800)))
                            : const Icon(Icons.person_rounded,
                                color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: Row(children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search_rounded,
                        color: Colors.white.withOpacity(0.3), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search products...',
                          hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.2),
                              fontSize: 14),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(7),
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_accent, _accent2]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.camera_alt_outlined,
                          color: Colors.white, size: 18),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Categories',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3)),
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = 2),
                      child: Text('See all',
                          style: TextStyle(
                              color: _accent.withOpacity(0.8),
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              const CategoriesWidget(),
              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Best Selling',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3)),
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = 2),
                      child: Text('See all',
                          style: TextStyle(
                              color: _accent.withOpacity(0.8),
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              Itemswidget(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildCartTab() {
  //   return Stack(
  //     children: [
  //       Positioned(top: -80, left: -80, child: _blob(260, _accent, 0.15)),
  //       SafeArea(
  //         child: Column(children: [
  //           Padding(
  //             padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
  //             child: Row(children: const [
  //               Text('My Cart',
  //                   style: TextStyle(
  //                       color: Colors.white, fontSize: 26,
  //                       fontWeight: FontWeight.w800, letterSpacing: -0.5)),
  //             ]),
  //           ),
  //           Expanded(
  //             child: Center(
  //               child: Column(mainAxisSize: MainAxisSize.min, children: [
  //                 Container(
  //                   width: 90, height: 90,
  //                   decoration: BoxDecoration(
  //                       color: _surface,
  //                       borderRadius: BorderRadius.circular(26),
  //                       border: Border.all(color: _border)),
  //                   child: Icon(CupertinoIcons.cart,
  //                       size: 44, color: _accent.withOpacity(0.7)),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 const Text('Your cart is empty',
  //                     style: TextStyle(
  //                         color: Colors.white, fontSize: 18,
  //                         fontWeight: FontWeight.w700)),
  //                 const SizedBox(height: 8),
  //                 Text('Add items to get started',
  //                     style: TextStyle(
  //                         color: Colors.white.withOpacity(0.35),
  //                         fontSize: 14)),
  //                 const SizedBox(height: 28),
  //                 GestureDetector(
  //                   onTap: () => setState(() => _currentIndex = 2),
  //                   child: Container(
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 28, vertical: 13),
  //                     decoration: BoxDecoration(
  //                       gradient: const LinearGradient(
  //                           colors: [_accent, _accent2]),
  //                       borderRadius: BorderRadius.circular(30),
  //                       boxShadow: [
  //                         BoxShadow(color: _accent.withOpacity(0.4),
  //                             blurRadius: 16, offset: const Offset(0, 6))
  //                       ],
  //                     ),
  //                     child: const Text('Browse Products',
  //                         style: TextStyle(
  //                             color: Colors.white,
  //                             fontWeight: FontWeight.w700, fontSize: 15)),
  //                   ),
  //                 ),
  //               ]),
  //             ),
  //           ),
  //         ]),
  //       ),
  //     ],
  //   );
  // }

  Widget _blob(double size, Color color, double opacity) => Container(
      width: size, height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [color.withOpacity(opacity), Colors.transparent])));
}