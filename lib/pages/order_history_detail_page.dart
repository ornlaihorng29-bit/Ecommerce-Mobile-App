// lib/pages/order_history_detail_page.dart

import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderHistoryDetailPage extends StatefulWidget {
  final int orderId;
  final String orderCode; // optional: for hero display before data loads

  const OrderHistoryDetailPage({
    super.key,
    required this.orderId,
    this.orderCode = '',
  });

  @override
  State<OrderHistoryDetailPage> createState() => _OrderHistoryDetailPageState();
}

class _OrderHistoryDetailPageState extends State<OrderHistoryDetailPage>
    with SingleTickerProviderStateMixin {
  final _orderService = OrderService();

  // ── Palette (matches OrderHistoryPage) ──────────────────────────────────
  static const _bg      = Color(0xFF0A0A14);
  static const _surface = Color(0xFF13131F);
  static const _border  = Color(0xFF1E1E2E);
  static const _accent  = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);

  OrderDetail? _order;
  bool _isLoading = true;
  String? _error;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 520));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadDetail();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _orderService.historyDetails(widget.orderId);
      setState(() {
        _order = result.data;
        _isLoading = false;
      });
      _animCtrl.forward(from: 0);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(top: -80, right: -80, child: _blob(260, _accent, 0.12)),
          Positioned(bottom: -100, left: -80, child: _blob(300, _accent2, 0.08)),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final code = _order?.orderCode ?? widget.orderCode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white.withOpacity(0.7), size: 17),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Order Detail',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
                if (code.isNotEmpty)
                  Text('#$code',
                      style: TextStyle(
                          color: _accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Body dispatcher ──────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_isLoading) return _buildLoading();
    if (_error != null) return _buildError(_error!);
    if (_order == null) return _buildEmpty();
    return FadeTransition(opacity: _fadeAnim, child: _buildDetail(_order!));
  }

  // ── Main detail scroll view ───────────────────────────────────────────────

  Widget _buildDetail(OrderDetail order) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: [
        // ── Order Summary Card ──
        _buildSummaryCard(order),
        const SizedBox(height: 20),

        // ── Section title ──
        _sectionTitle('Items Ordered', Icons.shopping_bag_outlined),
        const SizedBox(height: 12),

        // ── Product list ──
        ...order.orderItem.map((item) => _buildProductCard(item)),
      ],
    );
  }

  // ── Summary Card ─────────────────────────────────────────────────────────

  Widget _buildSummaryCard(OrderDetail order) {
    final statusColor  = _statusColor(order.status);
    final paymentColor = _paymentColor(order.paymentStatus);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: icon + code + status badge
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: _accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child:
                Icon(Icons.receipt_long_outlined, color: _accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${order.orderCode}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(_formatDate(order.createdAt),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 11)),
                  ],
                ),
              ),
              _badge(order.status, statusColor),
            ],
          ),

          const SizedBox(height: 18),
          Divider(color: _border, height: 1),
          const SizedBox(height: 18),

          // Grid of meta fields
          Row(children: [
            Expanded(
                child: _metaItem('Payment Method', order.paymentMethod,
                    icon: Icons.credit_card_rounded)),
            Expanded(
                child: _metaItem('Payment Status', order.paymentStatus,
                    icon: Icons.verified_outlined, valueColor: paymentColor)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: _metaItem('Promo Code',
                    order.promotionCode.isEmpty ? '—' : order.promotionCode,
                    icon: Icons.local_offer_outlined)),
            Expanded(
                child: _metaItem(
                    'Total Amount', '\$${order.totalAmount.toStringAsFixed(2)}',
                    icon: Icons.attach_money_rounded, valueColor: _accent2)),
          ]),

          const SizedBox(height: 18),
          Divider(color: _border, height: 1),
          const SizedBox(height: 14),

          // Item count summary row
          Row(
            children: [
              Icon(Icons.inventory_2_outlined,
                  color: Colors.white.withOpacity(0.3), size: 14),
              const SizedBox(width: 6),
              Text(
                '${order.orderItem.length} item${order.orderItem.length != 1 ? 's' : ''} in this order',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Product Card ─────────────────────────────────────────────────────────

  Widget _buildProductCard(OrderItemDetail item) {
    final product = item.product;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.image,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.image_not_supported_outlined,
                    color: _accent.withOpacity(0.4), size: 26),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + status dot
                Row(
                  children: [
                    Expanded(
                      child: Text(product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.3)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: product.status
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Color chips
                if (product.color.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: product.color
                        .take(4)
                        .map((c) => _colorChip(c))
                        .toList(),
                  ),

                const SizedBox(height: 8),

                // Price row
                Row(
                  children: [
                    // Unit price
                    Text('\$${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 11)),
                    Text(' × ${item.quantity}',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 11)),
                    const Spacer(),
                    // Subtotal
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _accent2.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _accent2.withOpacity(0.2)),
                      ),
                      child: Text(
                        '\$${item.subTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: _accent2,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),

                // Star rating
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    5,
                        (i) => Icon(
                      i < product.rate ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 13,
                      color: i < product.rate
                          ? const Color(0xFFF59E0B)
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Small helpers ─────────────────────────────────────────────────────────

  Widget _metaItem(String label, String value,
      {IconData? icon, Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: Colors.white.withOpacity(0.25)),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3)),
              const SizedBox(height: 3),
              Text(value,
                  style: TextStyle(
                      color: valueColor ?? Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _colorChip(String colorName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _border),
      ),
      child: Text(colorName,
          style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 9,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2)),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 16, color: _accent),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3)),
    ]);
  }

  // ── State screens ─────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: [
        // summary skeleton
        Container(
          height: 220,
          decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _border)),
        ),
        const SizedBox(height: 20),
        // item skeletons
        ...List.generate(
          3,
              (_) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            height: 100,
            decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _border)),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline_rounded,
              color: Colors.redAccent.withOpacity(0.7), size: 52),
          const SizedBox(height: 14),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 14)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _loadDetail,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              decoration: BoxDecoration(
                gradient:
                const LinearGradient(colors: [_accent, _accent2]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('Retry',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.receipt_long_outlined,
            color: Colors.white.withOpacity(0.15), size: 72),
        const SizedBox(height: 16),
        Text('Order not found',
            style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // ── Decorative blob ───────────────────────────────────────────────────────

  Widget _blob(double size, Color color, double opacity) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [color.withOpacity(opacity), Colors.transparent])));

  // ── Colour helpers ────────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'COMPLETED':
      case 'DELIVERED':
        return const Color(0xFF22C55E);
      case 'PENDING':
      case 'PROCESSING':
        return const Color(0xFFF59E0B);
      case 'CANCELLED':
      case 'FAILED':
        return const Color(0xFFEF4444);
      default:
        return Colors.white54;
    }
  }

  Color _paymentColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'SUCCESS':
        return const Color(0xFF22C55E);
      case 'UNPAID':
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'FAILED':
        return const Color(0xFFEF4444);
      default:
        return Colors.white54;
    }
  }

  String _formatDate(DateTime dt) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}