import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../models/menu_item_model.dart';
import '../utils/colors.dart';
import '../utils/routes.dart';

class ItemDetailScreen extends StatefulWidget {
  final MenuItemModel item;
  const ItemDetailScreen({super.key, required this.item});
  @override State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  String? _selectedSize;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    if (widget.item.isMultiSize) _selectedSize = widget.item.sizes!.keys.first;
  }

  double get _unitPrice {
    if (_selectedSize != null) return widget.item.sizes![_selectedSize!] ?? widget.item.price;
    return widget.item.price;
  }

  void _showCustomizeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 20, left: 24, right: 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Customize', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),

            // Size selector (pizza only)
            if (widget.item.isMultiSize) ...[
              const Align(alignment: Alignment.centerLeft,
                child: Text('Select Size', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: widget.item.sizes!.entries.map((e) {
                final sel = _selectedSize == e.key;
                return GestureDetector(
                  onTap: () { setModal(() => setState(() => _selectedSize = e.key)); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.accent : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? AppColors.accent : AppColors.divider, width: 1.5),
                    ),
                    child: Column(children: [
                      Text(e.key, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppColors.textPrimary)),
                      Text('Rs. ${e.value.toInt()}', style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                          color: sel ? Colors.white70 : AppColors.textSecondary)),
                    ]),
                  ),
                );
              }).toList()),
              const SizedBox(height: 20),
            ],

            // Quantity
            const Align(alignment: Alignment.centerLeft,
              child: Text('Quantity', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _qtyBtn(Icons.remove, () { if (_qty > 1) setModal(() => setState(() => _qty--)); }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('$_qty', style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
              _qtyBtn(Icons.add, () => setModal(() => setState(() => _qty++))),
            ]),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  final cart = Get.find<CartController>();
                  for (int i = 0; i < _qty; i++) {
                    cart.addItem(widget.item, size: _selectedSize);
                  }
                  Get.back();
                  Get.back();
                },
                child: Text('Add to Cart • Rs. ${(_unitPrice * _qty).toInt()}',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final cart = Get.find<CartController>();
    final hasImage = item.imageAsset.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(item.name,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
          child: const BackButton(color: AppColors.textPrimary),
        ),
        actions: [
          if (item.isSpicy)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange.shade700, borderRadius: BorderRadius.circular(8)),
              child: const Text('🌶 Spicy', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Column(children: [
        Expanded(child: SingleChildScrollView(child: Column(children: [
          // Food image area
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Container(
                width: 280, height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFE5E5),
                  boxShadow: [BoxShadow(color: Color(0x26E31837), blurRadius: 40, spreadRadius: 10)],
                ),
                child: ClipOval(
                  child: hasImage
                    ? Image.asset(item.imageAsset, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(item.categoryEmoji, style: const TextStyle(fontSize: 100))))
                    : Center(child: Text(item.categoryEmoji, style: const TextStyle(fontSize: 100))),
                ),
              ),
            ),
          ),

          // Info card
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8F0),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(children: [
              // Item name
              Text(item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text(item.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
              const SizedBox(height: 20),

              // Price
              Text('Rs. ${(_unitPrice * _qty).toInt()}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),

              const SizedBox(height: 8),

              // Featured badge
              if (item.isFeatured)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                  child: const Text('⭐ Popular Choice', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
                ),
            ]),
          ),
        ]))),

        // Bottom buttons
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Add to Cart
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                label: Text('Add to Cart  •  Rs. ${(_unitPrice * _qty).toInt()}',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700)),
                onPressed: () {
                  cart.addItem(item, size: _selectedSize);
                  Get.back();
                },
              ),
            ),
            const SizedBox(height: 12),
            // Customize
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.tune_rounded, size: 20),
                label: const Text('Customize',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700)),
                onPressed: _showCustomizeSheet,
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}
