import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/colors.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(children: [
            // Support icon
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 14, right: 16),
                child: _circleBtn(Icons.headset_mic_outlined, AppColors.textSecondary, () {}),
              ),
            ),
            const Spacer(flex: 2),
            // Food logo
            Container(
              width: 130, height: 130,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFFFFE5E5), Color(0xFFFFB3B3)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0,8))]),
              child: const Center(child: Text('🍔', style: TextStyle(fontSize: 68))),
            ),
            const SizedBox(height: 24),
            const Text('Hey there, feeling hungry?', textAlign: TextAlign.center,
              style: TextStyle(fontFamily:'Poppins', fontSize:22, fontWeight:FontWeight.w700, color:AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text("Let's enjoy your food with Hunger Point!",
              style: TextStyle(fontFamily:'Poppins', fontSize:14, color:AppColors.textSecondary)),
            const Spacer(flex: 3),
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                Obx(() => ElevatedButton.icon(
                  onPressed: auth.isLoading.value ? null : () => _showPhoneSheet(context, auth),
                  icon: const Icon(Icons.phone_outlined, size: 20),
                  label: const Text('CONTINUE WITH PHONE'),
                )),
                const SizedBox(height: 14),
                Obx(() => OutlinedButton(
                  onPressed: auth.isLoading.value ? null : () => _showGuestSheet(context, auth),
                  child: const Text('CONTINUE AS A GUEST'),
                )),
              ]),
            ),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44, height: 44,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white,
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
      child: Icon(icon, color: color, size: 22),
    ),
  );

  void _showPhoneSheet(BuildContext ctx, AuthController auth) {
    final phoneKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: ctx, isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 20, left: 24, right: 24),
        child: Form(
          key: phoneKey,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Enter your phone number', style: TextStyle(fontFamily:'Poppins', fontSize:18, fontWeight:FontWeight.w700)),
            const SizedBox(height: 4),
            const Text("We'll send you a 6-digit OTP to verify",
              style: TextStyle(fontFamily:'Poppins', fontSize:13, color:AppColors.textSecondary)),
            const SizedBox(height: 18),
            TextFormField(
              controller: auth.phoneCtrl,
              keyboardType: TextInputType.phone,
              autofocus: true,
              maxLength: 11,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: '03001234567',
                prefixIcon: Icon(Icons.phone_outlined),
                counterText: '',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Phone number required';
                if (v.length < 10) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Obx(() => ElevatedButton(
              onPressed: auth.isLoading.value ? null : () {
                if (phoneKey.currentState!.validate()) {
                  Navigator.pop(ctx);
                  auth.sendOtp(auth.phoneCtrl.text);
                }
              },
              child: auth.isLoading.value
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF1A1A1A)))
                : const Text('SEND OTP'),
            )),
          ]),
        ),
      ),
    );
  }

  void _showGuestSheet(BuildContext ctx, AuthController auth) {
    showModalBottomSheet(
      context: ctx, isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text('Continue as Guest', style: TextStyle(fontFamily:'Poppins', fontSize:18, fontWeight:FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Browse the menu and place orders without an account',
            style: TextStyle(fontFamily:'Poppins', fontSize:13, color:AppColors.textSecondary)),
          const SizedBox(height: 20),
          _featureRow(Icons.check_circle_outline, 'Browse full menu', false),
          _featureRow(Icons.check_circle_outline, 'Place orders with COD', false),
          _featureRow(Icons.cancel_outlined, 'No order history saved', true),
          const SizedBox(height: 20),
          Obx(() => ElevatedButton(
            onPressed: auth.isLoading.value ? null : () { Navigator.pop(ctx); auth.continueAsGuest(); },
            child: const Text('CONTINUE AS GUEST'),
          )),
          const SizedBox(height: 10),
          Center(child: TextButton(
            onPressed: () { Navigator.pop(ctx); _showPhoneSheet(ctx, auth); },
            child: const Text('Have account? Sign in with Phone', style: TextStyle(color: AppColors.accent)),
          )),
        ]),
      ),
    );
  }

  Widget _featureRow(IconData icon, String text, bool isNeg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Icon(icon, size: 18, color: isNeg ? AppColors.textLight : AppColors.success),
      const SizedBox(width: 10),
      Text(text, style: TextStyle(fontFamily:'Poppins', fontSize:13,
        color: isNeg ? AppColors.textLight : AppColors.textPrimary)),
    ]),
  );
}
