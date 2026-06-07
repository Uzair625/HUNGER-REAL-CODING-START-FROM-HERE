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

class _PhoneOtpScreenState extends State<PhoneOtpScreen>
    with CodeAutoFill, SingleTickerProviderStateMixin {
  final _boxes = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  int _secs = 60;
  Timer? _timer;
  bool _smsDetected = false;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  // ── Lifecycle ──────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
    _startTimer();
    _startSmsListening();
    _setupBackspaceHandlers();
  }

  Future<void> _startSmsListening() async {
    try {
      await SmsAutoFill().listenForCode();
      listenForCode();
    } catch (_) {}
  }

  void _setupBackspaceHandlers() {
    for (int i = 0; i < 6; i++) {
      final idx = i;
      _nodes[idx].onKeyEvent = (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _boxes[idx].text.isEmpty &&
            idx > 0) {
          _nodes[idx - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  @override
  void codeUpdated() {
    if (!mounted) return;
    final digits = (code ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length == 6) {
      _fillBoxes(digits);
      setState(() => _smsDetected = true);
    }
  }

  @override
  void dispose() {
    cancel();
    SmsAutoFill().unregisterListener();
    _timer?.cancel();
    _shakeCtrl.dispose();
    for (final c in _boxes) { c.dispose(); }
    for (final n in _nodes) { n.dispose(); }
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secs = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) { _timer?.cancel(); return; }
      if (_secs > 0) { setState(() => _secs--); }
      else { _timer?.cancel(); }
    });
  }

  String get _otp => _boxes.map((c) => c.text).join();

  void _fillBoxes(String digits, {int start = 0}) {
    for (int j = 0; j < digits.length && (start + j) < 6; j++) {
      _boxes[start + j].text = digits[j];
    }
    final next = (start + digits.length).clamp(0, 5);
    _nodes[next].requestFocus();
    setState(() {});
    if (_otp.length == 6) _verify();
  }

  void _onChanged(int i, String v) {
    if (v.isEmpty) {
      setState(() {});
      return;
    }
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      _boxes[i].clear();
      return;
    }
    _fillBoxes(digits, start: i);
  }



  void _verify() {
    if (_otp.length < 6) {
      _shakeCtrl.forward(from: 0);
      return;
    }
    Get.find<AuthController>().verifyOtp(_otp, widget.phone);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final digits = (data?.text ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 6) {
      _fillBoxes(digits.substring(0, 6));
      setState(() => _smsDetected = true);
    }
  }

  void _resend() {
    setState(() {
      _smsDetected = false;
      for (final b in _boxes) { b.clear(); }
    });
    _startTimer();
    cancel();
    _startSmsListening();
    _nodes[0].requestFocus();
    Get.find<AuthController>().sendOtp(widget.phone);
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const SizedBox(height: 8),

            // ── Icon ──────────────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 88, height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _smsDetected ? AppColors.success : AppColors.primary,
                boxShadow: [BoxShadow(
                  color: (_smsDetected ? AppColors.success : AppColors.primary)
                      .withValues(alpha: 0.30),
                  blurRadius: 28, spreadRadius: 2, offset: const Offset(0, 8),
                )],
              ),
              child: Center(child: Icon(
                _smsDetected ? Icons.check_rounded : Icons.lock_outline_rounded,
                color: Colors.white, size: 40,
              )),
            ),
            const SizedBox(height: 28),

            // ── Title ────────────────────────────────────────────────
            const Text('Enter OTP',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 26,
                fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            RichText(text: TextSpan(
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14,
                color: AppColors.textSecondary, height: 1.5),
              children: [
                const TextSpan(text: '6-digit code sent to\n'),
                TextSpan(text: widget.phone,
                  style: const TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w700,
                    fontSize: 15)),
              ],
            ), textAlign: TextAlign.center),
            const SizedBox(height: 36),

            // ── OTP boxes ─────────────────────────────────────────────
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(_shakeAnim.value, 0), child: child),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _OtpBox(
                  controller: _boxes[i],
                  focusNode: _nodes[i],
                  filled: _boxes[i].text.isNotEmpty,
                  detected: _smsDetected,
                  onChanged: (v) => _onChanged(i, v),
                )),
              ),
            ),
            const SizedBox(height: 16),

            // ── Paste button ────────────────────────────────────────
            TextButton.icon(
              onPressed: _pasteFromClipboard,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              icon: const Icon(Icons.content_paste_rounded, size: 15),
              label: const Text('Paste OTP',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                  fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 24),

            // ── Verify button ────────────────────────────────────────
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: auth.isLoading.value ? 0 : 3,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
                onPressed: auth.isLoading.value || _otp.length < 6 ? null : _verify,
                child: auth.isLoading.value
                  ? const SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('Verify & Continue',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
                        fontWeight: FontWeight.w700, letterSpacing: 0.3)),
              ),
            )),
            const SizedBox(height: 24),

            // ── Resend ──────────────────────────────────────────────
            _secs > 0
              ? RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
                      color: AppColors.textSecondary),
                    children: [
                      const TextSpan(text: "Didn't receive it? Resend in "),
                      TextSpan(text: '${_secs}s',
                        style: const TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ],
                  ))
              : TextButton(
                  onPressed: _resend,
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  child: const Text('Resend OTP',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                      fontWeight: FontWeight.w700))),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }
}

// ── OTP Box ───────────────────────────────────────────────────────────────────

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
    final Color borderColor;
    final Color bgColor;
    final Color textColor;

    if (detected && filled) {
      borderColor = AppColors.success;
      bgColor = const Color(0xFFEDF7EE);
      textColor = AppColors.success;
    } else if (filled) {
      borderColor = AppColors.primary;
      bgColor = const Color(0xFFFFF2F3);
      textColor = AppColors.primary;
    } else {
      borderColor = const Color(0xFFDDDDDD);
      bgColor = Colors.white;
      textColor = AppColors.textPrimary;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46,
      height: 58,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: filled ? 2.0 : 1.5),
        boxShadow: filled
          ? [BoxShadow(
              color: borderColor.withValues(alpha: 0.22),
              blurRadius: 10, offset: const Offset(0, 4))]
          : [BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4, offset: const Offset(0, 2))],
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: 32,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLines: 1,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textColor,
            height: 1.0,
          ),
          decoration: const InputDecoration(
            counterText: '',
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
