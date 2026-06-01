import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/colors.dart';

class PhoneOtpScreen extends StatefulWidget {
  final String phone;
  const PhoneOtpScreen({super.key, required this.phone});
  @override State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final _boxes = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());
  int _secs = 60;
  Timer? _timer;

  @override
  void initState() { super.initState(); _startTimer(); }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _boxes) c.dispose();
    for (var n in _nodes) n.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secs = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secs > 0) setState(() => _secs--); else _timer?.cancel();
    });
  }

  String get _otp => _boxes.map((c) => c.text).join();

  void _onKey(int i, String v) {
    if (v.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
    else if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
    if (_otp.length == 6) _verify();
  }

  void _verify() => Get.find<AuthController>().verifyOtp(_otp, widget.phone);

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(children: [
          const SizedBox(height: 20),

          // Icon circle
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))],
            ),
            child: const Icon(Icons.sms_rounded, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 28),

          const Text('Verify your number',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          RichText(text: TextSpan(
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textSecondary),
            children: [
              const TextSpan(text: 'OTP sent to '),
              TextSpan(text: widget.phone,
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ],
          )),

          const SizedBox(height: 40),

          // OTP boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) => _OtpBox(
              controller: _boxes[i],
              focusNode: _nodes[i],
              onChanged: (v) => _onKey(i, v),
            )),
          ),

          const SizedBox(height: 36),

          // Verify button
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 2,
              ),
              onPressed: auth.isLoading.value || _otp.length < 6 ? null : _verify,
              child: auth.isLoading.value
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Text('Continue',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          )),

          const SizedBox(height: 20),

          // Resend
          Center(child: _secs > 0
            ? Text('Resend OTP in ${_secs}s',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary))
            : TextButton(
                onPressed: () { _startTimer(); auth.sendOtp(widget.phone); },
                child: const Text('Resend OTP',
                  style: TextStyle(fontFamily: 'Poppins', color: AppColors.primary, fontWeight: FontWeight.w600)))),
        ]),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  const _OtpBox({required this.controller, required this.focusNode, required this.onChanged});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 48, height: 58,
    child: TextFormField(
      controller: controller,
      focusNode: focusNode,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 1,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      decoration: InputDecoration(
        counterText: '',
        contentPadding: EdgeInsets.zero,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
      onChanged: onChanged,
    ),
  );
}