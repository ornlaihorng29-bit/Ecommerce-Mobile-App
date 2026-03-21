// lib/pages/product_detail_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_mobile_app/models/cart_item_model.dart';
import 'package:ecommerce_mobile_app/provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';   
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../utils/image_url.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _service = ProductService();
  late Future<ProductDetail> _future;

  static const _bg = Color(0xFF0A0A14);
  static const _surface = Color(0xFF13131F);
  static const _border = Color(0xFF1E1E2E);
  static const _accent = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);

  @override
  void initState() {
    super.initState();
    _future = _service.getProductDetail(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(top: -80, right: -80, child: _blob(260, _accent, 0.15)),
          Positioned(
            bottom: -100,
            left: -80,
            child: _blob(300, _accent2, 0.08),
          ),
          SafeArea(
            child: FutureBuilder<ProductDetail>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoading();
                }
                if (snapshot.hasError) {
                  return _buildError(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                  );
                }
                return _ProductBody(product: snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        _backBar(''),
        Container(
          height: 320,
          color: _surface,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF6C63FF),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sh(28, 220),
              const SizedBox(height: 12),
              _sh(18, 100),
              const SizedBox(height: 20),
              _sh(14, double.infinity),
              const SizedBox(height: 8),
              _sh(14, double.infinity),
              const SizedBox(height: 8),
              _sh(14, 180),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError(String msg) {
    return Column(
      children: [
        _backBar(''),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent.withOpacity(0.7),
                    size: 52,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => setState(
                      () =>
                          _future = _service.getProductDetail(widget.productId),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_accent, _accent2],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _backBar(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white70,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _sh(double h, double w) => Container(
    height: h,
    width: w,
    margin: const EdgeInsets.only(bottom: 4),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(8),
    ),
  );

  Widget _blob(double size, Color color, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [color.withOpacity(opacity), Colors.transparent],
      ),
    ),
  );
}

// ── Product body ───────────────────────────────────────────────────────────────

class _ProductBody extends StatefulWidget {
  final ProductDetail product;
  const _ProductBody({required this.product});

  @override
  State<_ProductBody> createState() => _ProductBodyState();
}

class _ProductBodyState extends State<_ProductBody> {
  int _imageIdx = 0;
  String? _selectedColor;
  int _quantity = 1;

  final _pageCtrl = PageController();

  static const _bg = Color(0xFF0A0A14);
  static const _surface = Color(0xFF13131F);
  static const _border = Color(0xFF1E1E2E);
  static const _accent = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);

  @override
  void initState() {
    super.initState();
    if (widget.product.color.isNotEmpty) {
      _selectedColor = widget.product.color.first;
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final images = p.imageUrls;

    return Column(
      children: [
        // ── App bar ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image pager ─────────────────────────────────────
                    Stack(
                      children: [
                        SizedBox(
                          height: 320,
                          child: PageView.builder(
                            controller: _pageCtrl,
                            itemCount: images.length,
                            onPageChanged: (i) => setState(() => _imageIdx = i),
                            itemBuilder: (_, i) => CachedNetworkImage(
                              imageUrl: resolveImageUrl(images[i]),
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: _surface,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _accent,
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: _surface,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: _accent,
                                  size: 52,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Fade bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [_bg, Colors.transparent],
                              ),
                            ),
                          ),
                        ),
                        // Dot indicators
                        if (images.length > 1)
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(images.length, (i) {
                                final a = i == _imageIdx;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  width: a ? 20 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: a
                                        ? _accent
                                        : Colors.white.withOpacity(0.3),
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    ),

                    // ── Thumbnail strip ──────────────────────────────────
                    if (images.length > 1) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 64,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: images.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final a = i == _imageIdx;
                            return GestureDetector(
                              onTap: () => _pageCtrl.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: a ? _accent : _border,
                                    width: a ? 2 : 1,
                                  ),
                                  boxShadow: a
                                      ? [
                                          BoxShadow(
                                            color: _accent.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: CachedNetworkImage(
                                    imageUrl: resolveImageUrl(images[i]),
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) =>
                                        Container(color: _surface),
                                    errorWidget: (_, __, ___) =>
                                        Container(color: _surface),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    // ── Info ─────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category + rating
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_accent, _accent2],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  p.category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (p.rate > 0) ...[
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFC107),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${p.rate}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ] else
                                Text(
                                  'No ratings yet',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Text(
                            p.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.3,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Price + quantity
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _accent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _accent.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  '\$${p.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: _accent,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: _surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _border),
                                ),
                                child: Row(
                                  children: [
                                    _qBtn(Icons.remove_rounded, () {
                                      if (_quantity > 1) {
                                        setState(() => _quantity--);
                                      }
                                    }),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Text(
                                        '$_quantity',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    _qBtn(
                                      Icons.add_rounded,
                                      () => setState(() => _quantity++),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            height: 1,
                            color: _border,
                          ),

                          // Color picker
                          if (p.color.isNotEmpty) ...[
                            Text(
                              'Select Color',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withOpacity(0.65),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: p.color.map((c) {
                                final sel = _selectedColor == c;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedColor = c),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: sel
                                          ? const LinearGradient(
                                              colors: [_accent, _accent2],
                                            )
                                          : null,
                                      color: sel ? null : _surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: sel
                                            ? Colors.transparent
                                            : _border,
                                      ),
                                      boxShadow: sel
                                          ? [
                                              BoxShadow(
                                                color: _accent.withOpacity(
                                                  0.35,
                                                ),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: _colorFromName(c),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white24,
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 7),
                                        Text(
                                          c,
                                          style: TextStyle(
                                            color: sel
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.6),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              height: 1,
                              color: _border,
                            ),
                          ],

                          // Description
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            p.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.45),
                              height: 1.7,
                            ),
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Sticky bottom bar ───────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: BoxDecoration(
                    color: _bg,
                    border: Border(top: BorderSide(color: _border)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$${(p.price * _quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_accent, Color(0xFF9B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _accent.withOpacity(0.45),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final cart = Provider.of<CartProvider>(
                                  context,
                                  listen: false,
                                );

                                cart.addToCart(
                                  CartItem(
                                    productId: p.id, // your product ID field
                                    name: p.name,
                                    price: p.price,
                                    imageUrl: p.imageUrls.isNotEmpty
                                        ? p.imageUrls.first
                                        : null,
                                    selectedColor: _selectedColor,
                                    quantity:
                                        _quantity, // uses the quantity picker value
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${p.name} × $_quantity added!',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF22C55E),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.all(16),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: const Text(
                                'Add to Cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 18),
    ),
  );
}

// ── Color helper ───────────────────────────────────────────────────────────────

Color _colorFromName(String name) {
  switch (name.toLowerCase().replaceAll(' ', '')) {
    case 'beige':
      return const Color(0xFFF5F0E8);
    case 'fogblue':
    case 'blue':
      return const Color(0xFF9BB7D4);
    case 'black':
      return const Color(0xFF1A1A1A);
    case 'white':
      return const Color(0xFFF5F5F5);
    case 'red':
      return const Color(0xFFE53935);
    case 'green':
      return const Color(0xFF43A047);
    case 'brown':
      return const Color(0xFF795548);
    case 'pink':
      return const Color(0xFFF48FB1);
    case 'gray':
    case 'grey':
      return const Color(0xFF9E9E9E);
    case 'navy':
      return const Color(0xFF1A237E);
    case 'yellow':
      return const Color(0xFFFDD835);
    case 'orange':
      return const Color(0xFFFF7043);
    default:
      return const Color(0xFFBDBDBD);
  }
}
