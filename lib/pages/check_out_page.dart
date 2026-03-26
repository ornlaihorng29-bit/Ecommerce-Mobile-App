// lib/pages/checkout_page.dart

import 'package:ecommerce_mobile_app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';
import '../services/payment_service.dart';
import '../services/order_service.dart';
import '../pages/order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const _bg      = Color(0xFF0A0A14);
  static const _surface = Color(0xFF13131F);
  static const _border  = Color(0xFF1E1E2E);
  static const _accent  = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);

  String _paymentMethod = 'cash';
  final _promoController = TextEditingController();
  bool _isLoading = false;

  final _paymentOptions = [
    {
      'value': 'cash',
      'label': 'Cash on Delivery',
      'icon': Icons.payments_outlined,
    },
    {
      'value': 'card',
      'label': 'Credit / Debit Card',
      'icon': Icons.credit_card_rounded,
    },
  ];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  // ── Place order logic ────────────────────────────────────────────────────

  Future<void> _placeOrder(BuildContext context, CartProvider cart) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      if (_paymentMethod == 'card') {
        // yield to UI thread
        await Future.microtask(() {});

        // process Stripe payment (async)
        await PaymentService().processPayment(cart.totalPrice);
      }

      // Send order to backend
      final request = OrderRequest(
        paymentMethod: _paymentMethod,
        promotionCode: _promoController.text.trim(),
        orderItems: cart.items
            .map((i) => OrderItem(productId: i.productId, quantity: i.quantity))
            .toList(),
      );

      await OrderService().placeOrder(request);

      await cart.clearCart();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrderSuccessPage()),
            (route) => route.isFirst,
      );
    } on StripeException catch (e) {
      debugPrint('StripeException caught: ${e.error.code} - ${e.error.message}');
      debugPrint('StripeException details: ${e.toString()}');

      if (e.error.code == FailureCode.Canceled) return;

      if (!mounted) return;
      _showError(
        context,
        e.error.localizedMessage ?? 'Payment failed. Please try again.',
      );
    } catch (e) {
      if (!mounted) return;
      _showError(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(msg,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ]),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(top: -80, right: -80, child: _blob(260, _accent, 0.12)),
          Positioned(
              bottom: -100, left: -80, child: _blob(300, _accent2, 0.07)),
          SafeArea(
            child: Consumer<CartProvider>(
              builder: (context, cart, _) {
                return Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                        const EdgeInsets.fromLTRB(20, 20, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOrderSummary(cart),
                            const SizedBox(height: 24),
                            _buildPaymentMethods(),
                            const SizedBox(height: 24),
                            _buildPromoCode(),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomBar(context, cart),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        const Expanded(
          child: Text('Checkout',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  // ── Order summary ────────────────────────────────────────────────────────

  Widget _buildOrderSummary(CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Order Summary'),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              // Items list
              ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        if (item.selectedColor != null) ...[
                          const SizedBox(height: 2),
                          Text(item.selectedColor!,
                              style: TextStyle(
                                  color:
                                  Colors.white.withOpacity(0.35),
                                  fontSize: 11)),
                        ],
                      ],
                    ),
                  ),
                  Text('× ${item.quantity}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12)),
                  const SizedBox(width: 12),
                  Text(
                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ]),
              )),

              // Totals
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Divider(color: _border, height: 1),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(children: [
                  _totalRow('Subtotal',
                      '\$${cart.totalPrice.toStringAsFixed(2)}', false),
                  const SizedBox(height: 6),
                  _totalRow('Shipping', 'Free', false,
                      valueColor: const Color(0xFF22C55E)),
                  const SizedBox(height: 10),
                  _totalRow('Total',
                      '\$${cart.totalPrice.toStringAsFixed(2)}', true),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Payment methods ──────────────────────────────────────────────────────

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Payment Method'),
        const SizedBox(height: 14),
        ..._paymentOptions.map((option) {
          final selected = _paymentMethod == option['value'];
          return GestureDetector(
            onTap: () =>
                setState(() => _paymentMethod = option['value'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: selected ? _accent.withOpacity(0.1) : _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? _accent.withOpacity(0.5) : _border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                        colors: [_accent, _accent2])
                        : null,
                    color: selected ? null : _border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(option['icon'] as IconData,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option['label'] as String,
                          style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400)),
                      if (selected && option['value'] == 'card') ...[
                        const SizedBox(height: 4),
                        Text(
                            'Powered by Stripe — Visa, Mastercard accepted',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 11)),
                      ],
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: selected ? _accent : _border, width: 2),
                    color: selected ? _accent : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 12)
                      : null,
                ),
              ]),
            ),
          );
        }),
      ],
    );
  }

  // ── Promo code ───────────────────────────────────────────────────────────

  Widget _buildPromoCode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Promo Code'),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _promoController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter promo code (optional)',
                hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.25), fontSize: 14),
                filled: true,
                fillColor: _surface,
                prefixIcon: Icon(Icons.local_offer_outlined,
                    color: Colors.white.withOpacity(0.3), size: 18),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _accent)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 50,
            decoration: BoxDecoration(
              gradient:
              const LinearGradient(colors: [_accent, _accent2]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding:
                const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text('Apply',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ],
    );
  }

  // ── Bottom bar ───────────────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: _border)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, -6))
        ],
      ),
      child: Row(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 11)),
            Text('\$${cart.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5)),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_accent, Color(0xFF9B5CF6)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: _accent.withOpacity(0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 6))
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () => _placeOrder(context, cart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: _isLoading
                    ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.bolt_rounded,
                    color: Colors.white, size: 20),
                label: Text(
                  _isLoading ? 'Processing...' : 'Place Order',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionTitle(String text) => Text(text,
      style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white.withOpacity(0.65)));

  Widget _totalRow(String label, String value, bool isBold,
      {Color? valueColor}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: isBold
                      ? Colors.white
                      : Colors.white.withOpacity(0.45),
                  fontSize: isBold ? 14 : 13,
                  fontWeight:
                  isBold ? FontWeight.w700 : FontWeight.w400)),
          Text(value,
              style: TextStyle(
                  color: valueColor ??
                      (isBold
                          ? Colors.white
                          : Colors.white.withOpacity(0.6)),
                  fontSize: isBold ? 16 : 13,
                  fontWeight:
                  isBold ? FontWeight.w800 : FontWeight.w500)),
        ],
      );

  Widget _blob(double size, Color color, double opacity) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [color.withOpacity(opacity), Colors.transparent])));
}