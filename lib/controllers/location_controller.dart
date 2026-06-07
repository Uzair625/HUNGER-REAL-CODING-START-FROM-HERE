import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationController extends GetxController {
  static LocationController get to => Get.find();

  final RxBool hasPermission = false.obs;
  final RxBool isDetecting   = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (!kIsWeb) _checkPermission();
  }

  Future<void> _checkPermission() async {
    try {
      final p = await Geolocator.checkPermission();
      hasPermission.value = p == LocationPermission.always ||
          p == LocationPermission.whileInUse;
    } catch (_) {}
  }

  // ── Ask for permission (call on splash / profile setup) ─────────────

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        final open = await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(children: [
              Icon(Icons.location_off_rounded, color: Color(0xFFE31837)),
              SizedBox(width: 10),
              Text('Location Off', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 17)),
            ]),
            content: const Text(
              'Turn on location so we can detect your address and track your delivery.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF666666)),
            ),
            actions: [
              TextButton(onPressed: () => Get.back(result: false), child: const Text('Skip')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE31837), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Get.back(result: true),
                child: const Text('Enable', style: TextStyle(fontFamily: 'Poppins')),
              ),
            ],
          ),
        );
        if (open == true) await Geolocator.openLocationSettings();
        return false;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Denied',
          'Allow location access in app settings',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          mainButton: TextButton(
            onPressed: () => Geolocator.openAppSettings(),
            child: const Text('Open Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
        return false;
      }

      hasPermission.value = perm == LocationPermission.always ||
          perm == LocationPermission.whileInUse;
      return hasPermission.value;
    } catch (_) {
      return false;
    }
  }

  // ── Get current position ─────────────────────────────────────────────

  Future<Position?> getCurrentPosition() async {
    if (kIsWeb) return null;
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  // ── Reverse-geocode to a readable address string ─────────────────────

  Future<String> detectAddress() async {
    if (kIsWeb) return '';
    isDetecting.value = true;
    try {
      final granted = await requestPermission();
      if (!granted) return '';

      final pos = await getCurrentPosition();
      if (pos == null) return '';

      final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude)
          .timeout(const Duration(seconds: 10));
      if (marks.isEmpty) return '';

      final p = marks.first;
      final parts = <String>[
        if ((p.street ?? '').isNotEmpty) p.street!,
        if ((p.subLocality ?? '').isNotEmpty) p.subLocality!,
        if ((p.locality ?? '').isNotEmpty) p.locality!,
        if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea!,
      ];
      return parts.toSet().join(', ');
    } catch (_) {
      return '';
    } finally {
      isDetecting.value = false;
    }
  }

  // ── Silent permission request (call from splash, non-blocking) ───────

  Future<void> requestSilently() async {
    if (kIsWeb) return;
    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) return;
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      await _checkPermission();
    } catch (_) {}
  }
}
