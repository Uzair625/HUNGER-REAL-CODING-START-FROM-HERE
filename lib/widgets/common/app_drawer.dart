import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── User Header ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Obx(() {
            final u = auth.user.value;
            return Row(children: [
              Container(
                width: 58, height: 58,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Center(child: Text(
                  u?.isGuest == true ? '👤'
                    : (u?.name.isNotEmpty == true ? u!.name[0].toUpperCase() : '?'),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                )),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  u?.isGuest == true ? 'Guest User'
                    : (u?.name.isNotEmpty == true ? u!.name : 'Hunger Point Customer'),
                  style: const TextStyle(fontFamily:'Poppins', fontSize:15, fontWeight:FontWeight.w700, color:AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  u?.phone.isNotEmpty == true ? u!.phone : (u?.email.isNotEmpty == true ? u!.email : 'Not signed in'),
                  style: const TextStyle(fontFamily:'Poppins', fontSize:12, color:AppColors.textSecondary),
                ),
              ])),
            ]);
          }),
        ),

        // View Profile button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: ElevatedButton(
            onPressed: () { Navigator.pop(context); Get.toNamed(AppRoutes.profile); },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('VIEW PROFILE', style: TextStyle(fontWeight:FontWeight.w800, letterSpacing:0.8)),
          ),
        ),

        const Divider(height: 24),

        // Nav items
        _DrawerItem(icon: Icons.inventory_2_outlined, label: 'Order History',
          onTap: () { Navigator.pop(context); Get.toNamed(AppRoutes.orderHistory); }),
        _DrawerItem(icon: Icons.favorite_border_rounded, label: 'My Favorites',
          onTap: () => Navigator.pop(context)),
        _DrawerItem(icon: Icons.grid_view_rounded, label: 'Explore Menu',
          onTap: () { Navigator.pop(context); Get.toNamed(AppRoutes.explore); }),
        _DrawerItem(icon: Icons.star_border_rounded, label: 'Ratings & Feedbacks',
          onTap: () => Navigator.pop(context)),

        const Divider(height: 8),

        _DrawerItem(icon: Icons.logout_rounded, label: 'Logout',
          onTap: () { Navigator.pop(context); auth.signOut(); }),

        const Spacer(),

        // CONTACT US footer
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Center(child: Text('🍔', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('CONTACT US', style: TextStyle(fontFamily:'Poppins', fontSize:14, fontWeight:FontWeight.w800, color:AppColors.textOnPrimary))),
                Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                  child: const Icon(Icons.phone_outlined, color: Colors.white, size: 18),
                ),
              ]),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: const Text('Terms & Conditions', style: TextStyle(fontSize:11, color:AppColors.accent)),
            ),
            Text('v${AppConstants.appVersion}', style: const TextStyle(fontFamily:'Poppins', fontSize:11, color:AppColors.textLight)),
          ]),
        ),
      ])),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.textPrimary, size: 22),
    title: Text(label, style: const TextStyle(fontFamily:'Poppins', fontSize:14, fontWeight:FontWeight.w500, color:AppColors.textPrimary)),
    trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
  );
}
