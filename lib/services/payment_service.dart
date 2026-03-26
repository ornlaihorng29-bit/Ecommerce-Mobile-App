import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'api_service.dart';

class PaymentService {
  /// Create a PaymentIntent on your backend
  Future<String> _createPaymentIntent(double totalAmount) async {
    final data = await ApiService.post('/create-payment-intent', {
      'amount': (totalAmount * 100).toInt(), // convert dollars to cents
      'currency': 'usd',
    });
    if (data['clientSecret'] == null) {
      throw Exception('Failed to get client secret from backend');
    }
    return data['clientSecret'] as String;
  }

  /// Process payment via Stripe PaymentSheet
  Future<void> processPayment(double totalPrice) async {
    // Step 1 — create PaymentIntent (async, off main thread)
    final clientSecret = await _createPaymentIntent(totalPrice);

    // Step 2 — initialize PaymentSheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Your App',
        style: ThemeMode.dark,
        allowsDelayedPaymentMethods: true,
      ),
    );

    // Step 3 — yield to UI thread before presenting
    await Future.delayed(Duration(milliseconds: 50));

    // Step 4 — present PaymentSheet
    await Stripe.instance.presentPaymentSheet();
  }
}