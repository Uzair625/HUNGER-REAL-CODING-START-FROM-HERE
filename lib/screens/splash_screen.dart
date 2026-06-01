import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/colors.dart';
import '../utils/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _waveCtrl, _logoCtrl;
  late Animation<double> _waveAnim, _fadeAnim, _scaleAnim;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..forward();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _waveAnim  = CurvedAnimation(parent: _waveCtrl, curve: Curves.easeInOut);
    _fadeAnim  = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    final auth = Get.find<AuthController>();
    await auth.restoreSession();
    if (auth.isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.auth);
    }
  }

  @override
  void dispose() { _waveCtrl.dispose(); _logoCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        // Yellow wavy top area
        AnimatedBuilder(
          animation: _waveAnim,
          builder: (_, __) => SizedBox(
            width: size.width,
            height: size.height * 0.58,
            child: CustomPaint(painter: _WavePainter(_waveAnim.value)),
          ),
        ),
        // Logo in white area
        Positioned(
          bottom: size.height * 0.18,
          left: 0, right: 0,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(children: [
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0,8))],
                  ),
                  child: const Center(child: Text('🍔', style: TextStyle(fontSize: 56))),
                ),
                const SizedBox(height: 16),
                RichText(text: const TextSpan(children: [
                  TextSpan(text: 'Hunger ', style: TextStyle(fontFamily:'Poppins', fontSize:30, fontWeight:FontWeight.w800, color:Color(0xFF1A1A1A))),
                  TextSpan(text: 'Point', style: TextStyle(fontFamily:'Poppins', fontSize:30, fontWeight:FontWeight.w800, color:AppColors.accent)),
                ])),
                const SizedBox(height: 6),
                const Text('D E L I C I O U S', style: TextStyle(fontFamily:'Poppins', fontSize:11, fontWeight:FontWeight.w600, letterSpacing:5, color:AppColors.textSecondary)),
                const SizedBox(height: 4),
                const Text('ESTD 2022', style: TextStyle(fontFamily:'Poppins', fontSize:10, color:AppColors.textLight, letterSpacing:2)),
              ]),
            ),
          ),
        ),
        // Loading dot
        Positioned(
          bottom: 48, left: 0, right: 0,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: const Center(child: SizedBox(width: 28, height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.accent))),
          ),
        ),
      ]),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  _WavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    _drawLayer(canvas, size, const Color(0xFFE31837), 0.78, 0.0);
    _drawLayer(canvas, size, const Color(0xFFEF4444), 0.72, 0.5);
    _drawLayer(canvas, size, const Color(0xFFFF6B6B), 0.65, 1.0);
  }

  void _drawLayer(Canvas canvas, Size size, Color color, double heightRatio, double phase) {
    final paint = Paint()..color = color;
    final path = Path();
    final waveH = size.height * heightRatio * progress;
    final amp = size.height * 0.055;
    path.moveTo(0, 0);
    path.lineTo(0, waveH);
    final w3 = size.width / 3;
    for (int i = 0; i < 3; i++) {
      final x0 = i * w3;
      final x1 = x0 + w3 / 2;
      final x2 = x0 + w3;
      final dy = amp * (i % 2 == 0 ? 1 : -1) + phase * 8;
      path.quadraticBezierTo(x1, waveH + dy, x2, waveH);
    }
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}
