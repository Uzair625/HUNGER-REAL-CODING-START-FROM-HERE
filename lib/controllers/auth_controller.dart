import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  final Rx<UserModel?> user     = Rx<UserModel?>(null);
  final RxBool isLoading        = false.obs;
  final RxString verificationId = ''.obs;

  ConfirmationResult? _webConfirmation;

  final phoneCtrl = TextEditingController();
  final otpCtrl   = TextEditingController();
  final nameCtrl  = TextEditingController();
  final emailCtrl = TextEditingController();
  final dobCtrl   = TextEditingController();
  final addressCtrl = TextEditingController();

  final phoneFormKey   = GlobalKey<FormState>();
  final otpFormKey     = GlobalKey<FormState>();
  final profileFormKey = GlobalKey<FormState>();

  bool get isLoggedIn => user.value != null;
  bool get isGuest    => user.value?.isGuest ?? false;

  @override
  void onClose() {
    phoneCtrl.dispose(); otpCtrl.dispose();
    nameCtrl.dispose(); emailCtrl.dispose();
    dobCtrl.dispose(); addressCtrl.dispose();
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
    await p.setString(AppConstants.prefUserPhoto,   u.photoUrl);
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
        _webConfirmation = await _auth.signInWithPhoneNumber(phone);
        Get.toNamed(AppRoutes.phoneOtp, arguments: rawPhone);
      } else {
        await _auth.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (cred) async {
            await _auth.signInWithCredential(cred);
            await _onVerified(_auth.currentUser!, rawPhone);
          },
          verificationFailed: (e) {
            isLoading.value = false;
            debugPrint('🔴 verificationFailed [${e.code}]: ${e.message}');
            String msg;
            switch (e.code) {
              case 'app-not-authorized':
                msg = 'App not authorized. SHA-1 not registered in Firebase.'; break;
              case 'billing-not-enabled':
                msg = 'Upgrade Firebase project to Blaze plan to send real OTPs.'; break;
              case 'invalid-phone-number':
                msg = 'Invalid phone number. Use format 03XX-XXXXXXX.'; break;
              case 'too-many-requests':
                msg = 'Too many attempts. Try again in a few minutes.'; break;
              case 'quota-exceeded':
                msg = 'SMS quota exceeded for today.'; break;
              default:
                msg = '[${e.code}] ${e.message ?? 'Verification failed'}';
            }
            _snap('OTP Error', msg, err: true);
          },
          codeSent: (verId, _) {
            verificationId.value = verId;
            isLoading.value = false;
            Get.toNamed(AppRoutes.phoneOtp, arguments: rawPhone);
          },
          codeAutoRetrievalTimeout: (_) {},
        );
        return; // isLoading reset in codeSent / verificationFailed callbacks
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
          msg = 'Phone auth not enabled in Firebase Console.';
          break;
        case 'invalid-api-key':
          msg = 'Invalid Firebase API key.';
          break;
        default:
          msg = '[${e.code}] ${e.message ?? 'Unknown Firebase error'}';
      }
      _snap('Auth Error', msg, err: true);
    } catch (e) {
      final raw = e.toString();
      debugPrint('🔴 Auth catch: $raw');
      final String msg;
      if (raw.contains('CONFIGURATION_NOT_FOUND') || raw.contains('invalid-api-key')) {
        msg = 'Invalid Firebase config. Check firebase_options.dart.';
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
        if (verificationId.value.isEmpty) {
          _snap('Error', 'Session expired. Please request a new OTP.', err: true);
          return;
        }
        final cred = PhoneAuthProvider.credential(
          verificationId: verificationId.value, smsCode: code.trim());
        result = await _auth.signInWithCredential(cred);
      }
      await _onVerified(result.user!, rawPhone);
    } on FirebaseAuthException catch (e) {
      _snap('Wrong OTP', e.message ?? 'Invalid code. Try again.', err: true);
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
    if (isNew || u.name.isEmpty) {
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

  // ── Update Profile (with optional photo upload) ───────────────────

  Future<void> updateProfile({
    required String name,
    required String email,
    required String dob,
    String address = '',
    Uint8List? avatarBytes,
    bool redirectHome = true,
  }) async {
    if (user.value == null || isGuest) return;
    isLoading.value = true;
    try {
      String photoUrl = user.value!.photoUrl;

      if (avatarBytes != null && avatarBytes.isNotEmpty) {
        try {
          final ref = _storage.ref('profile_photos/${user.value!.uid}.jpg');
          await ref.putData(
            avatarBytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          photoUrl = await ref.getDownloadURL();
        } catch (e) {
          debugPrint('🔴 Photo upload failed: $e');
          // Continue saving profile even if photo upload fails
        }
      }

      final updated = user.value!.copyWith(
        name: name, email: email, dob: dob,
        address: address, photoUrl: photoUrl,
      );

      final updateData = <String, dynamic>{
        'name': name, 'email': email, 'dob': dob, 'address': address,
        'photoUrl': photoUrl,
      };
      await _db.collection(AppConstants.colUsers).doc(updated.uid).set(
        updateData, SetOptions(merge: true));

      user.value = updated;
      await _savePrefs(updated);
      _snap('Saved!', 'Profile updated successfully');
      if (redirectHome) Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      debugPrint('🔴 updateProfile error: $e');
      _snap('Error', 'Could not update profile. Try again.', err: true);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Restore session (validates Firebase Auth state) ───────────────

  Future<void> restoreSession() async {
    final p = await SharedPreferences.getInstance();
    final uid = p.getString(AppConstants.prefUserId);
    if (uid == null || uid.isEmpty) return;

    final guestMode = p.getBool(AppConstants.prefGuestMode) ?? false;

    // For phone-auth users verify Firebase still has a valid session
    if (!guestMode) {
      final fbUser = _auth.currentUser;
      if (fbUser == null) {
        // Firebase session expired — clear stale prefs and force re-login
        await p.clear();
        return;
      }
    }

    user.value = UserModel(
      uid:      uid,
      name:     p.getString(AppConstants.prefUserName)    ?? '',
      phone:    p.getString(AppConstants.prefUserPhone)   ?? '',
      email:    p.getString(AppConstants.prefUserEmail)   ?? '',
      dob:      p.getString(AppConstants.prefUserDob)     ?? '',
      address:  p.getString(AppConstants.prefUserAddress) ?? '',
      photoUrl: p.getString(AppConstants.prefUserPhoto)   ?? '',
      authMode: guestMode ? AppConstants.authGuest : AppConstants.authPhone,
      isGuest:  guestMode,
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
