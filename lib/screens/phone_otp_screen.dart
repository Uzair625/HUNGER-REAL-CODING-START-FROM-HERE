import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../controllers/auth_controller.dart';
import '../utils/colors.dart';

class PhoneOtpScreen extends StatefulWidget {
  final String phone;
  const PhoneOtpScreen({super.key, required this.phone});
  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

// CodeAutoFill (NOT SmsAutoFill) is the mixin that provides
// • code (String?)  — the detected OTP string
// • codeUpdated()   — called automatically when SMS arrives
// • listenForCode() — subscribes to the SmsAutoFill stream
// • cancel()        — unsubscribes
class _PhoneOtpScreenState extends State<PhoneOtpScreen> with CodeAutoFill {
  final _boxes = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  int _secs = 60;
  Timer? _timer;
  String _smsStatus = 'Waiting for OTP SMS…';
  bool _smsDetected = false;

  // ── Lifecycle ─────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startSmsListening();
  }

  Future<void> _startSmsListening() async {
    try {
      // 1. Start the native SMS Retriever / User Consent on Android
      await SmsAutoFill().listenForCode();
      // 2. Subscribe the CodeAutoFill mixin to the incoming code stream
      listenForCode();
      if (mounted) setState(() => _smsStatus = 'Listening for OTP SMS…');
    } catch (_) {
      // iOS / no Play Services — silent, user enters manually
    }
  }

  /// Called by [CodeAutoFill] mixin whenever an SMS code arrives.
  @override
  void codeUpdated() {
    if (!mounted) return;
    final incoming = code; // String? from CodeAutoFill
    if (incoming == null) return;
    final digits = incoming.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 6) {
      _fillBoxes(digits);
      setState(() {
        _smsDetected = true;
        _smsStatus = 'OTP detected automatically ✓';
      });
    }
  }

  @override
  void dispose() {
    cancel();                          // CodeAutoFill: unsubscribe stream
    SmsAutoFill().unregisterListener(); // stop native listener
    _timer?.cancel();
    for (final c in _boxes) { c.dispose(); }
    for (final n in _nodes) { n.dispose(); }
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secs = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) { _timer?.cancel(); return; }
      if (_secs > 0) {
        setState(() => _secs--);
      } else {
        _timer?.cancel();
      }
    });
  }

  String get _otp => _boxes.map((c) => c.text).join();

  /// Puts [digits] into boxes starting at [startIndex], trims extras to 1 char.
  void _fillBoxes(String digits, {int startIndex = 0}) {
    for (int j = 0; j < digits.length && (startIndex + j) < 6; j++) {
      _boxes[startIndex + j].text = digits[j];
    }
    for (final box in _boxes) {
      if (box.text.length > 1) box.text = box.text[box.text.length - 1];
    }
    final next = (startIndex + digits.length).clamp(0, 5);
    _nodes[next].requestFocus();
    setState(() {});
    if (_otp.length == 6) _verify();
  }

  /// Handles typing (1 char) or paste (multiple chars) in any box.
  void _onChanged(int i, String v) {
    if (v.isEmpty) {
      if (i > 0) _nodes[i - 1].requestFocus();
      setState(() {});
      return;
    }
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) { _boxes[i].clear(); return; }
    _fillBoxes(digits, startIndex: i);
  }

  void _verify() {
    if (_otp.length < 6) return;
    Get.find<AuthController>().verifyOtp(_otp, widget.phone);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final digits = (data?.text ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 6) {
      _fillBoxes(digits.substring(0, 6));
      setState(() {
        _smsDetected = true;
        _smsStatus = 'OTP pasted ✓';
      });
    }
  }

  void _resend() {
    setState(() {
      _smsDetected = false;
      _smsStatus = 'Listening for OTP SMS…';
      for (final box in _boxes) { box.clear(); }
    });
    _startTimer();
    cancel();
    _startSmsListening();
    Get.find<AuthController>().sendOtp(widget.phone);
  }

  // ── Build ─────────────────────────────────────────────────────────

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

          // ── Animated icon ──────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _smsDetected ? AppColors.success : AppColors.primary,
              boxShadow: [BoxShadow(
                color: (_smsDetected ? AppColors.success : AppColors.primary)
                    .withValues(alpha: 0.35),
                blurRadius: 24, offset: const Offset(0, 8),
              )],
            ),
            child: Icon(
              _smsDetected ? Icons.check_rounded : Icons.sms_rounded,
              color: Colors.white, size: 44,
            ),
          ),
          const SizedBox(height: 28),

          const Text('Verify your number',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 22,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),

          RichText(text: TextSpan(
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14,
              color: AppColors.textSecondary),
            children: [
              const TextSpan(text: 'OTP sent to '),
              TextSpan(text: widget.phone,
                style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ],
          )),
          const SizedBox(height: 16),

          // ── SMS status chip ────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _smsDetected
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                width: 14, height: 14,
                child: _smsDetected
                  ? const Icon(Icons.check_circle_rounded,
                      size: 14, color: AppColors.success)
                  : CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppColors.primary.withValues(alpha: 0.7)),
              ),
              const SizedBox(width: 8),
              Text(_smsStatus,
                style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500,
                  color: _smsDetected ? AppColors.success : AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: 32),

          // ── 6 OTP boxes ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) => _OtpBox(
              controller: _boxes[i],
              focusNode: _nodes[i],
              filled: _boxes[i].text.isNotEmpty,
              detected: _smsDetected,
              onChanged: (v) => _onChanged(i, v),
            )),
          ),
          const SizedBox(height: 10),

          // ── Paste button ──────────────────────────────────────────
          TextButton.icon(
            onPressed: _pasteFromClipboard,
            icon: const Icon(Icons.paste_rounded, size: 15,
              color: AppColors.textSecondary),
            label: const Text('Paste OTP',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 16),

          // ── Verify button ─────────────────────────────────────────
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
                elevation: 2,
              ),
              onPressed: auth.isLoading.value || _otp.length < 6
                  ? null : _verify,
              child: auth.isLoading.value
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white))
                : const Text('Continue',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
          )),
          const SizedBox(height: 20),

          // ── Resend countdown ──────────────────────────────────────
          Center(
            child: _secs > 0
              ? RichText(text: TextSpan(
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
                    color: AppColors.textSecondary),
                  children: [
                    const TextSpan(text: 'Resend OTP in '),
                    TextSpan(text: '${_secs}s',
                      style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ],
                ))
              : TextButton(
                  onPressed: _resend,
                  child: const Text('Resend OTP',
                    style: TextStyle(fontFamily: 'Poppins',
                      color: AppColors.primary, fontWeight: FontWeight.w600))),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

// ── Individual OTP box ─────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool filled;
  final bool detected;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.filled,
    required this.detected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activeBorder = detected && filled
        ? AppColors.success
        : filled
          ? AppColors.primary
          : AppColors.divider;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 48, height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: activeBorder, width: filled ? 2 : 1),
        boxShadow: filled
          ? [BoxShadow(
              color: (detected ? AppColors.success : AppColors.primary)
                  .withValues(alpha: 0.15),
              blurRadius: 8)]
          : null,
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700,
          color: detected && filled ? AppColors.success : AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
