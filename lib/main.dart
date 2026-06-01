import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/menu_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register controllers permanently so they are never disposed on route changes
  Get.put(AuthController(), permanent: true);
  Get.put(CartController(), permanent: true);
  Get.put(FoodMenuController(), permanent: true);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized — project: ${DefaultFirebaseOptions.currentPlatform.projectId}');
  } catch (e) {
    debugPrint('🔴 Firebase init failed: $e');
  }

  runApp(const HungerPointApp());
}
