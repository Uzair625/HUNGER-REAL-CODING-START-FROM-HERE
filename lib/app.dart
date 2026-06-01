import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'utils/theme.dart';
import 'utils/routes.dart';

class HungerPointApp extends StatelessWidget {
  const HungerPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Hunger Point',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}
