// lib/pages/cart_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_mobile_app/models/cart_item_model.dart';
import 'package:ecommerce_mobile_app/provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/image_url.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  static const _bg      = Color(0xFF0A0A14);
  static const _surface = Color(0xFF13131F);
  static const _border  = Color(0xFF1E1E2E);
  static const _accent  = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── Background blobs ─────────────────────────────────────────
          Positioned(top: -80, right: -80,  child: _blob(260, _accent,  0.12)),
          Positioned(bottom: -100, left: -80, child: _blob(300, _accent2, 0.07)),

          SafeArea(
            child: Consumer<CartProvider>(
              builder: (context, cart, _) {
                return Column(
                  children: [
                    _AppBar(cart: cart),
                    Expanded(
                      child: cart.items.isEmpty
                          ? _EmptyState()
                          : _CartContent(cart: cart),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static Widget _blob(double size, Color color, double opacity) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [color.withOpacity(opacity), Colors.transparent],
      ),
    ),
  );
}

// ── App bar ────────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final CartProvider cart;
  const _AppBar({required this.cart});

  static const _accent  = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);
  static const _surface = Color(0xFF13131F);
  static const _border  = Color(0xFF1E1E2E);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white70, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text('My Cart',
                style: TextStyle(color: Colors.white, fontSize: 17,
                    fontWeight: FontWeight.w700)),
          ),
          // Item count badge
          if (cart.items.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_accent, _accent2]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'items'}',
                style: const TextStyle(color: Colors.white,
                    fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            // Clear all button
            GestureDetector(
              onTap: () => _showClearDialog(context, cart),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: const Text('Clear',
                    style: TextStyle(color: Colors.redAccent,
                        fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Cart',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('Remove all items from your cart?',
            style: TextStyle(color: Colors.white.withOpacity(0.5))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.4))),
          ),
          TextButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear all',
                style: TextStyle(color: Colors.redAccent,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  static const _accent  = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);
  static const _surface = Color(0xFF13131F);
  static const _border  = Color(0xFF1E1E2E);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96, height: 96,
            decoration: BoxDecoration(
              color: _surface,
              shape: BoxShape.circle,
              border: Border.all(color: _border),
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                color: _accent, size: 42),
          ),
          const SizedBox(height: 20),
          const Text('Your cart is empty',
              style: TextStyle(color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Add products to get started',
              style: TextStyle(color: Colors.white.withOpacity(0.35),
                  fontSize: 14)),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_accent, _accent2]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                    color: _accent.withOpacity(0.4),
                    blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: const Text('Browse Products',
                  style: TextStyle(color: Colors.white,
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cart content (list + checkout panel) ──────────────────────────────────────

class _CartContent extends StatelessWidget {
  final CartProvider cart;
  const _CartContent({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 240),
          itemCount: cart.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _CartItemCard(item: cart.items[i]),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _CheckoutPanel(cart: cart),
        ),
      ],
    );
  }
}

