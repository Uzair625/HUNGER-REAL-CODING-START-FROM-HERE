import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';
import '../models/cart_item_model.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart  = Get.find<CartController>();
    final order = Get.find<OrderController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() => Text('My Cart (${cart.count})',
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))),
        backgroundColor: Colors.white,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: Obx(() {
        if (cart.items.isEmpty) return const _EmptyCart();
        return Column(children: [
          Expanded(child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              ...cart.items.map((ci) => _CartItemTile(
                ci: ci,
                onRemove: () => cart.removeItem(ci.item.id, size: ci.selectedSize),
                onQtyChange: (q) => cart.updateQty(ci.item.id, q, size: ci.selectedSize),
              )),
              const SizedBox(height: 12),
              _OrderSummaryCard(cart: cart),
              const SizedBox(height: 12),
              _AddressCard(order: order),
              const SizedBox(height: 12),
              _PaymentCard(order: order),
              const SizedBox(height: 80),
            ],
          )),
          _PlaceOrderBar(cart: cart, order: order),
        ]);
      }),
    );
  }
}

// ── Cart Item Tile ─────────────────────────────────────────────────────────────

class _CartItemTile extends StatelessWidget {
  final CartItemModel ci;
  final VoidCallback onRemove;
  final void Function(int) onQtyChange;
  const _CartItemTile({required this.ci, required this.onRemove, required this.onQtyChange});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
    child: Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ci.item.imageAsset.isNotEmpty
          ? Image.asset(ci.item.imageAsset, width: 64, height: 64, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _emojiBox(ci.item.categoryEmoji))
          : _emojiBox(ci.item.categoryEmoji),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(ci.displayName,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Text('Rs. ${ci.unitPrice.toInt()} each',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(children: [
          _qBtn(Icons.remove, () { if (ci.quantity > 1) { onQtyChange(ci.quantity - 1); } else { onRemove(); } }),
          SizedBox(width: 32, child: Center(child: Text('${ci.quantity}',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700)))),
          _qBtn(Icons.add, () => onQtyChange(ci.quantity + 1)),
        ]),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        GestureDetector(onTap: onRemove,
          child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20)),
        const SizedBox(height: 12),
        Text('Rs. ${ci.totalPrice.toInt()}',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accent)),
      ]),
    ]),
  );

  Widget _emojiBox(String emoji) => Container(
    width: 64, height: 64, color: AppColors.cardBg,
    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))));

  Widget _qBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 26, height: 26,
      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 14),
    ),
  );
}

// ── Order Summary ──────────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  final CartController cart;
  const _OrderSummaryCard({required this.cart});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Order Summary',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const Divider(height: 20),
      _row('Subtotal', 'Rs. ${cart.subtotal.toInt()}'),
      if (cart.deliveryFee > 0) _row('Delivery Fee', 'Rs. ${cart.deliveryFee.toInt()}'),
      if (cart.discount > 0) _row('Discount (10%)', '- Rs. ${cart.discount.toInt()}', isGreen: true),
      if (cart.subtotal < AppConstants.minDelivery)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('Add Rs. ${(AppConstants.minDelivery - cart.subtotal).toInt()} more for delivery',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.accent))),
      const Divider(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Total',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text('Rs. ${cart.total.toInt()}',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.accent)),
      ]),
    ]),
  );

  Widget _row(String label, String value, {bool isGreen = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary)),
      Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600,
        color: isGreen ? AppColors.success : AppColors.textPrimary)),
    ]),
  );
}

// ── Address Card ───────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final OrderController order;
  const _AddressCard({required this.order});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
        SizedBox(width: 6),
        Text('Delivery Address',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ]),
      const SizedBox(height: 12),
      Obx(() => TextFormField(
        initialValue: order.deliveryAddress.value,
        onChanged: (v) => order.deliveryAddress.value = v,
        maxLines: 2,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Enter your delivery address...',
          hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textLight),
          filled: true, fillColor: AppColors.cardBg,
          contentPadding: const EdgeInsets.all(12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        ),
      )),
    ]),
  );
}

// ── Payment Card ───────────────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final OrderController order;
  const _PaymentCard({required this.order});

  static const List<(String, IconData, String)> _methods = [
    ('Cash on Delivery', Icons.money_outlined,                  AppConstants.payCOD),
    ('Easypaisa',        Icons.phone_android_outlined,           AppConstants.payEasypaisa),
    ('JazzCash',         Icons.account_balance_wallet_outlined,  AppConstants.payJazzCash),
    ('Bank Transfer',    Icons.account_balance_outlined,         AppConstants.payBank),
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Payment Method',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      Obx(() => Column(
        children: _methods.map((m) => GestureDetector(
          onTap: () => order.selectedPayment.value = m.$3,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBg, borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: order.selectedPayment.value == m.$3 ? AppColors.accent : AppColors.divider,
                width: order.selectedPayment.value == m.$3 ? 2 : 1)),
            child: Row(children: [
              Icon(m.$2,
                color: order.selectedPayment.value == m.$3 ? AppColors.accent : AppColors.textSecondary,
                size: 20),
              const SizedBox(width: 12),
              Text(m.$1, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500,
                color: order.selectedPayment.value == m.$3 ? AppColors.textPrimary : AppColors.textSecondary)),
              const Spacer(),
              if (order.selectedPayment.value == m.$3)
                const Icon(Icons.check_circle, color: AppColors.accent, size: 18),
            ]),
          ),
        )).toList(),
      )),
    ]),
  );
}

// ── Place Order Bar ────────────────────────────────────────────────────────────

class _PlaceOrderBar extends StatelessWidget {
  final CartController cart;
  final OrderController order;
  const _PlaceOrderBar({required this.cart, required this.order});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -3))]),
    child: Obx(() => ElevatedButton(
      onPressed: order.isPlacing.value ? null : () => order.placeOrder(cart.items.toList(), cart),
      child: order.isPlacing.value
        ? const SizedBox(width: 22, height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
        : Text('Place Order  •  Rs. ${cart.total.toInt()}',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700)),
    )),
  );
}

// ── Empty Cart ─────────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🛒', style: TextStyle(fontSize: 64)),
      const SizedBox(height: 16),
      const Text('Your cart is empty',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      const Text('Add items from the menu to get started',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(height: 24),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: ElevatedButton(onPressed: Get.back, child: const Text('Browse Menu'))),
    ]),
  );
}
