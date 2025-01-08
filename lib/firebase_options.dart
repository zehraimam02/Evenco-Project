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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDcUgvYRc7Lyy1SGwjZ9Or5QnedIAXTYHw',
    appId: '1:779928669642:web:c4bbeddb48044ef8409333',
    messagingSenderId: '779928669642',
    projectId: 'project-evenco',
    authDomain: 'project-evenco.firebaseapp.com',
    storageBucket: 'project-evenco.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZTyabbBdH2qBtQNyIcaibQ_Kpta0-oxc',
    appId: '1:779928669642:android:289fffe162f4bc1b409333',
    messagingSenderId: '779928669642',
    projectId: 'project-evenco',
    storageBucket: 'project-evenco.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAV784nNeUtzxq7AWE3xClseDlgIcE3JFs',
    appId: '1:779928669642:ios:6c64467156d88418409333',
    messagingSenderId: '779928669642',
    projectId: 'project-evenco',
    storageBucket: 'project-evenco.firebasestorage.app',
    iosBundleId: 'com.example.evencoApp',
  );
}
