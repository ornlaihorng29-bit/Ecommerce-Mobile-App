// lib/providers/cart_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  static const String _cartKey = 'cart_items';

  // ── Getters ────────────────────────────────────────────────────────────────

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  bool isInCart(int productId) =>
      _items.any((i) => i.productId == productId);

  int getQuantity(int productId) {
    final index = _items.indexWhere((i) => i.productId == productId);
    return index != -1 ? _items[index].quantity : 0;
  }

  // ── Load (call on app start) ───────────────────────────────────────────────

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartJson = prefs.getString(_cartKey);
      if (cartJson != null) {
        final List decoded = jsonDecode(cartJson);
        _items = decoded.map((e) => CartItem.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      // If storage is corrupted just start with empty cart
      _items = [];
    }
  }

  // ── Save (called internally after every change) ────────────────────────────

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cartKey,
        jsonEncode(_items.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  // ── Add ────────────────────────────────────────────────────────────────────

  void addToCart(CartItem newItem) {
    // Match by productId AND selectedColor
    // so "Red Nike" and "Blue Nike" are separate cart entries
    final index = _items.indexWhere((i) =>
        i.productId == newItem.productId &&
        i.selectedColor == newItem.selectedColor);

    if (index != -1) {
      // Already exists → add incoming quantity on top
      _items[index].quantity += newItem.quantity;
    } else {
      _items.add(newItem);
    }

    _saveCart();
    notifyListeners();
  }

  // ── Remove ─────────────────────────────────────────────────────────────────

  void removeItem(int productId, {String? selectedColor}) {
    _items.removeWhere((i) =>
        i.productId == productId &&
        (selectedColor == null || i.selectedColor == selectedColor));
    _saveCart();
    notifyListeners();
  }

  // ── Update quantity ────────────────────────────────────────────────────────

  void updateQuantity(int productId, int qty, {String? selectedColor}) {
    final index = _items.indexWhere((i) =>
        i.productId == productId &&
        (selectedColor == null || i.selectedColor == selectedColor));

    if (index != -1) {
      if (qty <= 0) {
        _items.removeAt(index); // auto-remove when qty hits 0
      } else {
        _items[index].quantity = qty;
      }
    }

    _saveCart();
    notifyListeners();
  }

  // ── Clear ──────────────────────────────────────────────────────────────────

  Future<void> clearCart() async {
    _items.clear();
    await _saveCart();
    notifyListeners();
  }
}