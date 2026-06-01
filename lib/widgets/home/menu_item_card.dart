import 'package:flutter/material.dart';
import '../../models/menu_item_model.dart';
import '../../utils/colors.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback onTap;
  final VoidCallback? onAdd;

  const MenuItemCard({super.key, required this.item, required this.onTap, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
              child: SizedBox(
                height: 110, width: double.infinity,
                child: item.imageAsset.isNotEmpty
                  ? Image.asset(item.imageAsset, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.cardBg,
                        child: Center(child: Text(item.categoryEmoji, style: const TextStyle(fontSize: 36)))))
                  : Container(color: AppColors.cardBg,
                      child: Center(child: Text(item.categoryEmoji, style: const TextStyle(fontSize: 36)))),
              ),
            ),
            if (item.isFeatured) Positioned(top: 6, left: 6,
              child: _badge('⭐ Popular', AppColors.accent)),
            if (item.isSpicy) Positioned(top: 6, right: 6,
              child: _badge('🌶 Spicy', Colors.orange.shade700)),
          ]),
          // Info
          Expanded(child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily:'Poppins', fontSize:11, fontWeight:FontWeight.w600, color:AppColors.textPrimary)),
                if (item.description.isNotEmpty)
                  Text(item.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily:'Poppins', fontSize:9, color:AppColors.textSecondary)),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (item.isMultiSize) const Text('From', style: TextStyle(fontFamily:'Poppins', fontSize:8, color:AppColors.textSecondary)),
                  Text('Rs. ${item.displayPrice.toInt()}',
                    style: const TextStyle(fontFamily:'Poppins', fontSize:12, fontWeight:FontWeight.w700, color:AppColors.accent)),
                ]),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 26, height: 26,
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _badge(String text, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w700)),
  );
}

// Horizontal deal card
class DealCard extends StatelessWidget {
  final MenuItemModel deal;
  final VoidCallback onTap;
  final VoidCallback? onOrder;

  const DealCard({super.key, required this.deal, required this.onTap, this.onOrder});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
            child: deal.imageAsset.isNotEmpty
              ? Image.asset(deal.imageAsset, width: 110, height: 130, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 110, height: 130, color: AppColors.cardBg,
                    child: const Center(child: Text('🔥', style: TextStyle(fontSize: 40)))))
              : Container(width: 110, height: 130, color: AppColors.cardBg,
                  child: const Center(child: Text('🔥', style: TextStyle(fontSize: 40)))),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (deal.isFeatured)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                    child: const Text('⭐ POPULAR', style: TextStyle(fontFamily:'Poppins', fontSize:8, fontWeight:FontWeight.w700, color:AppColors.textOnPrimary)),
                  ),
                const SizedBox(height: 4),
                Text(deal.name, style: const TextStyle(fontFamily:'Poppins', fontSize:14, fontWeight:FontWeight.w700, color:AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(deal.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily:'Poppins', fontSize:10, color:AppColors.textSecondary)),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Rs. ${deal.price.toInt()}',
                  style: const TextStyle(fontFamily:'Poppins', fontSize:16, fontWeight:FontWeight.w700, color:AppColors.accent)),
                if (onOrder != null)
                  ElevatedButton(
                    onPressed: onOrder,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(70, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Order', style: TextStyle(fontSize: 12)),
                  ),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }
}
