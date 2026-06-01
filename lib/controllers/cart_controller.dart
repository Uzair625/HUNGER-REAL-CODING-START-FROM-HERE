import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/menu_item_model.dart';
import '../models/cart_item_model.dart';
import '../utils/constants.dart';

class CartController extends GetxController {
  static CartController get to => Get.find();

  final RxList<CartItemModel> items = <CartItemModel>[].obs;

  int get count => items.fold(0, (s, i) => s + i.quantity);
  double get subtotal => items.fold(0.0, (s, i) => s + i.totalPrice);
  double get deliveryFee => subtotal >= AppConstants.minDelivery ? AppConstants.deliveryFee : 0;
  double get discount => subtotal >= AppConstants.bulkMinOrder
      ? subtotal * AppConstants.bulkDiscount / 100 : 0;
  double get total => subtotal + deliveryFee - discount;

  bool containsItem(String id) => items.any((i) => i.item.id == id);

  void addItem(MenuItemModel item, {String? size}) {
    final idx = items.indexWhere((i) => i.item.id == item.id && i.selectedSize == size);
    if (idx >= 0) {
      items[idx].quantity++;
      items.refresh();
    } else {
      items.add(CartItemModel(item: item, quantity: 1, selectedSize: size));
    }
    Get.snackbar('Added! 🛒', '${item.name} added to cart',
      backgroundColor: const Color(0xFFFF6B35),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16));
  }

  void removeItem(String id, {String? size}) {
    items.removeWhere((i) => i.item.id == id && i.selectedSize == size);
  }

  void updateQty(String id, int qty, {String? size}) {
    final idx = items.indexWhere((i) => i.item.id == id && i.selectedSize == size);
    if (idx < 0) return;
    if (qty <= 0) { items.removeAt(idx); } else { items[idx].quantity = qty; items.refresh(); }
  }

  void clear() => items.clear();
}
