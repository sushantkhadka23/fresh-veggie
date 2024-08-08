import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions android = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY_ANDROID']!,
    appId: dotenv.env['FIREBASE_APP_ID_ANDROID']!,
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID_ANDROID']!,
    projectId: dotenv.env['FIREBASE_PROJECT_ID_ANDROID']!,
    databaseURL: dotenv.env['FIREBASE_DATABASE_URL_ANDROID']!,
    storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET_ANDROID']!,
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY_IOS']!,
    appId: dotenv.env['FIREBASE_APP_ID_IOS']!,
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID_IOS']!,
    projectId: dotenv.env['FIREBASE_PROJECT_ID_IOS']!,
    databaseURL: dotenv.env['FIREBASE_DATABASE_URL_IOS']!,
    storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET_IOS']!,
    androidClientId: dotenv.env['FIREBASE_ANDROID_CLIENT_ID'],
    iosClientId: dotenv.env['FIREBASE_IOS_CLIENT_ID'],
    iosBundleId: dotenv.env['FIREBASE_IOS_BUNDLE_ID'],
  );
}
