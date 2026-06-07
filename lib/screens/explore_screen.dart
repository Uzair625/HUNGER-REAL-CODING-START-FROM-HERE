import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/menu_controller.dart';
import '../controllers/cart_controller.dart';
import '../utils/colors.dart';
import '../utils/routes.dart';
import '../widgets/home/menu_item_card.dart';

class ExploreScreen extends StatefulWidget {
  final String? initialCategory;
  const ExploreScreen({super.key, this.initialCategory});
  @override State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    final menu = Get.find<FoodMenuController>();
    if (widget.initialCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        menu.selectCategory(widget.initialCategory!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final menu = Get.find<FoodMenuController>();
    final cart = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Explore Menu'),
        backgroundColor: Colors.white,
        leading: const BackButton(color: AppColors.textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: _SearchBar(menu: menu),
          ),
        ),
      ),
      body: Column(children: [
        // Category chips
        SizedBox(
          height: 46,
          child: Obx(() {
            final currentCat = menu.selectedCategory.value;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: menu.categories.length,
              itemBuilder: (_, i) {
                final cat = menu.categories[i];
                final selected = currentCat == cat;
                return GestureDetector(
                  onTap: () => menu.selectCategory(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppColors.accent : AppColors.divider, width: 1.5),
                      boxShadow: selected ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))] : [],
                    ),
                    child: Text(cat, style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textSecondary)),
                  ),
                );
              },
            );
          }),
        ),

        // Items count + grid
        Expanded(child: Obx(() {
          final items = menu.filtered;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(menu.selectedCategory.value == 'All' ? 'All Items' : menu.selectedCategory.value,
                  style: const TextStyle(fontFamily:'Poppins', fontSize:15, fontWeight:FontWeight.w700, color:AppColors.textPrimary)),
                Text('${items.length} items',
                  style: const TextStyle(fontFamily:'Poppins', fontSize:12, color:AppColors.textSecondary)),
              ]),
            ),
            Expanded(child: items.isEmpty
              ? const _EmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 160,
                    mainAxisExtent: 210,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => MenuItemCard(
                    item: items[i],
                    onTap: () => Get.toNamed(AppRoutes.itemDetail, arguments: items[i]),
                    onAdd: () => cart.addItem(items[i]),
                  ),
                )),
          ]);
        })),
      ]),

      // Floating cart button
      floatingActionButton: Obx(() => cart.count > 0
        ? FloatingActionButton.extended(
            onPressed: () => Get.toNamed(AppRoutes.cart),
            backgroundColor: AppColors.accent,
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            label: Text('Cart (${cart.count}) • Rs. ${cart.total.toInt()}',
              style: const TextStyle(color: Colors.white, fontFamily:'Poppins', fontWeight:FontWeight.w600)),
          )
        : const SizedBox.shrink()),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final FoodMenuController menu;
  const _SearchBar({required this.menu});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: TextField(
      onChanged: menu.search,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search burgers, pizza, deals...',
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textLight),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('😕', style: TextStyle(fontSize: 48)),
      SizedBox(height: 12),
      Text('No items found', style: TextStyle(fontFamily:'Poppins', fontSize:16, fontWeight:FontWeight.w600, color:AppColors.textPrimary)),
      Text('Try a different search or category', style: TextStyle(fontFamily:'Poppins', fontSize:13, color:AppColors.textSecondary)),
    ]),
  );
}
