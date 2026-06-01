import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/menu_controller.dart';
import '../controllers/cart_controller.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';
import '../widgets/common/app_drawer.dart';
import '../widgets/home/menu_item_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menu = Get.find<FoodMenuController>();
    final cart = Get.find<CartController>();
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.background,
        drawer: const AppDrawer(),
        body: SafeArea(child: Column(children: [
          // Top bar
          _TopBar(scaffoldKey: scaffoldKey, cart: cart),
          // Delivery selector
          _DeliveryBar(),
          // Body
          Expanded(child: Obx(() {
            if (menu.isLoading.value) return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            return RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () async => menu.onInit(),
              child: CustomScrollView(slivers: [
                // Promo banner
                SliverToBoxAdapter(child: _PromoBanner()),

                // Explore Menu header
                SliverToBoxAdapter(child: _SectionHeader(title: 'Explore Menu', onViewAll: () => Get.toNamed(AppRoutes.explore))),

                // Category grid — auto columns, max 105px per tile
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 105, mainAxisExtent: 90,
                      crossAxisSpacing: 10, mainAxisSpacing: 10),
                    delegate: SliverChildBuilderDelegate((ctx, i) {
                      if (i >= AppConstants.categories.length) return null;
                      final cat = AppConstants.categories[i];
                      return _CategoryTile(
                        category: cat,
                        count: menu.byCategory(cat).length,
                        onTap: () => Get.toNamed(AppRoutes.explore, arguments: cat),
                      );
                    }, childCount: AppConstants.categories.length),
                  ),
                ),

                // Popular items
                SliverToBoxAdapter(child: _SectionHeader(title: 'Popular Right Now 🔥', onViewAll: () => Get.toNamed(AppRoutes.explore))),

                // Popular items — auto columns, max 160px per card, fixed 210px height
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 160, mainAxisExtent: 210,
                      crossAxisSpacing: 10, mainAxisSpacing: 10),
                    delegate: SliverChildBuilderDelegate((ctx, i) {
                      final popular = menu.allItems
                        .where((it) => it.isFeatured || it.tags.contains('bestseller') || it.tags.contains('popular'))
                        .take(9).toList();
                      if (i >= popular.length) return null;
                      return MenuItemCard(
                        item: popular[i],
                        onTap: () => Get.toNamed(AppRoutes.itemDetail, arguments: popular[i]),
                        onAdd: () => cart.addItem(popular[i]),
                      );
                    }, childCount: 9),
                  ),
                ),
              ]),
            );
          })),
        ])),

        // Bottom Nav — 3 tabs only
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (i) {
            if (i == 1) Get.toNamed(AppRoutes.explore);
            if (i == 2) Get.toNamed(AppRoutes.cart);
          },
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'HOME'),
            const BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search_rounded), label: 'EXPLORE'),
            BottomNavigationBarItem(
              icon: Obx(() => Stack(clipBehavior: Clip.none, children: [
                const Icon(Icons.shopping_cart_outlined),
                if (cart.count > 0) Positioned(right: -4, top: -4,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                    child: Center(child: Text('${cart.count}', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700))),
                  )),
              ])),
              activeIcon: const Icon(Icons.shopping_cart_rounded),
              label: 'CART',
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final CartController cart;
  const _TopBar({required this.scaffoldKey, required this.cart});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(children: [
      GestureDetector(
        onTap: () => scaffoldKey.currentState?.openDrawer(),
        child: Container(
          width: 44, height: 44,
          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
          child: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
        ),
      ),
      const SizedBox(width: 10),
      const Expanded(child: Row(children: [
        Text('Deliver to', style: TextStyle(fontFamily:'Poppins', fontSize:15, fontWeight:FontWeight.w600, color:AppColors.textPrimary)),
        SizedBox(width: 4),
        Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary, size: 20),
      ])),
      Obx(() => GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.cart),
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
            child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary),
          ),
          if (cart.count > 0) Positioned(right: -2, top: -2,
            child: Container(
              width: 18, height: 18,
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              child: Center(child: Text('${cart.count}', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700))),
            )),
        ]),
      )),
    ]),
  );
}

class _DeliveryBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: const Icon(Icons.location_on_outlined, color: AppColors.textOnPrimary, size: 20),
      ),
      const SizedBox(width: 10),
      const Text('DELIVERY', style: TextStyle(fontFamily:'Poppins', fontSize:12, fontWeight:FontWeight.w700, color:AppColors.textPrimary, letterSpacing:1.5)),
    ]),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(fontFamily:'Poppins', fontSize:17, fontWeight:FontWeight.w700, color:AppColors.textPrimary)),
      GestureDetector(onTap: onViewAll,
        child: const Text('VIEW ALL', style: TextStyle(fontFamily:'Poppins', fontSize:13, fontWeight:FontWeight.w600, color:AppColors.accent))),
    ]),
  );
}

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
    height: 155,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: const LinearGradient(
        colors: [Color(0xFFE31837), Color(0xFFFF6B6B)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    child: Stack(children: [
      Positioned(right: -20, top: -20, child: Container(
        width: 130, height: 130,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)),
      )),
      Positioned(right: 14, top: 10, child: const Text('🍕', style: TextStyle(fontSize: 70))),
      Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
            child: const Text('HUNGER POINT SPECIAL', style: TextStyle(fontFamily:'Poppins', fontSize:8, fontWeight:FontWeight.w700, color:AppColors.textOnPrimary, letterSpacing:0.5)),
          ),
          const SizedBox(height: 8),
          const Text('🔥 Make Your Own Deal', style: TextStyle(fontFamily:'Poppins', fontSize:17, fontWeight:FontWeight.w800, color:Colors.white)),
          const SizedBox(height: 4),
          const Text('10% OFF on orders above Rs. 4,000', style: TextStyle(fontFamily:'Poppins', fontSize:12, color:Colors.white70)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: const Text('Order Now →', style: TextStyle(fontFamily:'Poppins', fontSize:12, fontWeight:FontWeight.w700, color:AppColors.accent)),
          ),
        ]),
      ),
    ]),
  );
}

class _CategoryTile extends StatelessWidget {
  final String category;
  final int count;
  final VoidCallback onTap;
  const _CategoryTile({required this.category, required this.count, required this.onTap});

  static const Map<String, String> _emoji = {
    'Deals':'🔥','Burgers':'🍔','Pizza':'🍕','Fried Chicken':'🍗',
    'Wings':'🍖','Fries':'🍟','Shawarma':'🌯','Paratha Roll':'🫔',
    'Biryani':'🍛','Chinese':'🥡','Soup':'🍲','Pasta':'🍝','Fish & Chips':'🐟',
  };

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(_emoji[category] ?? '🍴', style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(category, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily:'Poppins', fontSize:10, fontWeight:FontWeight.w600, color:AppColors.textPrimary)),
        ),
        Text('$count items', style: const TextStyle(fontFamily:'Poppins', fontSize:9, color:AppColors.textSecondary)),
      ]),
    ),
  );
}
