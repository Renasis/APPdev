// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const _dartDefineMap = <String, String>{
  'FIREBASE_WEB_API_KEY': String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
    defaultValue: '',
  ),
  'FIREBASE_WEB_APP_ID': String.fromEnvironment(
    'FIREBASE_WEB_APP_ID',
    defaultValue: '',
  ),
  'FIREBASE_WEB_MESSAGING_SENDER_ID': String.fromEnvironment(
    'FIREBASE_WEB_MESSAGING_SENDER_ID',
    defaultValue: '',
  ),
  'FIREBASE_PROJECT_ID': String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  ),
  'FIREBASE_WEB_AUTH_DOMAIN': String.fromEnvironment(
    'FIREBASE_WEB_AUTH_DOMAIN',
    defaultValue: '',
  ),
  'FIREBASE_WEB_STORAGE_BUCKET': String.fromEnvironment(
    'FIREBASE_WEB_STORAGE_BUCKET',
    defaultValue: '',
  ),
  'FIREBASE_WEB_MEASUREMENT_ID': String.fromEnvironment(
    'FIREBASE_WEB_MEASUREMENT_ID',
    defaultValue: '',
  ),
  'FIREBASE_ANDROID_API_KEY': String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
    defaultValue: '',
  ),
  'FIREBASE_ANDROID_APP_ID': String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
    defaultValue: '',
  ),
  'FIREBASE_ANDROID_MESSAGING_SENDER_ID': String.fromEnvironment(
    'FIREBASE_ANDROID_MESSAGING_SENDER_ID',
    defaultValue: '',
  ),
  'FIREBASE_ANDROID_STORAGE_BUCKET': String.fromEnvironment(
    'FIREBASE_ANDROID_STORAGE_BUCKET',
    defaultValue: '',
  ),
  'FIREBASE_IOS_API_KEY': String.fromEnvironment(
    'FIREBASE_IOS_API_KEY',
    defaultValue: '',
  ),
  'FIREBASE_IOS_APP_ID': String.fromEnvironment(
    'FIREBASE_IOS_APP_ID',
    defaultValue: '',
  ),
  'FIREBASE_IOS_MESSAGING_SENDER_ID': String.fromEnvironment(
    'FIREBASE_IOS_MESSAGING_SENDER_ID',
    defaultValue: '',
  ),
  'FIREBASE_IOS_STORAGE_BUCKET': String.fromEnvironment(
    'FIREBASE_IOS_STORAGE_BUCKET',
    defaultValue: '',
  ),
  'FIREBASE_IOS_BUNDLE_ID': String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
    defaultValue: '',
  ),
  'FIREBASE_MACOS_API_KEY': String.fromEnvironment(
    'FIREBASE_MACOS_API_KEY',
    defaultValue: '',
  ),
  'FIREBASE_MACOS_APP_ID': String.fromEnvironment(
    'FIREBASE_MACOS_APP_ID',
    defaultValue: '',
  ),
  'FIREBASE_MACOS_MESSAGING_SENDER_ID': String.fromEnvironment(
    'FIREBASE_MACOS_MESSAGING_SENDER_ID',
    defaultValue: '',
  ),
  'FIREBASE_MACOS_STORAGE_BUCKET': String.fromEnvironment(
    'FIREBASE_MACOS_STORAGE_BUCKET',
    defaultValue: '',
  ),
  'FIREBASE_MACOS_BUNDLE_ID': String.fromEnvironment(
    'FIREBASE_MACOS_BUNDLE_ID',
    defaultValue: '',
  ),
  'FIREBASE_WINDOWS_API_KEY': String.fromEnvironment(
    'FIREBASE_WINDOWS_API_KEY',
    defaultValue: '',
  ),
  'FIREBASE_WINDOWS_APP_ID': String.fromEnvironment(
    'FIREBASE_WINDOWS_APP_ID',
    defaultValue: '',
  ),
  'FIREBASE_WINDOWS_MESSAGING_SENDER_ID': String.fromEnvironment(
    'FIREBASE_WINDOWS_MESSAGING_SENDER_ID',
    defaultValue: '',
  ),
  'FIREBASE_WINDOWS_AUTH_DOMAIN': String.fromEnvironment(
    'FIREBASE_WINDOWS_AUTH_DOMAIN',
    defaultValue: '',
  ),
  'FIREBASE_WINDOWS_STORAGE_BUCKET': String.fromEnvironment(
    'FIREBASE_WINDOWS_STORAGE_BUCKET',
    defaultValue: '',
  ),
  'FIREBASE_WINDOWS_MEASUREMENT_ID': String.fromEnvironment(
    'FIREBASE_WINDOWS_MEASUREMENT_ID',
    defaultValue: '',
  ),
};

