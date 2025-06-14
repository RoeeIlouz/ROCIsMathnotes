// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA8dv98-pHEK88QIXh-nt-5DBlhxx2I_S0',
    appId: '1:1011854802210:web:ab0d0cddcfaf55e0a1397b',
    messagingSenderId: '1011854802210',
    projectId: 'rocis-mathnotes',
    authDomain: 'rocis-mathnotes.firebaseapp.com',
    storageBucket: 'rocis-mathnotes.firebasestorage.app',
    measurementId: 'G-L1RJ64P3V0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAqQuAo5V4pg0gZWU6iqhRKn5Tj1Ur13sc',
    appId: '1:1011854802210:android:f23bda9317ad9bb9a1397b',
    messagingSenderId: '1011854802210',
    projectId: 'rocis-mathnotes',
    storageBucket: 'rocis-mathnotes.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_DJJw-a_WNZuKHVd5oUKxODflMoCuXug',
    appId: '1:1011854802210:ios:a71071163b2344bba1397b',
    messagingSenderId: '1011854802210',
    projectId: 'rocis-mathnotes',
    storageBucket: 'rocis-mathnotes.firebasestorage.app',
    iosBundleId: 'com.example.mathnotes',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA_DJJw-a_WNZuKHVd5oUKxODflMoCuXug',
    appId: '1:1011854802210:ios:a71071163b2344bba1397b',
    messagingSenderId: '1011854802210',
    projectId: 'rocis-mathnotes',
    storageBucket: 'rocis-mathnotes.firebasestorage.app',
    iosBundleId: 'com.example.mathnotes',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA8dv98-pHEK88QIXh-nt-5DBlhxx2I_S0',
    appId: '1:1011854802210:web:c35f513405b6d545a1397b',
    messagingSenderId: '1011854802210',
    projectId: 'rocis-mathnotes',
    authDomain: 'rocis-mathnotes.firebaseapp.com',
    storageBucket: 'rocis-mathnotes.firebasestorage.app',
    measurementId: 'G-TR8BBWR85B',
  );

}