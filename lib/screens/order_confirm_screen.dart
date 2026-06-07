import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order_model.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';

class OrderConfirmScreen extends StatefulWidget {
  const OrderConfirmScreen({super.key});
  @override State<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen> {
  late OrderModel _order;
  bool _locLoading = false;
  String? _locError;

  @override
  void initState() {
    super.initState();
    _order = Get.arguments as OrderModel;
  }

  // ── Location ────────────────────────────────────────────────────────────────

  Future<void> _shareLocation() async {
    setState(() { _locLoading = true; _locError = null; });
    try {
      // Check & request permission
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() { _locError = 'Location permission denied. Enable it in Settings.'; _locLoading = false; });
        return;
      }

      // Get position
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)));

      // Update Firestore with lat/lng
      await FirebaseFirestore.instance
          .collection(AppConstants.colOrders)
          .doc(_order.id)
          .update({'latitude': pos.latitude, 'longitude': pos.longitude});

      // Rebuild order object with location
      setState(() {
        _order = OrderModel(
          id: _order.id, userId: _order.userId,
          customerPhone: _order.customerPhone, customerName: _order.customerName,
          deliveryAddress: _order.deliveryAddress, paymentMethod: _order.paymentMethod,
          status: _order.status, items: _order.items, subtotal: _order.subtotal,
          deliveryFee: _order.deliveryFee, discount: _order.discount, total: _order.total,
          createdAt: _order.createdAt, latitude: pos.latitude, longitude: pos.longitude,
        );
        _locLoading = false;
      });

      // Open WhatsApp with location
      await _openWhatsApp(withLocation: true);
    } catch (e) {
      setState(() { _locError = 'Could not get location. Try again.'; _locLoading = false; });
    }
  }

  Future<void> _openWhatsApp({bool withLocation = false}) async {
    final items = _order.items.map((i) {
      final size = i.selectedSize != null ? ' (${i.selectedSize})' : '';
      return '• ${i.name}$size x${i.quantity} = Rs. ${i.totalPrice.toInt()}';
    }).join('\n');

    final locationLine = withLocation && _order.hasLocation
        ? '\n📍 *Live Location:* ${_order.googleMapsUrl}'
        : '';

    final msg = '''🍔 *New Order - Hunger Point*

Order ID: #${_order.id.substring(0, 8).toUpperCase()}
Customer: ${_order.customerName}
Phone: ${_order.customerPhone}
Address: ${_order.deliveryAddress}$locationLine

*Items:*
$items

Subtotal: Rs. ${_order.subtotal.toInt()}
Delivery: Rs. ${_order.deliveryFee.toInt()}
${_order.discount > 0 ? 'Discount: -Rs. ${_order.discount.toInt()}\n' : ''}*Total: Rs. ${_order.total.toInt()}*
Payment: ${_paymentLabel(_order.paymentMethod)}''';

    final phone = AppConstants.phone2.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://wa.me/92$phone?text=${Uri.encodeComponent(msg)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => Scaffold(
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
              shape: BoxShape.circle, color: AppColors.success,
              boxShadow: [BoxShadow(color: AppColors.success.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)]),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
          ),
          const SizedBox(height: 24),

          const Text('Order Placed!',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Thank you, ${_order.customerName.isEmpty ? 'Customer' : _order.customerName}!',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textSecondary)),

          const SizedBox(height: 20),

          // Order info
          _InfoCard(children: [
            _row('Order ID', '#${_order.id.substring(0, 8).toUpperCase()}'),
            _row('Status', _order.statusLabel),
            _row('Payment', _paymentLabel(_order.paymentMethod)),
            _row('Address', _order.deliveryAddress),
            _row('Placed at', _formatTime(_order.createdAt)),
            if (_order.hasLocation) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => launchUrl(Uri.parse(_order.googleMapsUrl), mode: LaunchMode.externalApplication),
                child: const Row(children: [
                  Icon(Icons.location_on_rounded, color: AppColors.primary, size: 16),
                  SizedBox(width: 4),
                  Text('View on Google Maps',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                      color: AppColors.primary, decoration: TextDecoration.underline)),
                ]),
              ),
            ],
          ]),

          const SizedBox(height: 14),

          // Items
          _InfoCard(children: [
            const Text('Items Ordered',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Divider(height: 16),
            ..._order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(child: Text(
                  item.selectedSize != null ? '${item.name} (${item.selectedSize})' : item.name,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textPrimary))),
                Text('x${item.quantity}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                Text('Rs. ${item.totalPrice.toInt()}',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent)),
              ]),
            )),
            const Divider(height: 16),
            if (_order.deliveryFee > 0) _row('Delivery Fee', 'Rs. ${_order.deliveryFee.toInt()}'),
            if (_order.discount > 0) _row('Discount', '- Rs. ${_order.discount.toInt()}', green: true),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700)),
              Text('Rs. ${_order.total.toInt()}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.accent)),
            ]),
          ]),

          const SizedBox(height: 24),

          // Location error
          if (_locError != null) Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(_locError!, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.error)),
          ),

          // Share Location button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _order.hasLocation ? AppColors.success : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: _locLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(_order.hasLocation ? Icons.location_on_rounded : Icons.my_location_rounded, size: 20),
              label: Text(
                _locLoading ? 'Getting Location...'
                  : _order.hasLocation ? '✅ Location Shared with Rider'
                  : 'Share My Live Location',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700)),
              onPressed: _locLoading || _order.hasLocation ? null : _shareLocation,
            ),
          ),
          const SizedBox(height: 10),

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
              label: const Text('Share Order on WhatsApp',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700)),
              onPressed: () => _openWhatsApp(withLocation: _order.hasLocation),
            ),
          ),
          const SizedBox(height: 10),

          // Track / History
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
              label: const Text('My Orders',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
              onPressed: () => Get.offAllNamed(AppRoutes.orderHistory),
            ),
          ),
          const SizedBox(height: 10),

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

  String _formatTime(DateTime dt) =>
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

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}
