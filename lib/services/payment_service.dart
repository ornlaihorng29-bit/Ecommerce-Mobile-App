// lib/services/payment_service.dart

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'api_service.dart';

class PaymentService {
  Future<String> _createPaymentIntent(double totalAmount) async {
    final amountInCents = (totalAmount * 100).toInt();

    final data = await ApiService.post('/create-payment-intent', {
      'amount': amountInCents,
      'currency': 'usd',
    });

    return data['clientSecret'];
  }

  Future<void> processPayment(double totalAmount) async {
    final clientSecret = await _createPaymentIntent(totalAmount);

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Your Shop',
        style: ThemeMode.dark,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }
}