String _requireFirebaseValue(String key) {
  final fromDefine = _dartDefineMap[key];
  if (fromDefine != null && fromDefine.isNotEmpty) {
    return fromDefine;
  }

  final fromEnv = dotenv.env[key];
  if (fromEnv != null && fromEnv.trim().isNotEmpty) {
    return fromEnv.trim();
  }

  throw StateError(
    'Missing Firebase config for "$key". Add it to your .env file or pass '
    'it with --dart-define=$key=...',
  );
}

FirebaseOptions _buildOptions({
  required String apiKey,
  required String appId,
  required String messagingSenderId,
  required String projectId,
  String? authDomain,
  String? storageBucket,
  String? measurementId,
  String? iosBundleId,
}) {
  return FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: authDomain,
    storageBucket: storageBucket,
    measurementId: measurementId,
    iosBundleId: iosBundleId,
  );
}

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Configure the values in a .env file before running the app.
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

  static FirebaseOptions get web => _buildOptions(
    apiKey: _requireFirebaseValue('FIREBASE_WEB_API_KEY'),
    appId: _requireFirebaseValue('FIREBASE_WEB_APP_ID'),
    messagingSenderId: _requireFirebaseValue(
      'FIREBASE_WEB_MESSAGING_SENDER_ID',
    ),
    projectId: _requireFirebaseValue('FIREBASE_PROJECT_ID'),
    authDomain: _requireFirebaseValue('FIREBASE_WEB_AUTH_DOMAIN'),
    storageBucket: _requireFirebaseValue('FIREBASE_WEB_STORAGE_BUCKET'),
    measurementId: _requireFirebaseValue('FIREBASE_WEB_MEASUREMENT_ID'),
  );

  static FirebaseOptions get android => _buildOptions(
    apiKey: _requireFirebaseValue('FIREBASE_ANDROID_API_KEY'),
    appId: _requireFirebaseValue('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: _requireFirebaseValue(
      'FIREBASE_ANDROID_MESSAGING_SENDER_ID',
    ),
    projectId: _requireFirebaseValue('FIREBASE_PROJECT_ID'),
    storageBucket: _requireFirebaseValue('FIREBASE_ANDROID_STORAGE_BUCKET'),
  );

  static FirebaseOptions get ios => _buildOptions(
    apiKey: _requireFirebaseValue('FIREBASE_IOS_API_KEY'),
    appId: _requireFirebaseValue('FIREBASE_IOS_APP_ID'),
    messagingSenderId: _requireFirebaseValue(
      'FIREBASE_IOS_MESSAGING_SENDER_ID',
    ),
    projectId: _requireFirebaseValue('FIREBASE_PROJECT_ID'),
    storageBucket: _requireFirebaseValue('FIREBASE_IOS_STORAGE_BUCKET'),
    iosBundleId: _requireFirebaseValue('FIREBASE_IOS_BUNDLE_ID'),
  );

  static FirebaseOptions get macos => _buildOptions(
    apiKey: _requireFirebaseValue('FIREBASE_MACOS_API_KEY'),
    appId: _requireFirebaseValue('FIREBASE_MACOS_APP_ID'),
    messagingSenderId: _requireFirebaseValue(
      'FIREBASE_MACOS_MESSAGING_SENDER_ID',
    ),
    projectId: _requireFirebaseValue('FIREBASE_PROJECT_ID'),
    storageBucket: _requireFirebaseValue('FIREBASE_MACOS_STORAGE_BUCKET'),
    iosBundleId: _requireFirebaseValue('FIREBASE_MACOS_BUNDLE_ID'),
  );

  static FirebaseOptions get windows => _buildOptions(
    apiKey: _requireFirebaseValue('FIREBASE_WINDOWS_API_KEY'),
    appId: _requireFirebaseValue('FIREBASE_WINDOWS_APP_ID'),
    messagingSenderId: _requireFirebaseValue(
      'FIREBASE_WINDOWS_MESSAGING_SENDER_ID',
    ),
    projectId: _requireFirebaseValue('FIREBASE_PROJECT_ID'),
    authDomain: _requireFirebaseValue('FIREBASE_WINDOWS_AUTH_DOMAIN'),
    storageBucket: _requireFirebaseValue('FIREBASE_WINDOWS_STORAGE_BUCKET'),
    measurementId: _requireFirebaseValue('FIREBASE_WINDOWS_MEASUREMENT_ID'),
  );
}
