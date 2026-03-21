// lib/pages/order_success_page.dart

import 'package:flutter/material.dart';
import 'home_page.dart';

class OrderSuccessPage extends StatefulWidget {
  const OrderSuccessPage({super.key});

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage>
    with SingleTickerProviderStateMixin {
  static const _bg      = Color(0xFF0A0A14);
  static const _surface = Color(0xFF13131F);
  static const _border  = Color(0xFF1E1E2E);
  static const _accent  = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);

  late AnimationController _ctrl;
  late Animation<double>   _scaleBounce;
  late Animation<double>   _fadeSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleBounce = CurvedAnimation(
        parent: _ctrl, curve: Curves.elasticOut);
    _fadeSlide = CurvedAnimation(
        parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── Background blobs ───────────────────────────────────────
          Positioned(top: -80, right: -80,
              child: _blob(260, _accent, 0.12)),
          Positioned(bottom: -100, left: -80,
              child: _blob(300, _accent2, 0.07)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── Bouncing check circle ──────────────────────────
                  ScaleTransition(
                    scale: _scaleBounce,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring
                        Container(
                          width: 140, height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF22C55E).withOpacity(0.2),
                                width: 12),
                          ),
                        ),
                        // Inner circle
                        Container(
                          width: 110, height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [BoxShadow(
                              color: const Color(0xFF22C55E).withOpacity(0.45),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            )],
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 54),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Title + subtitle ───────────────────────────────
                  FadeTransition(
                    opacity: _fadeSlide,
                    child: Column(children: [
                      const Text('Order Placed!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5)),
                      const SizedBox(height: 10),
                      Text(
                        'Your order has been received\nand is being processed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 15,
                            height: 1.6),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 36),

                  // ── Info card ──────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeSlide,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _border),
                      ),
                      child: Column(children: [
                        _infoRow(
                          icon: Icons.local_shipping_outlined,
                          label: 'Estimated Delivery',
                          value: '3 – 5 business days',
                        ),
                        _divider(),
                        _infoRow(
                          icon: Icons.receipt_long_outlined,
                          label: 'Order Status',
                          value: 'Processing',
                          valueColor: const Color(0xFFFFC107),
                        ),
                        _divider(),
                        _infoRow(
                          icon: Icons.support_agent_outlined,
                          label: 'Need help?',
                          value: 'Contact support',
                        ),
                      ]),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── Buttons ────────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeSlide,
                    child: Column(children: [

                      // Primary — Back to Home
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
                                blurRadius: 16,
                                offset: const Offset(0, 6))],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomePage()),
                              (_) => false,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.home_rounded,
                                color: Colors.white, size: 20),
                            label: const Text('Back to Home',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Secondary — Continue Shopping
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HomePage()),
                            (_) => false,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: _accent.withOpacity(0.4),
                                width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: Icon(Icons.shopping_bag_outlined,
                              color: _accent.withOpacity(0.8), size: 20),
                          label: Text('Continue Shopping',
                              style: TextStyle(
                                  color: _accent.withOpacity(0.8),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: _accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _accent.withOpacity(0.2)),
        ),
        child: Icon(icon, color: _accent, size: 18),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ]);
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Divider(color: _border, height: 1),
      );

  Widget _blob(double size, Color color, double opacity) => Container(
      width: size, height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [color.withOpacity(opacity), Colors.transparent])));
}