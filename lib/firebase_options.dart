import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// PLACEHOLDER. Do not fill this in by hand.
///
/// Run `flutterfire configure` from the project root (see README.md, step 3)
/// and it will overwrite this entire file with the real, correct values for
/// every platform you select. Committing hand-typed API keys here is a
/// common source of "it works on my machine" bugs — let the CLI generate it.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBZHHyYey4EAC_1AGw19qQ2DfNFtVzKm3U',
    appId: '1:121336374429:web:31497dc22adae380a7a074',
    messagingSenderId: '121336374429',
    projectId: 'debate-tab-app',
    authDomain: 'debate-tab-app.firebaseapp.com',
    storageBucket: 'debate-tab-app.firebasestorage.app',
    measurementId: 'G-SXR8WQDQRX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyClCp1HSLpTcrevQugVfufD1f6WAuNLAAI',
    appId: '1:121336374429:android:ce557d9f49f5a686a7a074',
    messagingSenderId: '121336374429',
    projectId: 'debate-tab-app',
    storageBucket: 'debate-tab-app.firebasestorage.app',
  );
}
