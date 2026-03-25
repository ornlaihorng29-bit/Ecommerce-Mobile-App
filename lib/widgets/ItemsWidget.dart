// lib/widgets/ItemsWidget.dart

import 'package:ecommerce_mobile_app/pages/product_detail_page.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ItemsWidget extends StatefulWidget {
  const ItemsWidget({super.key});

  @override
  State<ItemsWidget> createState() => _ItemsWidgetState();
}

class _ItemsWidgetState extends State<ItemsWidget> {
  late Future<ProductClientHomeViewResponse> _future;
  final ProductService _productService = ProductService();

  static const _accent  = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);
  static const _surface = Color(0xFF13131F);
  static const _border  = Color(0xFF1E1E2E);

  @override
  void initState() {
    super.initState();
    _future = _productService.getProductClientHomeView();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductClientHomeViewResponse>(
      future: _future,
      builder: (context, snapshot) {

        // ── Loading ───────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            ),
          );
        }

        // ── Error ─────────────────────────────────────────────
        if (snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Color(0xFFEF4444), size: 40),
                const SizedBox(height: 12),
                Text(
                  'Failed to load products',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() {
                    _future = _productService.getProductClientHomeView();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_accent, _accent2]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Retry',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        }

        // ── Empty ─────────────────────────────────────────────
        final products = snapshot.data!.data;
        if (products.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'No products available',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 14),
              ),
            ),
          );
        }

        // ── Grid ──────────────────────────────────────────────
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) =>
              _ProductCard(product: products[index]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Product Card
// ─────────────────────────────────────────────
class _ProductCard extends StatefulWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _wished = false;

  static const _accent  = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);
  static const _surface = Color(0xFF13131F);
  static const _border  = Color(0xFF1E1E2E);

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(productId: p.id),
        ),
      ),
      child: Container(                          // ✅ fixed — decoration inside Container
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Image + wishlist ──────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  child: Image.network(
                    p.image,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: Colors.white.withOpacity(0.05),
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: Colors.white24, size: 40),
                    ),
                    loadingBuilder: (_, child, progress) =>
                    progress == null
                        ? child
                        : Container(
                      height: 140,
                      color: Colors.white.withOpacity(0.03),
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6C63FF),
                            strokeWidth: 2),
                      ),
                    ),
                  ),
                ),

                // Wishlist button
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _wished = !_wished),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _wished
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _wished
                            ? const Color(0xFFEF4444)
                            : Colors.white54,
                        size: 16,
                      ),
                    ),
                  ),
                ),

                // Rating badge
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_accent, _accent2]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.white, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          p.rate.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Info ──────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Category
                    Text(
                      p.category,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 3),

                    // Name
                    Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.3),
                    ),

                    const Spacer(),

                    // Price + cart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${p.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Color(0xFF6C63FF),
                              fontSize: 15,
                              fontWeight: FontWeight.w800),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [_accent, _accent2]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}