// lib/pages/products_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import '../utils/image_url.dart';
import 'product_detail_page.dart';

class ProductsPage extends StatefulWidget {
  final int? initialCategoryId;
  const ProductsPage({super.key, this.initialCategoryId});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with SingleTickerProviderStateMixin {
  final _productService  = ProductService();
  final _categoryService = CategoryService();

  List<Product>  _products   = [];
  List<Category> _categories = [];
  ProductMeta?   _meta;

  int?   _selectedCategoryId;
  int    _currentPage = 1;
  bool   _loading     = true;
  bool   _loadingMore = false;
  String? _error;

  // ── Search & filter state ──────────────────────────────────────────────────
  final _searchController   = TextEditingController();
  final _priceMinController = TextEditingController();
  final _priceMaxController = TextEditingController();

  String  _searchQuery = '';
  double? _priceMin;
  double? _priceMax;
  bool    _filterPanelOpen = false;

  // debounce timer
  DateTime _lastSearchTime = DateTime.now();

  final ScrollController _scrollController = ScrollController();

  // ── Colors ─────────────────────────────────────────────────────────────────
  static const _bg      = Color(0xFF0A0A14);
  static const _surface = Color(0xFF13131F);
  static const _accent  = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);
  static const _border  = Color(0xFF1E1E2E);
  static const _text    = Colors.white;