// ── Cart item card ─────────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  const _CartItemCard({required this.item});

  static const _bg      = Color(0xFF0A0A14);
  static const _surface = Color(0xFF13131F);
  static const _border  = Color(0xFF1E1E2E);
  static const _accent  = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Dismissible(
      key: ValueKey('${item.productId}_${item.selectedColor}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => cart.removeItem(
          item.productId, selectedColor: item.selectedColor),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withOpacity(0.25)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded,
                color: Colors.redAccent, size: 26),
            SizedBox(height: 4),
            Text('Remove', style: TextStyle(color: Colors.redAccent,
                fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            // ── Product image ──────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: resolveImageUrl(item.imageUrl!),
                      width: 82, height: 82,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _imgPlaceholder(),
                      errorWidget: (_, __, ___) => _imgError(),
                    )
                  : _imgError(),
            ),

            const SizedBox(width: 14),

            // ── Info ───────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(item.name,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white,
                          fontSize: 14, fontWeight: FontWeight.w700,
                          height: 1.3)),

                  const SizedBox(height: 6),

                  // Color badge
                  if (item.selectedColor != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_accent, _accent2]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: _colorFromName(item.selectedColor!),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white24, width: 0.5),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(item.selectedColor!,
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Unit price + quantity controls
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\$${item.price.toStringAsFixed(2)} each',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(color: _accent,
                                fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Quantity stepper
                      Container(
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _border),
                        ),
                        child: Row(
                          children: [
                            _qBtn(Icons.remove_rounded, () =>
                                cart.updateQuantity(
                                    item.productId, item.quantity - 1,
                                    selectedColor: item.selectedColor)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: Text('${item.quantity}',
                                  style: const TextStyle(color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                            ),
                            _qBtn(Icons.add_rounded, () =>
                                cart.updateQuantity(
                                    item.productId, item.quantity + 1,
                                    selectedColor: item.selectedColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
      width: 82, height: 82, color: const Color(0xFF1E1E2E),
      child: const Center(child: CircularProgressIndicator(
          strokeWidth: 2, color: Color(0xFF6C63FF))));

  Widget _imgError() => Container(
      width: 82, height: 82, color: const Color(0xFF1E1E2E),
      child: const Icon(Icons.image_not_supported_outlined,
          color: Color(0xFF6C63FF), size: 28));

  Widget _qBtn(IconData icon, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      child: Container(width: 32, height: 32,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Icon(icon,
              color: Colors.white.withOpacity(0.7), size: 16)));
}

// ── Checkout panel ─────────────────────────────────────────────────────────────

class _CheckoutPanel extends StatelessWidget {
  final CartProvider cart;
  const _CheckoutPanel({required this.cart});

  static const _bg      = Color(0xFF0A0A14);
  static const _border  = Color(0xFF1E1E2E);
  static const _accent  = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: _border)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 24, offset: const Offset(0, -6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary rows
          _row('Subtotal (${cart.itemCount} items)',
              '\$${cart.totalPrice.toStringAsFixed(2)}', false),
          const SizedBox(height: 8),
          _row('Shipping', 'Free', false,
              valueColor: const Color(0xFF22C55E)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: _border, height: 1),
          ),
          _row('Total', '\$${cart.totalPrice.toStringAsFixed(2)}', true),
          const SizedBox(height: 16),

          // Checkout button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_accent, Color(0xFF9B5CF6)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                    color: _accent.withOpacity(0.45),
                    blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.bolt_rounded,
                    color: Colors.white, size: 20),
                label: const Text('Proceed to Checkout',
                    style: TextStyle(color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.w700, letterSpacing: 0.2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, bool isBold, {Color? valueColor}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: isBold
                      ? Colors.white
                      : Colors.white.withOpacity(0.45),
                  fontSize: isBold ? 15 : 13,
                  fontWeight:
                      isBold ? FontWeight.w700 : FontWeight.w400)),
          Text(value,
              style: TextStyle(
                  color: valueColor ??
                      (isBold
                          ? Colors.white
                          : Colors.white.withOpacity(0.65)),
                  fontSize: isBold ? 18 : 13,
                  fontWeight:
                      isBold ? FontWeight.w800 : FontWeight.w500)),
        ],
      );
}

// ── Color helper (mirrors product_detail_page.dart) ───────────────────────────

Color _colorFromName(String name) {
  switch (name.toLowerCase().replaceAll(' ', '')) {
    case 'beige':             return const Color(0xFFF5F0E8);
    case 'fogblue':
    case 'blue':              return const Color(0xFF9BB7D4);
    case 'black':             return const Color(0xFF1A1A1A);
    case 'white':             return const Color(0xFFF5F5F5);
    case 'red':               return const Color(0xFFE53935);
    case 'green':             return const Color(0xFF43A047);
    case 'brown':             return const Color(0xFF795548);
    case 'pink':              return const Color(0xFFF48FB1);
    case 'gray': case 'grey': return const Color(0xFF9E9E9E);
    case 'navy':              return const Color(0xFF1A237E);
    case 'yellow':            return const Color(0xFFFDD835);
    case 'orange':            return const Color(0xFFFF7043);
    default:                  return const Color(0xFFBDBDBD);
  }
}