// lib/main.dart

import 'package:ecommerce_mobile_app/pages/check_out_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'provider/cart_provider.dart';
import 'services/storage_service.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/order_success_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = 'pk_test_51TCzAbJXJG4s4IjxS7xMF9uGi7571yOqlN9Q6oJsk4kZbzsC9yb4yJIu1VXPSuBytOsjS3FjA8XxRhRtB7XuP3zw00VOM5eYWA';
  await Stripe.instance.applySettings();

  final cartProvider = CartProvider();
  await cartProvider.loadCart();

  runApp(
    ChangeNotifierProvider.value(value: cartProvider, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecommerce App',
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (_) => const HomePage(),
        '/checkout': (_) => const CheckoutPage(),
        '/order-success': (_) => const OrderSuccessPage(),
      },
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await StorageService.getToken();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => token != null ? const HomePage() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A14),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
    );
  }
}