  // ── Derived helpers ────────────────────────────────────────────────────────
  bool get _hasActiveFilter =>
      _priceMin != null || _priceMax != null || _selectedCategoryId != null;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _loadCategories();
    _loadProducts(reset: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_loadingMore &&
          _meta != null &&
          _currentPage < _meta!.lastPage) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
  }

  // ── Data loading ───────────────────────────────────────────────────────────
  Future<void> _loadCategories() async {
    try {
      final cats = await _categoryService.getCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  Future<void> _loadProducts({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error   = null;
        _currentPage = 1;
        _products    = [];
      });
    }
    try {
      final result = await _productService.getProducts(
        page:       _currentPage,
        categoryId: _selectedCategoryId,
        name:       _searchQuery.isEmpty ? null : _searchQuery,
        priceMin:   _priceMin,
        priceMax:   _priceMax,
      );
      if (mounted) {
        setState(() {
          _products = reset
              ? result.data
              : [..._products, ...result.data];
          _meta    = result.meta;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _error   = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() { _loadingMore = true; _currentPage++; });
    try {
      final result = await _productService.getProducts(
        page:       _currentPage,
        categoryId: _selectedCategoryId,
        name:       _searchQuery.isEmpty ? null : _searchQuery,
        priceMin:   _priceMin,
        priceMax:   _priceMax,
      );
      if (mounted) setState(() {
        _products   = [..._products, ...result.data];
        _meta       = result.meta;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  // ── Filter / search handlers ───────────────────────────────────────────────
  void _onCategoryTap(int? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    setState(() => _selectedCategoryId = categoryId);
    _loadProducts(reset: true);
  }

  /// Called on every keystroke — debounced 400 ms.
  void _onSearchChanged(String value) {
    final now = DateTime.now();
    _lastSearchTime = now;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_lastSearchTime == now && mounted) {
        setState(() => _searchQuery = value.trim());
        _loadProducts(reset: true);
      }
    });
  }

  void _applyPriceFilter() {
    final min = double.tryParse(_priceMinController.text.trim());
    final max = double.tryParse(_priceMaxController.text.trim());
    setState(() {
      _priceMin = min;
      _priceMax = max;
      _filterPanelOpen = false;
    });
    _loadProducts(reset: true);
  }

  void _clearAllFilters() {
    _priceMinController.clear();
    _priceMaxController.clear();
    setState(() {
      _priceMin           = null;
      _priceMax           = null;
      _selectedCategoryId = null;
      _filterPanelOpen    = false;
    });
    _loadProducts(reset: true);
  }

  // ── Navigate to detail ─────────────────────────────────────────────────────
  void _openDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(productId: product.id),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(top: -80,    right: -80, child: _blob(260, _accent,  0.18)),
          Positioned(bottom: -100, left: -80, child: _blob(300, _accent2, 0.12)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 14),
                _buildSearchBar(),
                const SizedBox(height: 10),
                // ── Filter panel (collapsible) ────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOut,
                  child: _filterPanelOpen
                      ? _buildFilterPanel()
                      : const SizedBox.shrink(),
                ),
                // ── Active-filter chips ───────────────────────────────────
                if (_hasActiveFilter) ...[
                  const SizedBox(height: 4),
                  _buildActiveFilterChips(),
                ],
                const SizedBox(height: 10),
                if (_categories.isNotEmpty) _buildCategoryFilter(),
                const SizedBox(height: 14),
                Expanded(
                  child: _loading
                      ? _buildLoadingGrid()
                      : _error != null
                          ? _buildError()
                          : _products.isEmpty
                              ? _buildEmpty()
                              : _buildGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(                                           // ✅ wrap in Row
            children: [
              if (Navigator.canPop(context)) ...[        // ✅ back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white.withOpacity(0.7), size: 16),
                  ),
                ),
              ],
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Products',
                    style: TextStyle(
                        color: _text,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6)),
                if (_meta != null)
                  Text('${_meta!.total} items',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4), fontSize: 13)),
              ]),
            ],
          ),
          // Filter toggle button — unchanged
          GestureDetector(
            onTap: () => setState(() => _filterPanelOpen = !_filterPanelOpen),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: _filterPanelOpen || _hasActiveFilter
                    ? const LinearGradient(colors: [_accent, _accent2])
                    : null,
                color: _filterPanelOpen || _hasActiveFilter ? null : _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _filterPanelOpen || _hasActiveFilter
                        ? Colors.transparent
                        : _border),
                boxShadow: _filterPanelOpen || _hasActiveFilter
                    ? [BoxShadow(
                    color: _accent.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4))]
                    : [],
              ),
              child: Stack(alignment: Alignment.center, children: [
                Icon(Icons.tune_rounded,
                    color: Colors.white.withOpacity(
                        _filterPanelOpen || _hasActiveFilter ? 1.0 : 0.7),
                    size: 20),
                if (_hasActiveFilter)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                          color: Color(0xFFFFC107), shape: BoxShape.circle),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded,
              color: Colors.white.withOpacity(0.4), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: _text, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search products…',
                hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3), fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _onSearchChanged('');
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.close_rounded,
                    color: Colors.white.withOpacity(0.4), size: 18),
              ),
            ),
        ]),
      ),
    );
  }

  // ── Collapsible filter panel ───────────────────────────────────────────────
  Widget _buildFilterPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Filter by Price',
            style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: _priceField(
              controller: _priceMinController,
              hint: 'Min \$',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('—',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.3), fontSize: 16)),
          ),
          Expanded(
            child: _priceField(
              controller: _priceMaxController,
              hint: 'Max \$',
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: _applyPriceFilter,
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_accent, _accent2]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(
                      color: _accent.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4))],
                ),
                child: const Center(
                  child: Text('Apply',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _clearAllFilters,
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('Clear All',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _priceField(
      {required TextEditingController controller, required String hint}) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        style: const TextStyle(color: _text, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  // ── Active filter chips ────────────────────────────────────────────────────
  Widget _buildActiveFilterChips() {
    final chips = <Widget>[];

    if (_priceMin != null && _priceMax != null) {
      chips.add(_activeChip(
          '\$${_priceMin!.toStringAsFixed(0)} – \$${_priceMax!.toStringAsFixed(0)}',
          onRemove: () {
            _priceMinController.clear();
            _priceMaxController.clear();
            setState(() { _priceMin = null; _priceMax = null; });
            _loadProducts(reset: true);
          }));
    } else if (_priceMin != null) {
      chips.add(_activeChip(
          'Min \$${_priceMin!.toStringAsFixed(0)}',
          onRemove: () {
            _priceMinController.clear();
            setState(() => _priceMin = null);
            _loadProducts(reset: true);
          }));
    } else if (_priceMax != null) {
      chips.add(_activeChip(
          'Max \$${_priceMax!.toStringAsFixed(0)}',
          onRemove: () {
            _priceMaxController.clear();
            setState(() => _priceMax = null);
            _loadProducts(reset: true);
          }));
    }

    if (_selectedCategoryId != null) {
      final catName = _categories
          .firstWhere((c) => c.id == _selectedCategoryId,
              orElse: () => Category(id: 0, name: 'Category', image: '', status: true, createdAt: DateTime.now()))
          .name;
      chips.add(_activeChip(catName, onRemove: () {
        setState(() => _selectedCategoryId = null);
        _loadProducts(reset: true);
      }));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: chips),
    );
  }

  Widget _activeChip(String label, {required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF33), Color(0xFF06B6D433)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withOpacity(0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onRemove,
          child: Icon(Icons.close_rounded,
              size: 14, color: Colors.white.withOpacity(0.6)),
        ),
      ]),
    );
  }

  // ── Category filter ────────────────────────────────────────────────────────
  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        _chip(label: 'All',
            selected: _selectedCategoryId == null,
            onTap: () => _onCategoryTap(null)),
        ..._categories.map((c) => _chip(
              label: c.name,
              selected: _selectedCategoryId == c.id,
              onTap: () => _onCategoryTap(c.id),
            )),
      ]),
    );
  }

  Widget _chip(
      {required String label,
      required bool selected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(colors: [_accent, _accent2])
              : null,
          color: selected ? null : _surface,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: selected ? Colors.transparent : _border),
          boxShadow: selected
              ? [BoxShadow(
                  color: _accent.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4))]
              : [],
        ),
        child: Text(label,
            style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ),
    );
  }

  // ── Grid ───────────────────────────────────────────────────────────────────
  Widget _buildGrid() {
    return RefreshIndicator(
      color: _accent,
      backgroundColor: _surface,
      onRefresh: () => _loadProducts(reset: true),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: _products.length + (_loadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= _products.length) return _shimmerCard();
          return _ProductCard(
            product: _products[index],
            onTap: () => _openDetail(_products[index]),
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => _shimmerCard(),
    );
  }

  Widget _shimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _border,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                height: 11,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 7),
            Container(
                height: 11,
                width: 70,
                decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(6))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline_rounded,
              color: Colors.redAccent.withOpacity(0.8), size: 52),
          const SizedBox(height: 14),
          Text(_error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 14)),
          const SizedBox(height: 20),
          _gradientButton('Retry', () => _loadProducts(reset: true)),
        ]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.search_off_rounded,
            color: Colors.white.withOpacity(0.2), size: 56),
        const SizedBox(height: 14),
        Text('No products found.',
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 15)),
        if (_hasActiveFilter || _searchQuery.isNotEmpty) ...[
          const SizedBox(height: 16),
          _gradientButton('Clear filters', _clearAllFilters),
        ],
      ]),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _blob(double size, Color color, double opacity) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [color.withOpacity(opacity), Colors.transparent])));

  Widget _gradientButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
        decoration: BoxDecoration(
          gradient:
              const LinearGradient(colors: [_accent, _accent2]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
              color: _accent.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6))],
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15)),
      ),
    );
  }
}

// ── Product card (unchanged) ───────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  static const _surface = Color(0xFF13131F);
  static const _border  = Color(0xFF1E1E2E);
  static const _accent  = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))],
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18)),
              child: Stack(fit: StackFit.expand, children: [
                CachedNetworkImage(
                  imageUrl: resolveImageUrl(product.image),
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                      color: _border,
                      child: const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _accent))),
                  errorWidget: (_, __, ___) => Container(
                      color: _border,
                      child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: _accent,
                          size: 32)),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),
                ),
                if (product.rate > 0)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFC107), size: 12),
                        const SizedBox(width: 3),
                        Text(product.rate.toStringAsFixed(1),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.3)),
              const SizedBox(height: 6),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _accent)),
                    if (product.color.isNotEmpty)
                      Row(
                          children: product.color
                              .take(3)
                              .map((c) => Container(
                                    width: 9, height: 9,
                                    margin: const EdgeInsets.only(left: 4),
                                    decoration: BoxDecoration(
                                      color: _colorFromName(c),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white24,
                                          width: 0.5),
                                    ),
                                  ))
                              .toList()),
                  ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

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