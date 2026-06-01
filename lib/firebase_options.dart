// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return _web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _android;
      case TargetPlatform.iOS:
        return _ios;
      case TargetPlatform.macOS:
        return _macos;
      case TargetPlatform.windows:
        return _windows;
      case TargetPlatform.linux:
        return _linux;
      default:
        return _web;
    }
  }

  static const _web = FirebaseOptions(
    apiKey: 'AIzaSyB8Xg3NHdbvo8Yl5BvTgSfh-yeM9_k1NR4',
    appId: '1:850010452933:web:aaa44a02989e71d42051ac',
    messagingSenderId: '850010452933',
    projectId: 'hunger-point-910ef',
    authDomain: 'hunger-point-910ef.firebaseapp.com',
    storageBucket: 'hunger-point-910ef.firebasestorage.app',
    measurementId: 'G-XP2NPRE98V',
  );

  static const _android = FirebaseOptions(
    apiKey: 'AIzaSyB8Xg3NHdbvo8Yl5BvTgSfh-yeM9_k1NR4',
    appId: '1:850010452933:android:0000000000000000000000',
    messagingSenderId: '850010452933',
    projectId: 'hunger-point-910ef',
    storageBucket: 'hunger-point-910ef.firebasestorage.app',
  );

  static const _ios = FirebaseOptions(
    apiKey: 'AIzaSyB8Xg3NHdbvo8Yl5BvTgSfh-yeM9_k1NR4',
    appId: '1:850010452933:ios:0000000000000000000000',
    messagingSenderId: '850010452933',
    projectId: 'hunger-point-910ef',
    storageBucket: 'hunger-point-910ef.firebasestorage.app',
    iosBundleId: 'com.example.hungerPoint',
  );

  static const _macos = FirebaseOptions(
    apiKey: 'AIzaSyB8Xg3NHdbvo8Yl5BvTgSfh-yeM9_k1NR4',
    appId: '1:850010452933:ios:0000000000000000000000',
    messagingSenderId: '850010452933',
    projectId: 'hunger-point-910ef',
    storageBucket: 'hunger-point-910ef.firebasestorage.app',
    iosBundleId: 'com.example.hungerPoint',
  );

  static const _windows = FirebaseOptions(
    apiKey: 'AIzaSyB8Xg3NHdbvo8Yl5BvTgSfh-yeM9_k1NR4',
    appId: '1:850010452933:web:aaa44a02989e71d42051ac',
    messagingSenderId: '850010452933',
    projectId: 'hunger-point-910ef',
    authDomain: 'hunger-point-910ef.firebaseapp.com',
    storageBucket: 'hunger-point-910ef.firebasestorage.app',
  );

  static const _linux = FirebaseOptions(
    apiKey: 'AIzaSyB8Xg3NHdbvo8Yl5BvTgSfh-yeM9_k1NR4',
    appId: '1:850010452933:web:aaa44a02989e71d42051ac',
    messagingSenderId: '850010452933',
    projectId: 'hunger-point-910ef',
    authDomain: 'hunger-point-910ef.firebaseapp.com',
    storageBucket: 'hunger-point-910ef.firebasestorage.app',
  );
}
