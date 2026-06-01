import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  // Lazy getters — safe even if Firebase.initializeApp() wasn't called yet
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  final Rx<UserModel?> user     = Rx<UserModel?>(null);
  final RxBool isLoading        = false.obs;
  final RxString verificationId = ''.obs;

  // Web-only: holds the ConfirmationResult from signInWithPhoneNumber
  ConfirmationResult? _webConfirmation;

  final phoneCtrl = TextEditingController();
  final otpCtrl   = TextEditingController();
  final nameCtrl  = TextEditingController();
  final emailCtrl = TextEditingController();
  final dobCtrl   = TextEditingController();

  final phoneFormKey   = GlobalKey<FormState>();
  final otpFormKey     = GlobalKey<FormState>();
  final profileFormKey = GlobalKey<FormState>();

  bool get isLoggedIn => user.value != null;
  bool get isGuest    => user.value?.isGuest ?? false;

  @override
  void onClose() {
    phoneCtrl.dispose(); otpCtrl.dispose();
    nameCtrl.dispose(); emailCtrl.dispose(); dobCtrl.dispose();
    super.onClose();
  }

  void _snap(String title, String msg, {bool err = false}) => Get.snackbar(
    title, msg,
    backgroundColor: err ? Colors.red.shade600 : Colors.green.shade600,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 3),
  );

  Future<void> _savePrefs(UserModel u) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(AppConstants.prefUserId,      u.uid);
    await p.setString(AppConstants.prefUserName,    u.name);
    await p.setString(AppConstants.prefUserPhone,   u.phone);
    await p.setString(AppConstants.prefUserEmail,   u.email);
    await p.setString(AppConstants.prefUserDob,     u.dob);
    await p.setString(AppConstants.prefUserAddress, u.address);
    await p.setBool(AppConstants.prefGuestMode,     u.isGuest);
  }

  // ── Phone OTP ─────────────────────────────────────────────────────

  Future<void> sendOtp(String rawPhone) async {
    isLoading.value = true;
    String phone = rawPhone.trim().replaceAll(RegExp(r'[\s\-]'), '');
    if (phone.startsWith('0')) phone = '+92${phone.substring(1)}';
    if (!phone.startsWith('+')) phone = '+92$phone';

    try {
      if (kIsWeb) {
        // Web: signInWithPhoneNumber shows reCAPTCHA automatically
        _webConfirmation = await _auth.signInWithPhoneNumber(phone);
        Get.toNamed(AppRoutes.phoneOtp, arguments: rawPhone);
      } else {
        // Mobile: verifyPhoneNumber with auto-retrieval
        await _auth.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (cred) async {
            await _auth.signInWithCredential(cred);
            await _onVerified(_auth.currentUser!, rawPhone);
          },
          verificationFailed: (e) => _snap('Error', e.message ?? 'Verification failed', err: true),
          codeSent: (verId, _) {
            verificationId.value = verId;
            Get.toNamed(AppRoutes.phoneOtp, arguments: rawPhone);
          },
          codeAutoRetrievalTimeout: (_) {},
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('🔴 FirebaseAuthException [${e.code}]: ${e.message}');
      String msg;
      switch (e.code) {
        case 'invalid-phone-number':
          msg = 'Invalid phone number format.';
          break;
        case 'too-many-requests':
          msg = 'Too many attempts. Try again later.';
          break;
        case 'operation-not-allowed':
          msg = 'Phone auth not enabled. Enable it in Firebase Console → Authentication → Sign-in method.';
          break;
        case 'invalid-api-key':
          msg = 'Invalid Firebase API key. Update firebase_options.dart with real credentials.';
          break;
        case 'app-not-authorized':
          msg = 'App not authorized. Check Firebase Console → Authentication → Authorized domains.';
          break;
        default:
          msg = '[${e.code}] ${e.message ?? 'Unknown Firebase error'}';
      }
      _snap('Auth Error', msg, err: true);
    } catch (e) {
      final raw = e.toString();
      debugPrint('🔴 Auth catch: $raw');
      final String msg;
      if (raw.contains('CONFIGURATION_NOT_FOUND') || raw.contains('invalid-api-key') || raw.contains('API key')) {
        msg = 'Invalid Firebase config. Paste real credentials in firebase_options.dart.';
      } else if (raw.contains('operation-not-allowed') || raw.contains('NOT_ENABLED')) {
        msg = 'Phone auth not enabled in Firebase Console.';
      } else {
        msg = 'OTP failed: ${raw.length > 120 ? raw.substring(0, 120) : raw}';
      }
      _snap('Setup Required', msg, err: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String code, String rawPhone) async {
    isLoading.value = true;
    try {
      UserCredential result;
      if (kIsWeb && _webConfirmation != null) {
        result = await _webConfirmation!.confirm(code.trim());
      } else {
        final cred = PhoneAuthProvider.credential(
          verificationId: verificationId.value, smsCode: code.trim());
        result = await _auth.signInWithCredential(cred);
      }
      await _onVerified(result.user!, rawPhone);
    } on FirebaseAuthException catch (e) {
      _snap('Wrong OTP', e.message ?? 'Invalid code', err: true);
    } catch (e) {
      _snap('Error', 'Verification failed. Try again.', err: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _onVerified(User fbUser, String phone) async {
    final doc = await _db.collection(AppConstants.colUsers).doc(fbUser.uid).get();
    UserModel u;
    final isNew = !doc.exists;
    if (doc.exists) {
      u = UserModel.fromMap(doc.data()!);
    } else {
      u = UserModel(uid: fbUser.uid, phone: phone, authMode: AppConstants.authPhone);
      await _db.collection(AppConstants.colUsers).doc(u.uid).set(u.toMap());
    }
    user.value = u;
    await _savePrefs(u);
    if (isNew) {
      Get.offAllNamed(AppRoutes.profileSetup);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void goHome() => Get.offAllNamed(AppRoutes.home);

  // ── Guest ─────────────────────────────────────────────────────────

  Future<void> continueAsGuest() async {
    isLoading.value = true;
    try {
      final uid = const Uuid().v4();
      final u = UserModel(uid: uid, name: 'Guest', authMode: AppConstants.authGuest, isGuest: true);
      user.value = u;
      await _savePrefs(u);
      Get.offAllNamed(AppRoutes.home);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Update Profile ────────────────────────────────────────────────

  Future<void> updateProfile({required String name, required String email, required String dob, String address = ''}) async {
    if (user.value == null || isGuest) return;
    isLoading.value = true;
    try {
      final updated = user.value!.copyWith(name: name, email: email, dob: dob, address: address);
      await _db.collection(AppConstants.colUsers).doc(updated.uid).update({
        'name': name, 'email': email, 'dob': dob, 'address': address,
      });
      user.value = updated;
      await _savePrefs(updated);
      _snap('Saved!', 'Profile updated successfully');
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      _snap('Error', 'Could not update profile', err: true);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Restore session ───────────────────────────────────────────────

  Future<void> restoreSession() async {
    final p = await SharedPreferences.getInstance();
    final uid = p.getString(AppConstants.prefUserId);
    if (uid == null || uid.isEmpty) return;
    final isGuest = p.getBool(AppConstants.prefGuestMode) ?? false;
    user.value = UserModel(
      uid:     uid,
      name:    p.getString(AppConstants.prefUserName)    ?? '',
      phone:   p.getString(AppConstants.prefUserPhone)   ?? '',
      email:   p.getString(AppConstants.prefUserEmail)   ?? '',
      dob:     p.getString(AppConstants.prefUserDob)     ?? '',
      address: p.getString(AppConstants.prefUserAddress) ?? '',
      authMode: isGuest ? AppConstants.authGuest : AppConstants.authPhone,
      isGuest: isGuest,
    );
  }

  // ── Sign Out ──────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      if (!isGuest) await _auth.signOut();
    } catch (_) {}
    user.value = null;
    final p = await SharedPreferences.getInstance();
    await p.clear();
    Get.offAllNamed(AppRoutes.auth);
  }
}
