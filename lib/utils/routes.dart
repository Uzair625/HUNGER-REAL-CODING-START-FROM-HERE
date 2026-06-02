import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/phone_otp_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/item_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/order_confirm_screen.dart';
import '../models/menu_item_model.dart';

class AppRoutes {
  AppRoutes._();
  static const String splash        = '/';
  static const String auth          = '/auth';
  static const String phoneOtp      = '/otp';
  static const String profileSetup  = '/profile-setup';
  static const String home          = '/home';
  static const String explore       = '/explore';
  static const String itemDetail    = '/item';
  static const String cart          = '/cart';
  static const String profile       = '/profile';
  static const String orderHistory  = '/orders';
  static const String orderConfirm  = '/order-confirm';

  static final pages = [
    GetPage(name: splash,       page: () => const SplashScreen()),
    GetPage(name: auth,         page: () => const AuthScreen()),
    GetPage(name: phoneOtp,     page: () => PhoneOtpScreen(phone: Get.arguments is String ? Get.arguments as String : '')),
    GetPage(name: profileSetup, page: () => const ProfileSetupScreen()),
    GetPage(name: home,         page: () => const HomeScreen()),
    GetPage(name: explore,      page: () => ExploreScreen(initialCategory: Get.arguments is String ? Get.arguments as String : null)),
    GetPage(name: itemDetail,   page: () => Get.arguments is MenuItemModel ? ItemDetailScreen(item: Get.arguments as MenuItemModel) : const HomeScreen()),
    GetPage(name: cart,         page: () => const CartScreen()),
    GetPage(name: profile,       page: () => const ProfileScreen()),
    GetPage(name: orderHistory,  page: () => const OrderHistoryScreen()),
    GetPage(name: orderConfirm,  page: () => const OrderConfirmScreen()),
  ];
}
