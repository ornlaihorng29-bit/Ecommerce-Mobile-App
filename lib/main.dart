// lib/main.dart

import 'dart:async';
import 'dart:convert';
import 'package:ecommerce_mobile_app/pages/check_out_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'provider/cart_provider.dart';
import 'services/storage_service.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/order_success_page.dart';

const String baseUrl = 'http://192.168.1.176:3000'; // ← change to your server

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey =
  'pk_test_51TCwjJEx8106PSkose50zqqdzIpzO7Z4xSBlyWrj2BJGHJPW9E94gEwuqcSru0eJ9MgesvN52ixuuKNUdIQ9b4y800N7asfkaW';
  await Stripe.instance.applySettings();

  final cartProvider = CartProvider();
  await cartProvider.loadCart();

  // ✅ Start background token refresh
  TokenRefreshService.instance.start();

  runApp(
    ChangeNotifierProvider.value(value: cartProvider, child: const MyApp()),
  );
}

// ─────────────────────────────────────────────
// ✅ Background Token Refresh Service
// ─────────────────────────────────────────────
class TokenRefreshService {
  TokenRefreshService._();
  static final TokenRefreshService instance = TokenRefreshService._();

  Timer? _timer;

  // Check every 5 minutes in background
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) async {
      await _tryRefresh();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<bool> _tryRefresh() async {
    final isExpired = await StorageService.isAccessTokenExpired();
    if (!isExpired) return true; // token still valid, skip

    final refreshToken = await StorageService.getRefreshToken();
    if (refreshToken == null) {
      stop(); // no refresh token — force re-login
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auths/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'];

        // ✅ Save new tokens using StorageService
        await StorageService.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          accessTokenExpiresAt: data['accessTokenExpiresAt'],
        );

        debugPrint('✅ Token refreshed in background');
        return true;
      } else {
        debugPrint('❌ Token refresh failed: ${response.body}');
        await StorageService.clearAll(); // force re-login
        stop();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Token refresh error: $e');
      return false;
    }
  }

  // ✅ Call this before every API request
  Future<String?> getValidAccessToken() async {
    final isExpired = await StorageService.isAccessTokenExpired();
    if (isExpired) {
      final success = await _tryRefresh();
      if (!success) return null;
    }
    return StorageService.getToken();
  }
}

// ─────────────────────────────────────────────
// App
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
// AuthGate
// ─────────────────────────────────────────────
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
    // ✅ Automatically refreshes if expired
    final token = await TokenRefreshService.instance.getValidAccessToken();

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
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      ),
    );
  }
}