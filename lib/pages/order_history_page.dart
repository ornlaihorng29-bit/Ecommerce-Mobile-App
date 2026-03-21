// lib/pages/order_history_page.dart

import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final _orderService = OrderService();
  final _scrollController = ScrollController();

  static const _bg      = Color(0xFF0A0A14);
  static const _surface = Color(0xFF13131F);
  static const _border  = Color(0xFF1E1E2E);
  static const _accent  = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);

  List<Order> _orders = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _currentPage < _lastPage) {
        _loadMore();
      }
    }
  }

  Future<void> _loadOrders({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _orders = [];
        _error = null;
      });
    }
    setState(() => _isLoading = true);
    try {
      final result = await _orderService.historys(page: 1);
      setState(() {
        _orders = result.data;
        _currentPage = result.meta.currentPage;
        _lastPage = result.meta.lastPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    try {
      final result = await _orderService.historys(page: _currentPage + 1);
      setState(() {
        _orders.addAll(result.data);
        _currentPage = result.meta.currentPage;
        _lastPage = result.meta.lastPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44, height: 44,
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
          const Text('My Orders',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoading();
    if (_error != null) return _buildError(_error!);
    if (_orders.isEmpty) return _buildEmpty();
    return _buildList();
  }

  Widget _buildList() {
    return RefreshIndicator(
      color: _accent,
      backgroundColor: _surface,
      onRefresh: () => _loadOrders(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        itemCount: _orders.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _orders.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _accent)),
            );
          }
          return _buildOrderCard(_orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _statusColor(order.status);
    final paymentColor = _paymentColor(order.paymentStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: order code + date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: _accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.receipt_long_outlined,
                      color: _accent, size: 18),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('#${order.orderCode}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(_formatDate(order.createdAt),
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11)),
                ]),
              ]),
              // Order status badge
              _badge(order.status, statusColor),
            ],
          ),

          const SizedBox(height: 14),
          Divider(color: _border, height: 1),
          const SizedBox(height: 14),

          // Details row
          Row(children: [
            Expanded(child: _detailItem('Payment', order.paymentMethod)),
            Expanded(child: _detailItem('Payment Status',
                order.paymentStatus, valueColor: paymentColor)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _detailItem('Promo Code',
                order.promotionCode.isEmpty ? '—' : order.promotionCode)),
            Expanded(child: _detailItem('Total',
                '\$${order.totalAmount.toStringAsFixed(2)}',
                valueColor: _accent2)),
          ]),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value, {Color? valueColor}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
    ]);
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

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: List.generate(5, (_) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        height: 160,
        decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border)),
      )),
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
            onTap: () => _loadOrders(refresh: true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_accent, _accent2]),
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
        Icon(Icons.shopping_bag_outlined,
            color: Colors.white.withOpacity(0.15), size: 72),
        const SizedBox(height: 16),
        Text('No orders yet',
            style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Your order history will appear here',
            style: TextStyle(
                color: Colors.white.withOpacity(0.25), fontSize: 13)),
      ]),
    );
  }

  Widget _blob(double size, Color color, double opacity) => Container(
      width: size, height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [color.withOpacity(opacity), Colors.transparent])));

  String _formatDate(DateTime dt) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}