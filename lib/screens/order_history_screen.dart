import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrderController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Orders',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (ctrl.orders.isEmpty) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('📦', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text('No orders yet',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text('Your order history will appear here',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Start Ordering'))),
            ]),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: ctrl.orders.length,
          itemBuilder: (_, i) => _OrderCard(order: ctrl.orders[i]),
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('#${order.id.substring(0, 8).toUpperCase()}',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        _StatusBadge(status: order.status, label: order.statusLabel),
      ]),
      const SizedBox(height: 4),
      Text(_formatDate(order.createdAt),
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary)),

      const Divider(height: 16),

      // Items
      ...order.items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          Expanded(child: Text(
            item.selectedSize != null ? '${item.name} (${item.selectedSize})' : item.name,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textPrimary))),
          Text('x${item.quantity}  Rs. ${item.totalPrice.toInt()}',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
        ]),
      )),

      const Divider(height: 16),

      // Footer
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(_paymentLabel(order.paymentMethod),
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
        Text('Rs. ${order.total.toInt()}',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accent)),
      ]),
    ]),
  );

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';

  String _paymentLabel(String m) {
    switch (m) {
      case AppConstants.payCOD:       return 'Cash on Delivery';
      case AppConstants.payEasypaisa: return 'Easypaisa';
      case AppConstants.payJazzCash:  return 'JazzCash';
      case AppConstants.payBank:      return 'Bank Transfer';
      default:                        return m;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status, label;
  const _StatusBadge({required this.status, required this.label});

  Color get _color {
    switch (status) {
      case 'placed':     return Colors.orange;
      case 'confirmed':  return Colors.blue;
      case 'preparing':  return Colors.purple;
      case 'on_the_way': return Colors.teal;
      case 'delivered':  return AppColors.success;
      default:           return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20)),
    child: Text(label,
      style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: _color)),
  );
}
