import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';

class OrderController extends GetxController {
  static OrderController get to => Get.find();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  final RxList<OrderModel> orders    = <OrderModel>[].obs;
  final RxBool isLoading             = false.obs;
  final RxBool isPlacing             = false.obs;
  final RxString selectedPayment     = AppConstants.payCOD.obs;
  final RxString deliveryAddress     = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    if (auth.user.value != null && !auth.isGuest) {
      deliveryAddress.value = auth.user.value?.address ?? '';
      _listenOrders(auth.user.value!.uid);
    }
    ever(auth.user, (u) {
      if (u != null && !u.isGuest) {
        deliveryAddress.value = u.address;
        _listenOrders(u.uid);
      }
    });
  }

  void _listenOrders(String uid) {
    _db.collection(AppConstants.colOrders)
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      orders.value = snap.docs
          .map((d) => OrderModel.fromMap(d.data()))
          .toList();
    });
  }

  Future<void> placeOrder(List<CartItemModel> cartItems, CartController cart) async {
    final auth = Get.find<AuthController>();

    if (deliveryAddress.value.trim().isEmpty) {
      Get.snackbar('Address Required', 'Please enter your delivery address',
          backgroundColor: Colors.orange, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
      return;
    }

    isPlacing.value = true;
    try {
      final user = auth.user.value;
      final id = const Uuid().v4();
      final order = OrderModel(
        id: id,
        userId: user?.uid ?? 'guest_${id.substring(0, 8)}',
        customerPhone: user?.phone ?? '',
        customerName: user == null || user.name.isEmpty ? 'Guest Customer' : user.name,
        deliveryAddress: deliveryAddress.value.trim(),
        paymentMethod: selectedPayment.value,
        status: AppConstants.statusPlaced,
        items: cartItems.map((ci) => OrderItemSnapshot(
          name: ci.item.name,
          category: ci.item.category,
          selectedSize: ci.selectedSize,
          quantity: ci.quantity,
          unitPrice: ci.unitPrice,
          totalPrice: ci.totalPrice,
        )).toList(),
        subtotal: cart.subtotal,
        deliveryFee: cart.deliveryFee,
        discount: cart.discount,
        total: cart.total,
        createdAt: DateTime.now(),
      );

      await _db.collection(AppConstants.colOrders).doc(id).set(order.toMap());
      cart.clear();
      Get.offAllNamed(AppRoutes.orderConfirm, arguments: order);
    } catch (e) {
      debugPrint('🔴 Order error: $e');
      Get.snackbar('Error', 'Could not place order. Try again.',
          backgroundColor: Colors.red, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
    } finally {
      isPlacing.value = false;
    }
  }
}
