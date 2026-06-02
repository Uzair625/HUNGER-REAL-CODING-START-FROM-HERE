import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order_model.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';

class OrderConfirmScreen extends StatelessWidget {
  const OrderConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = Get.arguments as OrderModel;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 20),

            // Success icon
            Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
                boxShadow: [BoxShadow(color: AppColors.success.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 24),

            const Text('Order Placed!',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text('Thank you, ${order.customerName.isEmpty ? 'Customer' : order.customerName}!',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textSecondary)),

            const SizedBox(height: 20),

            // Order ID + Status
            _InfoCard(children: [
              _row('Order ID', '#${order.id.substring(0, 8).toUpperCase()}'),
              _row('Status', order.statusLabel),
              _row('Payment', _paymentLabel(order.paymentMethod)),
              _row('Address', order.deliveryAddress),
              _row('Placed at', _formatTime(order.createdAt)),
            ]),

            const SizedBox(height: 14),

            // Items
            _InfoCard(children: [
              const Text('Items Ordered',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Divider(height: 16),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Expanded(child: Text(
                    item.selectedSize != null ? '${item.name} (${item.selectedSize})' : item.name,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textPrimary))),
                  Text('x${item.quantity}',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 12),
                  Text('Rs. ${item.totalPrice.toInt()}',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent)),
                ]),
              )),
              const Divider(height: 16),
              if (order.deliveryFee > 0) _row('Delivery Fee', 'Rs. ${order.deliveryFee.toInt()}'),
              if (order.discount > 0) _row('Discount', '- Rs. ${order.discount.toInt()}', green: true),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700)),
                Text('Rs. ${order.total.toInt()}',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.accent)),
              ]),
            ]),

            const SizedBox(height: 24),

            // WhatsApp button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.chat_rounded, size: 20),
                label: const Text('Share on WhatsApp',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700)),
                onPressed: () => _shareWhatsApp(order),
              ),
            ),
            const SizedBox(height: 12),

            // Track order button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.track_changes_rounded, color: AppColors.primary, size: 20),
                label: const Text('My Orders',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),
                onPressed: () => Get.offAllNamed(AppRoutes.orderHistory),
              ),
            ),
            const SizedBox(height: 12),

            // Back to home
            TextButton(
              onPressed: () => Get.offAllNamed(AppRoutes.home),
              child: const Text('Back to Home',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textSecondary)),
            ),

            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  void _shareWhatsApp(OrderModel order) async {
    final items = order.items.map((i) {
      final size = i.selectedSize != null ? ' (${i.selectedSize})' : '';
      return '• ${i.name}$size x${i.quantity} = Rs. ${i.totalPrice.toInt()}';
    }).join('\n');

    final msg = '''🍔 *New Order - Hunger Point*

Order ID: #${order.id.substring(0, 8).toUpperCase()}
Customer: ${order.customerName}
Phone: ${order.customerPhone}
Address: ${order.deliveryAddress}

*Items:*
$items

Subtotal: Rs. ${order.subtotal.toInt()}
Delivery: Rs. ${order.deliveryFee.toInt()}
${order.discount > 0 ? 'Discount: -Rs. ${order.discount.toInt()}\n' : ''}*Total: Rs. ${order.total.toInt()}*
Payment: ${_paymentLabel(order.paymentMethod)}''';

    final encoded = Uri.encodeComponent(msg);
    final phone = AppConstants.phone2.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://wa.me/92$phone?text=$encoded');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  String _paymentLabel(String method) {
    switch (method) {
      case AppConstants.payCOD:        return 'Cash on Delivery';
      case AppConstants.payEasypaisa:  return 'Easypaisa';
      case AppConstants.payJazzCash:   return 'JazzCash';
      case AppConstants.payBank:       return 'Bank Transfer';
      default:                         return method;
    }
  }

  String _formatTime(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';

  Widget _row(String label, String value, {bool green = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 90, child: Text(label,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary))),
      Expanded(child: Text(value,
        style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600,
          color: green ? AppColors.success : AppColors.textPrimary))),
    ]),
  );
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}
